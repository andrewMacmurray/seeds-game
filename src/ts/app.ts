import { Elm } from "../elm/Main";
import * as Interop from "./interop";
import * as Cache from "./cache";

export function init() {
  const { ports } = createApp();
  Interop.bindPorts(ports);
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
