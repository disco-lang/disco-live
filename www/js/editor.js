(function() {
    'use strict'
    const {basicSetup, EditorView} = CM["codemirror"]
    window.view = new EditorView({
      doc: "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n",
      parent: document.querySelector("#editor"),
      extensions: [basicSetup]
    })
})()
