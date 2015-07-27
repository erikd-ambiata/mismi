{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
module Mismi.S3.Internal (
    f'
  , fencode'
  , encodeKey
  , ff'
  , calculateChunks
  , downRange
  , sinkChan
  , sinkChanWithDelay
  , waitForNResults
  , withFileSafe
  ) where

import           Control.Concurrent

import           Control.Monad.Catch
import           Control.Monad.IO.Class

import qualified Data.ByteString as BS

import           Data.Conduit
import qualified Data.Conduit.List as DC

import           Data.Text hiding (length)
import           Data.Text.Encoding
import           Data.UUID
import           Data.UUID.V4

import           P

import           Mismi.S3.Data

import           Network.HTTP.Types (urlEncode)

import           System.Directory
import           System.IO
import           System.FilePath

f' :: (Text -> Text -> a) -> Address -> a
f' f a =
  uncurry f (unBucket $ bucket a, unKey $ key a)

fencode' :: (Text -> Text -> a) -> Address -> a
fencode' f (Address (Bucket b) k) =
  uncurry f (b, encodeKey k)

-- Url is being sent as a header not as a query therefore
-- requires special url encoding. (Do not encode the delimiters)
-- https://github.com/brendanhay/amazonka/issues/127
encodeKey :: Key -> Text
encodeKey (Key k) =
  let splitEncoded = urlEncode True . encodeUtf8 <$> split (== '/') k
      bsEncoded = BS.intercalate "/" splitEncoded
  in
  decodeUtf8 bsEncoded

ff' :: (Text -> Text -> a) -> Address -> a
ff' f a =
  uncurry f (unKey $ key a, unBucket $ bucket a)

-- filesize -> Chunk -> [(offset, chunk, index)]
calculateChunks :: Int -> Int -> [(Int, Int, Int)]
calculateChunks size chunk =
  let go :: Int -> Int -> [(Int, Int, Int)]
      go i o =
        let o' = (o + chunk) in
          if (o' < size)
            then
              (o, chunk, i) : go (i + 1) o'
            else
              let c' = (size - o) in -- last chunk
              [(o, c', i)]
  in
    go 1 0

-- http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.35
-- https://github.com/aws/aws-sdk-java/blob/master/aws-java-sdk-s3/src/main/java/com/amazonaws/services/s3/AmazonS3Client.java#L1135
downRange :: Int -> Int -> Text
downRange start end =
  pack $ "bytes=" <> show start <> "-" <> show end

sinkChan :: MonadIO m => Source m a -> Chan a -> m Int
sinkChan source c =
  sinkChanWithDelay 0 source c

sinkChanWithDelay :: MonadIO m => Int -> Source m a -> Chan a -> m Int
sinkChanWithDelay delay source c =
  source $$ DC.foldM (\i v -> liftIO $ threadDelay delay >> writeChan c v >> pure (i + 1)) 0


waitForNResults :: Int -> Chan a -> IO [a]
waitForNResults i c = do
  let waitForDone acc =
        if (length acc == i)
           then pure acc
           else do
             r <- readChan c
             waitForDone (r : acc)
  waitForDone []

-- | Create a temporary file location that can be used safely, and on a successful operation, do an (atomic) rename
withFileSafe :: (MonadCatch m, MonadIO m) => FilePath -> (FilePath -> m a) -> m a
withFileSafe f1 run = do
  uuid <- liftIO nextRandom >>= return . toString
  let f2 = takeDirectory f1 <> "/" <> "." <> takeFileName f1 <> "." <> uuid
  onException
    (run f2 >>= \a -> liftIO $ whenM (doesFileExist f2) (renameFile f2 f1) >> pure a)
    (liftIO $ removeFile f2)
