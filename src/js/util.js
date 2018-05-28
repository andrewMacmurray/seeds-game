function _bumpDebuggerPanel() {
  var overlay = document.querySelector('.elm-overlay')
  if (overlay) {
    overlay.classList.add('z-999')
  }
}

function bumpDebuggerPanel() {
  setTimeout(_bumpDebuggerPanel, 100)
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
  isProduction
}
