module State
  ( AppState (..)
  , RefState
  , initState
  )
  where

import Data.IORef
import System.Environment

import qualified Interpreter

data AppState = AppState
  { replState :: !Interpreter.Repl
  , editorHash :: !Int
  }

type RefState = IORef AppState

initState :: IO RefState
initState = do
  repl <- initDisco
  newIORef (AppState repl 0)

initDisco :: IO Interpreter.Repl
initDisco = do
    -- NOTE: We set path environment variables here,
    -- because processing the .wasm module with `wizer` may bake
    -- them into the code.
    setEnv "disco_datadir" "stdlib"
    pure Interpreter.initial
