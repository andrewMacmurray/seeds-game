import * as Cache from "./cache";

export function activate() {
  window["skipToLevel"] = skipToLevel;
}

function skipToLevel(worldId, levelId) {
  Cache.saveProgress({ worldId, levelId });
  window.location.reload();
}
