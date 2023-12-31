module Lemmatchers.CLI where

import Lemmatchers.Matchers
import Lemmatchers.TagRecords
import qualified Data.ByteString as LBS
import qualified Data.Text as T
import Data.Text.Encoding
import System.Environment
import System.IO
import Control.Monad

run :: [String] -> String -> IO String
run args input = do

  -- Load matchers from command line argument
  when (null args) $ fail "Expects matcher file name as only argument"
  recordMatchers <- read <$> readFile (head args)

  -- Read data from STDIN
  let records = csvToLemmaRecords . str2lbs $ input
  let lemmi = concatMap (lemmas . lemmata) records
  report $    show (length records) ++ " records with "
          ++  show (length lemmi)   ++ " lemmata found."

  -- Match!
  let results = concat  [ matchRecord m lr
                          | m   <- matchers recordMatchers
                          , lr  <- records
                        ]

  -- Write output!
  report $ show (length results) ++ " results found."
  return $ lbs2str $ matchesToCsv results

  where report  = hPutStrLn stderr
        str2lbs = LBS.fromStrict . encodeUtf8 . T.pack
        lbs2str = T.unpack . decodeUtf8 . LBS.toStrict
