const { Howl } = require('howler')

function loadAudio () {
  const introMusic = new Howl({
    src: ['audio/intro.mp3']
  })
  return { introMusic }
}

function playTrack (track, cb) {
  track.once('play', cb)
  track.play()
}

function longFade (track) {
  track.fade(1, 0, 4000)
}

module.exports = {
  loadAudio,
  playTrack,
  longFade
}
