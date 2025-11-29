{-# LANGUAGE DataKinds #-}
module Eval
    ( initDisco
    , eval
    ) where

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

{-----------------------------------------------------------------------------
    Rendering Logic
------------------------------------------------------------------------------}
eval :: String -> String
eval = show . runParser term "<interactive>"

resolveModule'
    :: Resolver -> String
    -> Sem '[Embed IO] (Maybe (FilePath, ModuleProvenance))
resolveModule' = resolveModule

initDisco :: IO ()
initDisco = do
    s <- runM $ resolveModule' FromStdlib "num"
    print s
