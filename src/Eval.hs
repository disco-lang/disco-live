{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeApplications #-}
module Eval
    ( RefRepl
    , initDisco
    , eval
    , loadFile
    ) where

import System.Environment

import qualified Interpreter
import Data.IORef

{-----------------------------------------------------------------------------
    Rendering Logic
------------------------------------------------------------------------------}
type RefRepl = IORef Interpreter.Repl

eval :: RefRepl -> String -> IO String
eval ref command = do
    repl0 <- readIORef ref
    (result, repl1) <- Interpreter.execute command repl0
    writeIORef ref repl1
    pure result

loadFile :: RefRepl -> String -> IO String
loadFile ref s = do
    writeFile "disco-live.disco" s
    repl0 <- readIORef ref
    (result, repl1) <-
        Interpreter.execute (":load disco-live.disco") repl0
    writeIORef ref repl1
    pure result

initDisco :: IO RefRepl
initDisco = do
    -- NOTE: We set path environment variables here,
    -- because processing the .wasm module with `wizer` may bake
    -- them into the code.
    setEnv "disco_datadir" "stdlib"
    newIORef Interpreter.initial
