import { setProgress } from "./cache.js"

export function activate() {
  window.skipToLevel = skipToLevel;
}

function skipToLevel(worldId, levelId) {
  setProgress({ worldId, levelId });
  window.location.reload();
}
