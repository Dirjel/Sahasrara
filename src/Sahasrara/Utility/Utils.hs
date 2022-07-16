-- |
-- Module      : Sahasrara.Utility.Utils
-- Description : A place for functions that don't belong anywhere else.
-- License     : MIT
-- Maintainer  : github.com/distributive
-- Stability   : experimental
-- Portability : POSIX
--
-- A place for functions to live that don't got nowhere else to live.
module Sahasrara.Utility.Utils where

import Control.Monad (when)
import Data.Text (Text, filter, toLower)
import Data.Text.ICU.Char (Bool_ (Diacritic), property)
import Data.Text.ICU.Normalize (NormalizationMode (NFD), normalize)
import Data.Text.Lazy (toStrict)
import Data.Text.Lazy.Builder (toLazyText)
import Data.Text.Lazy.Builder.Int (decimal)
import System.Environment (lookupEnv)
import Prelude hiding (filter)

isDebug :: IO Bool
isDebug = do
  d <- lookupEnv "DEBUG"
  return $ justDebug d
  where
    justDebug (Just "True") = True
    justDebug (Just "true") = True
    justDebug (Just "1") = True
    justDebug _ = False

debugPrint :: Show a => a -> IO ()
debugPrint a = do
  d <- isDebug
  when d $ print a

intToText :: Integral a => a -> Text
intToText = toStrict . toLazyText . decimal

-- | @standardise@ converts text to lowercase and removes diacritics
standardise :: Text -> Text
standardise x = filter (not . property Diacritic) normalizedText
  where
    normalizedText = normalize NFD $ toLower x

-- | Utility function to prepend a given Text to Text within a Maybe, or return
-- the empty Text.
maybeEmptyPrepend :: Text -> Maybe Text -> Text
maybeEmptyPrepend s = maybe "" (s <>)

-- | Formats a list with commas and a given separator between the last two elements
formatList :: String -> [String] -> String
formatList _ [] = ""
formatList _ [s] = s
formatList x [a, b] = a ++ " " ++ x ++ " " ++ b
formatList x [a, b, c] = a ++ ", " ++ b ++ ", " ++ x ++ " " ++ c
formatList x (s : ss) = s ++ ", " ++ formatList x ss

-- | Formats a list with commas and an and between the last two elements
formatListAnd :: [String] -> String
formatListAnd = formatList "and"

-- | Formats a list with commas and an or between the last two elements
formatListOr :: [String] -> String
formatListOr = formatList "or"

newtype DebugString = DStr String

instance Show DebugString where
  show (DStr a) = a
