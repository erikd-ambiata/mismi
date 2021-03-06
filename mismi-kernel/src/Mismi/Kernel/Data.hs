{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
module Mismi.Kernel.Data (
    MismiRegion (..)
  , renderMismiRegion
  , parseMismiRegion
  ) where

import           P


-- | Mismi's view of available AWS regions.
data MismiRegion =
    IrelandRegion         -- ^ Europe / eu-west-1
  | FrankfurtRegion       -- ^ Europe / eu-central-1
  | TokyoRegion           -- ^ Asia Pacific / ap-northeast-1
  | SingaporeRegion       -- ^ Asia Pacific / ap-southeast-1
  | SydneyRegion          -- ^ Asia Pacific / ap-southeast-2
  | BeijingRegion         -- ^ China / cn-north-1
  | NorthVirginiaRegion   -- ^ US / us-east-1
  | NorthCaliforniaRegion -- ^ US / us-west-1
  | OregonRegion          -- ^ US / us-west-2
  | GovCloudRegion        -- ^ AWS GovCloud / us-gov-west-1
  | GovCloudFIPSRegion    -- ^ AWS GovCloud (FIPS 140-2) S3 Only / fips-us-gov-west-1
  | SaoPauloRegion        -- ^ South America / sa-east-1
    deriving (Eq, Ord, Read, Show, Enum, Bounded)


renderMismiRegion :: MismiRegion -> Text
renderMismiRegion r =
  case r of
    IrelandRegion ->
      "eu-west-1"
    FrankfurtRegion ->
      "eu-central-1"
    TokyoRegion ->
      "ap-northeast-1"
    SingaporeRegion ->
      "ap-southeast-1"
    SydneyRegion ->
      "ap-southeast-2"
    BeijingRegion ->
      "cn-north-1"
    NorthVirginiaRegion ->
      "us-east-1"
    NorthCaliforniaRegion ->
      "us-west-1"
    OregonRegion ->
      "us-west-2"
    GovCloudRegion ->
      "us-gov-west-1"
    GovCloudFIPSRegion ->
      "fips-us-gov-west-1"
    SaoPauloRegion ->
      "sa-east-1"

parseMismiRegion :: Text -> Maybe MismiRegion
parseMismiRegion t =
  case t of
    "eu-west-1" ->
      Just IrelandRegion
    "eu-central-1" ->
      Just FrankfurtRegion
    "ap-northeast-1" ->
      Just TokyoRegion
    "ap-southeast-1" ->
      Just SingaporeRegion
    "ap-southeast-2" ->
      Just SydneyRegion
    "cn-north-1" ->
      Just BeijingRegion
    "us-east-1" ->
      Just NorthVirginiaRegion
    "us-west-2" ->
      Just OregonRegion
    "us-west-1" ->
      Just NorthCaliforniaRegion
    "us-gov-west-1" ->
      Just GovCloudRegion
    "fips-us-gov-west-1" ->
      Just GovCloudFIPSRegion
    "sa-east-1" ->
      Just SaoPauloRegion
    _ ->
      Nothing
