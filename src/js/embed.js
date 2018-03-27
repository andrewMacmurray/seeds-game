var Elm = window.Elm
var animations = require('./bounce.js')
var cache = require('./cache.js')
var util = require('./util')

init()
util.bumpDebuggerPanel()

function init() {
  var app = Elm.App.fullscreen({
    now: Date.now(),
    times: cache.getTimes(),
    rawProgress: cache.getProgress()
  })

  app.ports.scrollToHubLevel.subscribe(function (level) {
    var levelEl = document.getElementById('level-' + level)
    if (levelEl) {
      app.ports.receiveHubLevelOffset.send(levelEl.offsetTop)
    }
  })

  app.ports.generateBounceKeyframes.subscribe(function (tileSize) {
    var anims = [
      animations.elasticBounceIn(),
      animations.bounceDown(),
      animations.bounceUp(),
      animations.bounceDowns(tileSize)
    ]
    .join(' ')

    var styleNode = document.getElementById('generated-styles')
    styleNode.textContent = anims
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
}
