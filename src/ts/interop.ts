import * as Cache from "./cache";
import * as Audio from "./audio";
import * as Scroll from "./scroll";
import { Elm } from "../elm/Main";

export function bindPorts({
  playIntroMusic,
  introMusicPlaying,
  fadeMusic,
  generateBounceKeyframes,
  cacheProgress,
  cacheLives,
  clearCache_,
  scrollToCenter,
}: Elm.Main.App["ports"]) {
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
