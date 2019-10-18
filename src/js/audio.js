import { Howl } from "howler"

export function load() {
  return {
    introMusic: new Howl({ src: [require("../../assets/audio/intro.mp3")] })
  };
}

export function playTrack(track, cb) {
  track.once("play", cb);
  track.play();
}

export function longFade(track) {
  track.fade(1, 0, 4000);
}
