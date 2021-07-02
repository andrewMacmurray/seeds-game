import "pepjs";
import * as Cheats from "./ts/cheats";
import { Elm } from "./elm/Main";
import * as Cache from "./ts/cache";
import * as Audio from "./ts/audio";
import * as Scroll from "./ts/scroll";

Cheats.activate();
init();

function init() {
  let {
    ports: {
      playIntroMusic,
      introMusicPlaying,
      fadeMusic,
      cacheProgress,
      cacheLives,
      clearCache_,
      scrollToCenter,
    }
  } = createApp();
  const { introMusic } = Audio.preload();
  
  playIntroMusic.subscribe(() => {
    const musicPlaying = () => introMusicPlaying.send(true);
    Audio.playTrack(introMusic, musicPlaying);
  });
  
  fadeMusic.subscribe(() => {
    Audio.longFade(introMusic);
  });
  
  cacheProgress.subscribe((progress) => {
    Cache.setProgress(progress);
  });
  
  clearCache_.subscribe(() => {
    Cache.clear();
    window.location.reload();
  });
  
  cacheLives.subscribe((times) => {
    Cache.setLives(times);
  });
  
  scrollToCenter.subscribe((id) => {
    Scroll.toCenter(id);
  });
}

function createApp() {
  return Elm.Main.init({
    node: document.getElementById("app"),
    flags: {
      now: Date.now(),
      lives: Cache.getLives(),
      progress: Cache.getProgress(),
      randomMessageIndex: Math.round(Math.random() * 10),
      window: windowSize()
    }
  });
}

function windowSize() {
  return {
    height: window.innerHeight,
    width: window.innerWidth
  };
}
