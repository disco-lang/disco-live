module Main where

import Control.Concurrent
import GHC.Wasm.Prim

import Eval (eval)

{-----------------------------------------------------------------------------
    JavaScript Imports
------------------------------------------------------------------------------}
foreign import javascript unsafe "document.getElementById($1)"
  js_document_getElementById :: JSString -> IO JSVal

foreign import javascript unsafe "$1.addEventListener($2, $3)"
  js_addEventListener :: JSVal -> JSString -> JSVal -> IO ()

foreign import javascript "wrapper"
  asEventListener :: (JSVal -> IO ()) -> IO JSVal

foreign import javascript unsafe "$1.target.value"
  js_event_target_value :: JSVal -> IO Double

foreign import javascript unsafe "$1.value"
  js_input_value :: JSVal -> IO JSString

foreign import javascript "$1.innerHTML = $2"
  js_element_setInnerHtml :: JSVal -> JSString -> IO ()

main :: IO ()
main = error "main is unused"

{-----------------------------------------------------------------------------
    Web page
------------------------------------------------------------------------------}
foreign export javascript "setup" setup :: IO ()

-- | Main entrypoint.
setup :: IO ()
setup = do
    -- Register callback for button click.
    evalButton <- js_document_getElementById (toJSString "eval")
    onEvalButtonCallback <- asEventListener onEvalButtonClick
    js_addEventListener evalButton (toJSString "click") onEvalButtonCallback

-- | Handle button clicks.
onEvalButtonClick :: JSVal -> IO ()
onEvalButtonClick event = do
    exprInput  <- js_document_getElementById (toJSString "expr")
    expr       <- fromJSString <$> js_input_value exprInput
    
    let svg = eval expr
    outDiv     <- js_document_getElementById (toJSString "out")
    js_element_setInnerHtml outDiv (toJSString svg)
