import { Elm } from "../elm/Main";
import * as Interop from "./interop";
import * as Cache from "./cache";

export function init() {
  const flags = {
    now: Date.now(),
    lives: Cache.getLives(),
    level: Cache.getProgress(),
    randomMessageIndex: Math.round(Math.random() * 10),
    window: { height: window.innerHeight, width: window.innerWidth }
  };

  const node = document.getElementById("app");

  Interop.bindPorts(Elm.Main.init({ node, flags }));
}
