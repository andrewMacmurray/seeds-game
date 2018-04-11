const { Elm } = window
const animations = require('./bounce.js')
const cache = require('./cache.js')
const util = require('./util')
const { Howl } = require('howler')

init()
util.bumpDebuggerPanel()

function init() {
  const app = Elm.App.fullscreen({
    now: Date.now(),
    times: cache.getTimes(),
    rawProgress: cache.getProgress()
  })

  const introMusic = new Howl({
    src: ['audio/intro.mp3']
  })

  function introMusicstarted () {
    app.ports.introMusicPlaying.send(true)
  }

  app.ports.playIntroMusic.subscribe(() => {
    introMusic.once('play', introMusicstarted)
    introMusic.play()
  })

  app.ports.fadeMusic.subscribe(() => introMusic.fade(1, 0, 4000))

  app.ports.scrollToHubLevel.subscribe(level => {
    const levelEl = document.getElementById('level-' + level)
    if (levelEl) {
      app.ports.receiveHubLevelOffset.send(levelEl.offsetTop)
    }
  })

  app.ports.generateBounceKeyframes.subscribe(tileSize => {
    const anims = [
      animations.elasticBounceIn(),
      animations.bounceDown(),
      animations.bounceUp(),
      animations.bounceDowns(tileSize)
    ]
    .join(' ')

    const styleNode = document.getElementById('generated-styles')
    styleNode.textContent = anims
  })

  app.ports.cacheProgress.subscribe(progress => {
    cache.setProgress(progress)
  })

  app.ports.clearCache_.subscribe(() => {
    cache.clear()
    window.location.reload()
  })

  app.ports.cacheTimes.subscribe(times => {
    cache.setTimes(times)
  })
}
