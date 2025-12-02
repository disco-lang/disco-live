{-# LANGUAGE DataKinds #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE TypeApplications #-}
module Interpreter 
    ( Repl
    , Command
    , Result
    , initial
    , execute
    ) where

import Disco.Context hiding (filter)
import Disco.Error
import Disco.Eval
import Disco.Interactive.Commands 
    ( dispatch
    , discoCommands
    , parseLine
    )
import Disco.Messages
import Disco.Module
import Disco.Pretty
import Disco.Value

import Control.Lens
    ( makeLenses
    , toListOf
    , view
    , (&)
    , (%~)
    , (.~)
    , (<>~)
    , (^.)
    )

import Control.Monad.IO.Class (liftIO)
import Disco.Effects.Fresh
import Disco.Effects.Input
import Disco.Effects.LFresh
import Disco.Effects.State
import Polysemy
import Polysemy.Embed
import Polysemy.Error
import Polysemy.Fail
import Polysemy.Output
import Polysemy.Random
import Polysemy.Reader

import qualified System.Console.Haskeline as H

import qualified Data.Map as Map
import qualified Data.Set as Set

{-----------------------------------------------------------------------------
    Simpler Interpreter API
------------------------------------------------------------------------------}
-- | State of the Read-Eval-Print-Loop (REPL)
data Repl = Repl
    { topInfo :: TopInfo
    , mem :: Mem
    }

-- | Initial 'Repl' state.
initial :: Repl
initial = Repl
    { topInfo = initTopInfo
    , mem = emptyMem
    }

-- | The initial (empty) record of top-level info.
initTopInfo :: TopInfo
initTopInfo = TopInfo
    { _replModInfo = emptyModuleInfo
    , _topEnv = emptyCtx
    , _topModMap = Map.empty
    , _lastFile = Nothing
    , _discoConfig = initDiscoConfig
    }

-- | Interpreter command
type Command = String

-- | Interpreter result.
type Result = String

-- | Execute a command and change the 'Repl' state.
execute :: Command -> Repl -> IO (Result, Repl)
execute command = runDiscoEffects (runCommand command)

-- | Run a top-level computation.
runDiscoEffects
    :: (forall r. Members DiscoEffects r => Sem r ())
    -> Repl
    -> IO (Result, Repl)
runDiscoEffects action Repl{topInfo,mem} = do
    (outputs, (topInfo', (mem', _))) <-
        H.runInputT H.defaultSettings
        . runFinal @(H.InputT IO)
        . embedToFinal @(H.InputT IO)
        . runEmbedded @_ @(H.InputT IO) liftIO
        . runOutputList @Message -- Collect all output messages
        . runState topInfo -- Run with state TopInfo
        . inputToState @TopInfo -- Dispatch Input TopInfo effect via State effect
        . runState mem -- Start with given memory
        . outputDiscoErrors -- Output any top-level errors
        . runLFresh -- Generate locally fresh names
        . runRandomIO -- Generate randomness via IO
        . mapError EvalErr -- Embed runtime errors into top-level error type
        . failToError Panic -- Turn pattern-match failures into a Panic error
        . runReader (view topEnv topInfo) -- Keep track of current Env
        $ action
    let repl' = Repl topInfo' mem'
    pure (showOutputs outputs, repl')
  where
    showOutputs = unlines . map (show . view message) . filter msgFilter
    msgFilter
        | initDiscoConfig ^. debugMode = const True
        | otherwise = (/= Debug) . view messageType

-- | Run a REPL command within the disco monad.
runCommand :: Members DiscoEffects r => Command -> Sem r ()
runCommand command =
    case parseLine discoCommands Set.empty command of
        Left e -> info (text e)
        Right l ->
            catch @DiscoError (dispatch discoCommands l) (info . pretty')
