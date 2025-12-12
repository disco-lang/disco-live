module Main where

import Control.Monad (when)
import GHC.Wasm.Prim

import Eval (RefRepl, eval, initDisco)

{-----------------------------------------------------------------------------
    JavaScript Imports
------------------------------------------------------------------------------}
foreign import javascript unsafe "document.getElementById($1)"
  js_document_getElementById :: JSString -> IO JSVal

foreign import javascript unsafe "document.createElement($1)"
  js_document_createElement :: JSString -> IO JSVal

foreign import javascript unsafe "$1.addEventListener($2, $3)"
  js_addEventListener :: JSVal -> JSString -> JSVal -> IO ()

foreign import javascript unsafe "$1.appendChild($2)"
  js_element_appendChild :: JSVal -> JSVal -> IO ()

foreign import javascript "wrapper"
  asEventListener :: (JSVal -> IO ()) -> IO JSVal

foreign import javascript unsafe "$1.value"
  js_input_value :: JSVal -> IO JSString

foreign import javascript unsafe "$1.key"
  js_event_key :: JSVal -> IO JSString

foreign import javascript unsafe "$1.textContent = $2"
  js_element_setTextContent :: JSVal -> JSString -> IO ()

foreign import javascript unsafe "view.state.doc.toString()"
  js_view_state_doc_toString :: IO JSString

foreign import javascript "$1.innerHTML = $2"
  js_element_setInnerHtml :: JSVal -> JSString -> IO ()

foreign import javascript unsafe "$1.scrollTop = $1.scrollHeight"
  js_element_scrollToBottom :: JSVal -> IO ()

main :: IO ()
main = error "main is unused"

{-----------------------------------------------------------------------------
    Web page
------------------------------------------------------------------------------}
foreign export javascript "setup" setup :: IO ()

-- | Main entrypoint.
setup :: IO ()
setup = do
    ref <- initDisco

    -- Register callback for button click.
    evalButton <- js_document_getElementById (toJSString "eval")
    callback <- asEventListener (onEvalButtonClick ref)
    js_addEventListener evalButton (toJSString "click") callback

    exprIn <- js_document_getElementById (toJSString "expr")
    callback <- asEventListener (onExprKeyUp ref)
    js_addEventListener exprIn (toJSString "keyup") callback

-- | Handle 'keyup'.
onExprKeyUp :: RefRepl -> JSVal -> IO ()
onExprKeyUp ref event = do
    key <- js_event_key event
    when (fromJSString key == "Enter") $ handleEval ref

-- | Handle button clicks.
onEvalButtonClick :: RefRepl -> JSVal -> IO ()
onEvalButtonClick ref _ = handleEval ref

-- | Handle evaluation request.
handleEval :: RefRepl -> IO ()
handleEval ref = do
    module_ <- fromJSString <$> js_view_state_doc_toString
    exprIn  <- js_document_getElementById (toJSString "expr")
    expr    <- fromJSString <$> js_input_value exprIn

    logHistory $ "disco> " <> expr
    result <- eval ref expr
    logHistory result

-- | Put an item in the interpreter history.
logHistory :: String -> IO ()
logHistory s = do
    div <- js_document_getElementById (toJSString "out")
    pre <- js_document_createElement (toJSString "pre")
    js_element_appendChild div pre
    js_element_setInnerHtml pre (toJSString s)
    js_element_scrollToBottom div
