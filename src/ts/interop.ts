import * as Bounce from "./bounce";
import * as Cache from "./cache";
import * as Audio from "./audio";
import { Elm } from "../elm/Main";

export function bindPorts(ports: Elm.Main.App["ports"]) {
  const { introMusic } = Audio.preload();

  ports.playIntroMusic.subscribe(() => {
    const musicPlaying = () => ports.introMusicPlaying.send(true);
    Audio.playTrack(introMusic, musicPlaying);
  });

  ports.fadeMusic.subscribe(() => {
    Audio.longFade(introMusic);
  });

  ports.generateBounceKeyframes.subscribe(tileSize => {
    const styleNode = document.getElementById("generated-styles");
    styleNode.textContent = Bounce.generateKeyframes(tileSize);
  });

  ports.cacheProgress.subscribe(progress => {
    Cache.setProgress(progress);
  });

  ports.clearCache_.subscribe(() => {
    Cache.clear();
    window.location.reload();
  });

  ports.cacheLives.subscribe(times => {
    Cache.setLives(times);
  });
}
