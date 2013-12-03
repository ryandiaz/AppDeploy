{-# LANGUAGE MultiParamTypeClasses #-}

module DeployInfo where

import qualified Data.HashTable.IO as H
import System.IO.Unsafe

type AppName = String

data DeployInfo = DeployInfo {
  identifier :: Int,
  hostname :: String,
  portnum :: Int
} deriving Show

class Monad m => Table d m where
  addEntry :: d -> AppName -> DeployInfo -> m ()
  removeEntry :: d -> AppName -> DeployInfo -> m ()
  lookup :: d -> AppName -> m (Maybe DeployInfo)

