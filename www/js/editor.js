(function() {
    'use strict'
    const {basicSetup, EditorView} = CM["codemirror"]
    window.view = new EditorView({
      doc: "1 + 2",
      parent: document.querySelector("#editor"),
      extensions: [basicSetup]
    })
})()
