{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeApplications #-}
module Eval
    ( eval
    , loadFile
    ) where

import Data.Char (isSpace)
import Data.Hashable (hash)
import Data.IORef

import qualified Interpreter
import State

{-----------------------------------------------------------------------------
    Rendering Logic
------------------------------------------------------------------------------}

eval :: RefState -> String -> IO String
eval ref command = do
  AppState repl0 h <- readIORef ref
  (result, repl1) <- Interpreter.execute command repl0
  writeIORef ref (AppState repl1 h)
  pure result

loadFile :: RefState -> String -> IO (Maybe String)
loadFile ref s = do
  AppState repl0 h <- readIORef ref
  let h' = hash s
  if h' /= h && not (all isSpace s)
    then do
      writeFile "disco-live.disco" s
      (result, repl1) <- Interpreter.execute (":load disco-live.disco") repl0
      writeIORef ref (AppState repl1 h')
      pure (Just result)
    else
      pure Nothing
