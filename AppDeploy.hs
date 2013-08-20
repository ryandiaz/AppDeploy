{-# LANGUAGE OverloadedStrings, DeriveDataTypeable #-}

import System.Posix.Process
import System.Posix.Unistd
import System.Posix.Types
import Control.Concurrent
import Data.List.Split
import Control.Concurrent.Spawn

-- Step 1
-- taskctl /path/to/app [arg1 [arg2 [arg3]]]
-- look at .env file to get environment variables

-- Step 2
-- taskctl description_file
-- File looks like:
-- /path/to/app1 [arg1 [arg2 [...]]]
-- /path/to/app2 [arg1 [...]]
-- ...

-- Step 2
-- Turn into TCP or HTTP server that can monitor multiple apps

-- Step 3
-- List status of running processes

main = do 
    putStrLn "hello"

parseEnv :: FilePath -> IO (Maybe [(String, String)])
parseEnv envFile = do
    envString <- readFile envFile
    let varList = lines envString
    return $ Just $ map (\line -> ((head $ splitOn "=" line) ,(last $ splitOn "=" line))) varList  

--readProcesses :: FilePath -> IO a 
readProcesses descriptionFile = do
        processesString <- readFile descriptionFile 
        let processList = lines processesString
        mapM taskctl processList

taskctl :: String -> IO ThreadId
taskctl cline = do
    let entries = splitOn " " cline
    let command = head entries
    let args = tail entries
    env <- parseEnv ".env"
    startApp command False args env

startApp :: FilePath             -- ^ Command
            -> Bool             -- ^ Search PATH?
            -> [String]             -- ^ Arguments
            -> Maybe [(String, String)]     -- ^ Environment
            -> IO ThreadId
startApp command spath args env  = forkIO $ go
        where go = do
                err1 <- spawn (executeFile command spath args env)
                err <- err1
                case err of
                    0 -> return
                    _ -> do
                        print err
                        go
        --pid <- forkProcess (executeFile command spath args env) 
        --checkStatus pid command spath args env


checkStatus :: ProcessID
            -> FilePath             -- ^ Command
            -> Bool             -- ^ Search PATH?
            -> [String]             -- ^ Arguments
            -> Maybe [(String, String)]     -- ^ Environment
            -> IO ThreadId
checkStatus pid command spath args env = do
    pstatus <- getProcessStatus False True pid
    case pstatus of
        Just stat -> startApp command spath args env
        _         -> do
            threadDelay 5
            checkStatus pid command spath args env