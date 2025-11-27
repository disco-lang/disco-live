module Eval
    ( eval
    ) where

import Disco.Parser
    ( term
    , runParser
    )

{-----------------------------------------------------------------------------
    Rendering Logic
------------------------------------------------------------------------------}
eval :: String -> String
eval = show . runParser term "<interactive>"
