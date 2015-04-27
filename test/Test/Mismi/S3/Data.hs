{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
module Test.Mismi.S3.Data where

import           Data.Text as T

import           Mismi.S3.Data

import           Test.Mismi
import           Test.Mismi.S3 ()

prop_append :: Key -> Key -> Property
prop_append p1 p2 =
  T.count "//" (unKey (p1 </> p2)) === 0

prop_parse :: Address -> Property
prop_parse a =
  addressFromText (addressToText a) === Just a

prop_withKey :: Address -> Property
prop_withKey a =
  withKey id a === a

prop_withKey_dirname :: Address -> Property
prop_withKey_dirname a =
  key (withKey dirname a) === (dirname . key) a

prop_withKey_key :: Address -> Key -> Property
prop_withKey_key a k =
  key (withKey (</> k) a) === (key a) </> k

prop_basename :: Key -> Text -> Property
prop_basename k bn = T.all (/= '/') bn && not (T.null bn) ==>
  basename (k </> (Key bn)) === Just bn

prop_basename_prefix :: Key -> Text -> Property
prop_basename_prefix k bn =
  basename (k </> (Key $ bn <> "/")) === Nothing

prop_basename_root :: Property
prop_basename_root =
  basename (Key "") === Nothing

return []
tests :: IO Bool
tests = $quickCheckAll