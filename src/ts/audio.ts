import { Howl } from "howler";
import introPath from "../../assets/audio/intro.mp3";

export function preload() {
  return {
    introMusic: new Howl({ src: [introPath] })
  };
}

export function playTrack(track: Howl, cb: () => void) {
  track.once("play", cb);
  track.play();
}

export function longFade(track: Howl) {
  track.fade(1, 0, 4000);
}
