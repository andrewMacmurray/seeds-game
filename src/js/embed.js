const bounce = require("./bounce.js");
const cache = require("./cache.js");
const { loadAudio, playTrack, longFade } = require("./audio.js");

function Embed(Program) {
  const { ports } = Program.init({
    node: document.getElementById("app"),
    flags: {
      now: Date.now(),
      lives: cache.getLives(),
      level: cache.getProgress(),
      randomMessageIndex: Math.round(Math.random() * 10),
      window: { height: window.innerHeight, width: window.innerWidth }
    }
  });

  const {
    playIntroMusic,
    introMusicPlaying,
    fadeMusic,
    generateBounceKeyframes,
    cacheProgress,
    clearCache_,
    cacheLives
  } = ports;

  const { introMusic } = loadAudio();

  playIntroMusic.subscribe(() => {
    const musicPlaying = () => introMusicPlaying.send(true);
    playTrack(introMusic, musicPlaying);
  });

  fadeMusic.subscribe(() => {
    longFade(introMusic);
  });

  generateBounceKeyframes.subscribe(tileSize => {
    const styleNode = document.getElementById("generated-styles");
    styleNode.textContent = bounce.generateKeyframes(tileSize);
  });

  cacheProgress.subscribe(progress => {
    cache.setProgress(progress);
  });

  clearCache_.subscribe(() => {
    cache.clear();
    window.location.reload();
  });

  cacheLives.subscribe(times => {
    cache.setLives(times);
  });
}

module.exports = { Embed };
