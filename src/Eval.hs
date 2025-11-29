{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeApplications #-}
module Eval
    ( initDisco
    , eval
    ) where

import Disco.Error
import Disco.Eval
    ( initDiscoConfig
    , runDisco
    )
import Disco.Interactive.Commands 
    ( dispatch
    , discoCommands
    , parseLine
    )
import Disco.Messages
    ( info
    )
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
import Disco.Pretty
    ( pretty'
    , text
    )
import Polysemy
    ( Embed
    , Sem
    , runM
    )
import Polysemy.Error
    ( catch
    )
import qualified Data.Set as Set

{-----------------------------------------------------------------------------
    Rendering Logic
------------------------------------------------------------------------------}
eval :: String -> IO ()
eval expr = runDisco initDiscoConfig $ do
    case parseLine discoCommands Set.empty expr of
        Left e -> info (text e)
        Right l ->
            catch @DiscoError (dispatch discoCommands l) (info . pretty')

parseTest :: String -> String
parseTest = show . runParser term "<interactive>"

resolveModule'
    :: Resolver -> String
    -> Sem '[Embed IO] (Maybe (FilePath, ModuleProvenance))
resolveModule' = resolveModule

initDisco :: IO ()
initDisco = do
    s <- runM $ resolveModule' FromStdlib "num"
    print s
