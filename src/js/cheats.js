const { setProgress } = require("./cache.js");

function activate() {
  window.skipToLevel = skipToLevel;
}

function skipToLevel(worldId, levelId) {
  setProgress({ worldId, levelId });
  window.location.reload();
}

module.exports = { activate };
