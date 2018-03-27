function _bumpDebuggerPanel () {
  var overlay = document.querySelector('.elm-overlay')
  if (overlay) {
    overlay.classList.add('z-999')
  }
}

function bumpDebuggerPanel () {
  setTimeout(_bumpDebuggerPanel, 100)
}

module.exports = {
  bumpDebuggerPanel: bumpDebuggerPanel
}
