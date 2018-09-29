const { Elm } = window;
const animations = require("./bounce.js");
const cache = require("./cache.js");
const util = require("./util");
const { loadAudio, playTrack, longFade } = require("./audio.js");

// registerServiceWorker()
init();

util.bumpDebuggerPanel();

window.skipToLevel = util.skipToLevel;

function init() {
  // Init Elm App
  const { ports } = Elm.App.init({
    node: document.getElementById("app"),
    flags: {
      now: Date.now(),
      times: cache.getTimes(),
      rawProgress: cache.getProgress(),
      window: { height: window.innerHeight, width: window.innerWidth }
    }
  });

  // Audio
  const { introMusic } = loadAudio();

  ports.playIntroMusic.subscribe(() => {
    const musicPlaying = () => ports.introMusicPlaying.send(true);
    playTrack(introMusic, musicPlaying);
  });

  ports.fadeMusic.subscribe(() => longFade(introMusic));

  ports.generateBounceKeyframes.subscribe(tileSize => {
    const anims = [
      animations.elasticBounceIn(),
      animations.bounceDown(),
      animations.bounceUp(),
      animations.bounceDowns(tileSize)
    ].join(" ");

    const styleNode = document.getElementById("generated-styles");
    styleNode.textContent = anims;
  });

  // LocalStorgage Cache
  ports.cacheProgress.subscribe(progress => {
    cache.setProgress(progress);
  });

  ports.clearCache_.subscribe(() => {
    cache.clear();
    window.location.reload();
  });

  ports.cacheTimes.subscribe(times => {
    cache.setTimes(times);
  });
}

function registerServiceWorker() {
  if ("serviceWorker" in navigator) {
    window.addEventListener("load", () => {
      navigator.serviceWorker.register("/sw.js");
    });
  }
}
