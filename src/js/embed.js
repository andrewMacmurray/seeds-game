var Elm = window.Elm
var animations = require('./bounce.js')
var cache = require('./cache.js')

function init() {
  var now = Date.now()

  var app = Elm.App.fullscreen({
    now: now,
    times: cache.getTimes(),
    rawProgress: cache.getProgress()
  })

  app.ports.scrollToHubLevel.subscribe(function (level) {
    var levelEl = document.getElementById('level-' + level)
    if (levelEl) {
      app.ports.receiveHubLevelOffset.send(levelEl.offsetTop)
    }
  })

  app.ports.getExternalAnimations.subscribe(function (tileSize) {
    var anims = [
      animations.elasticBounceIn(),
      animations.bounceDown(),
      animations.bounceUp(),
      animations.bounceDowns(tileSize)
    ]
    .join(' ')

    app.ports.receiveExternalAnimations.send(anims)
  })

  app.ports.cacheProgress.subscribe(function (progress) {
    cache.setProgress(progress)
  })

  app.ports.clearCache_.subscribe(function () {
    cache.clear()
    window.location.reload()
  })

  app.ports.cacheTimes.subscribe(function (times) {
    cache.setTimes(times)
  })

  setTimeout(bumpDebuggerPanel, 100)
}

function bumpDebuggerPanel () {
  var overlay = document.querySelector('.elm-overlay')
  if (overlay) {
    overlay.classList.add('z-999')
  }
}

init()
