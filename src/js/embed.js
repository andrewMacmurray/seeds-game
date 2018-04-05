const { Elm } = window
const animations = require('./bounce.js')
const cache = require('./cache.js')
const util = require('./util')
const { animateHills, growSeeds } = require('./animations.js')
const { loadAudio, playTrack, longFade } = require('./audio.js')

init()
util.bumpDebuggerPanel()

function init() {
  // Init Elm App
  const { ports } = Elm.App.fullscreen({
    now: Date.now(),
    times: cache.getTimes(),
    rawProgress: cache.getProgress()
  })

  // Audio
  const { introMusic } = loadAudio()

  ports.playIntroMusic.subscribe(() => {
    const musicPlaying = () => ports.introMusicPlaying.send(true)
    playTrack(introMusic, musicPlaying)
  })

  ports.fadeMusic.subscribe(() => longFade(introMusic))

  // Scroll
  ports.scrollToHubLevel.subscribe(level => {
    const levelEl = document.getElementById('level-' + level)
    if (levelEl) {
      ports.receiveHubLevelOffset.send(levelEl.offsetTop)
    }
  })

  // Animations
  ports.animateHills.subscribe(animateHills)
  ports.animateGrowingSeeds.subscribe(growSeeds)

  ports.generateBounceKeyframes.subscribe(tileSize => {
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

  // Cache
  ports.cacheProgress.subscribe(progress => {
    cache.setProgress(progress)
  })

  ports.clearCache_.subscribe(() => {
    cache.clear()
    window.location.reload()
  })

  ports.cacheTimes.subscribe(times => {
    cache.setTimes(times)
  })
}
