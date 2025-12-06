{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeApplications #-}
module Eval
    ( RefRepl
    , initDisco
    , eval
    ) where

import Control.Monad (forM_)
import Disco.Module
    ( Resolver (..)
    , resolveModule
    )
import Disco.Names
    ( ModuleProvenance
    )
import Polysemy
    ( Embed
    , Sem
    , runM
    )
import System.Environment

import Interpreter
    ( Repl
    , execute
    , initial
    )
import Data.IORef

{-----------------------------------------------------------------------------
    Rendering Logic
------------------------------------------------------------------------------}
type RefRepl = IORef Repl

eval :: RefRepl -> String -> IO String
eval ref command = do
    repl0 <- readIORef ref
    (result, repl1) <- execute command repl0
    writeIORef ref repl1
    pure result

resolveModule'
    :: Resolver -> String
    -> Sem '[Embed IO] (Maybe (FilePath, ModuleProvenance))
resolveModule' = resolveModule

initDisco :: IO RefRepl
initDisco = do
    -- NOTE: We set path environment variables here,
    -- because processing the .wasm module with `wizer` may bake
    -- them into the code.
    setEnv "disco_datadir" "stdlib"

    -- Debug output
    s <- runM $ resolveModule' FromStdlib "num"
    print s

    newIORef initial
