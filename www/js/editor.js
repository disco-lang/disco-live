(function() {
    'use strict'
    const {basicSetup, EditorView} = CM["codemirror"]

    const queryString = window.location.search
    const urlParams = new URLSearchParams(queryString)
    let param = urlParams.get('module')
    if (param === null) { param = "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" }

    window.view = new EditorView({
      doc: decodeURIComponent(param),
      parent: document.querySelector("#editor"),
      extensions: [basicSetup]
    })
})()
