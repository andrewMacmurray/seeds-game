import * as Bounce from "./bounce.js"
import * as Cache from "./cache.js"
import * as Audio from "./audio.js"

export function Embed(Program) {
  const flags = {
    now: Date.now(),
    lives: Cache.getLives(),
    level: Cache.getProgress(),
    randomMessageIndex: Math.round(Math.random() * 10),
    window: { height: window.innerHeight, width: window.innerWidth }
  };

  const { ports } = Program.init({
    node: document.getElementById("app"),
    flags
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

  const { introMusic } = Audio.load();

  playIntroMusic.subscribe(() => {
    const musicPlaying = () => introMusicPlaying.send(true);
    Audio.playTrack(introMusic, musicPlaying);
  });

  fadeMusic.subscribe(() => {
    Audio.longFade(introMusic);
  });

  generateBounceKeyframes.subscribe(tileSize => {
    const styleNode = document.getElementById("generated-styles");
    styleNode.textContent = Bounce.generateKeyframes(tileSize);
  });

  cacheProgress.subscribe(progress => {
    Cache.setProgress(progress);
  });

  clearCache_.subscribe(() => {
    Cache.clear();
    window.location.reload();
  });

  cacheLives.subscribe(times => {
    Cache.setLives(times);
  });
}
