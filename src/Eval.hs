{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeApplications #-}
module Eval
    ( initDisco
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
import Disco.Parser
    ( term
    , runParser
    )
import Polysemy
    ( Embed
    , Sem
    , runM
    )
import System.Environment

import Interpreter
    ( Repl
    , initial
    , execute
    )

{-----------------------------------------------------------------------------
    Rendering Logic
------------------------------------------------------------------------------}
eval :: String -> IO String
eval command = fst <$> execute command initial

parseTest :: String -> String
parseTest = show . runParser term "<interactive>"

resolveModule'
    :: Resolver -> String
    -> Sem '[Embed IO] (Maybe (FilePath, ModuleProvenance))
resolveModule' = resolveModule

initDisco :: IO ()
initDisco = do
    putStrLn $ "Printing Environment"
    xs <- getEnvironment
    forM_ xs $ \(a,b) -> putStrLn $ a <> " = " <> b

    let filename = "/stdlib/num.disco"
    putStrLn $ "Printing " <> filename
    putStrLn =<< readFile filename

    s <- runM $ resolveModule' FromStdlib "num"
    print s
