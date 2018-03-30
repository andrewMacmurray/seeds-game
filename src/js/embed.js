var Elm = window.Elm
var animations = require('./bounce.js')
var cache = require('./cache.js')
var util = require('./util')
var { TweenMax, Elastic } = require('gsap')

init()
util.bumpDebuggerPanel()

function init() {
  var app = Elm.App.fullscreen({
    now: Date.now(),
    times: cache.getTimes(),
    rawProgress: cache.getProgress()
  })

  app.ports.animate.subscribe(function () {
    var hillVals = [
      [ 800, 700 ],
      [ 800, 600 ],
      [ 800, 500 ],
      [ 800, 400 ],
      [ 800, 300 ]
    ]
    var hills = Array.from(document.querySelectorAll('.hill')).reverse()
    hills.forEach((hill, i) => {
      [ from, to ] = hillVals[i]
      const toConfig = {
        y: to,
        delay: i * 0.5,
        ease: Elastic.easeOut.config(0.3, 0.3)
      }
      TweenMax.fromTo(hill, 2, { y: from }, toConfig)
    })
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
