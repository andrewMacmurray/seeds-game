const { setProgress } = require('./cache.js');

function _bumpDebuggerPanel () {
  var overlay = document.querySelector('.elm-overlay')
  if (overlay) {
    overlay.classList.add('z-999')
  }
}

function bumpDebuggerPanel() {
  setTimeout(_bumpDebuggerPanel, 100)
}

function skipToLevel(world, level) {
    setProgress({ world, level })
    window.location.reload()
}

module.exports = {
  bumpDebuggerPanel,
  skipToLevel
}
