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

function isDevelopment() {
  return window.location.hostname.includes('localhost')
}

function isProduction() {
  return !isDevelopment()
}

module.exports = {
  bumpDebuggerPanel,
  isDevelopment,
  isProduction,
  skipToLevel
}
