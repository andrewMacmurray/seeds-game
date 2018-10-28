const { localStorage } = window;

function getLives() {
  return safeParse(localStorage.getItem("lives"));
}

function setLives(lives) {
  return localStorage.setItem("lives", JSON.stringify(lives));
}

function getProgress() {
  return safeParse(localStorage.getItem("progress"));
}

function setProgress(progress) {
  return localStorage.setItem("progress", JSON.stringify(progress));
}

function clear() {
  localStorage.clear();
}

function safeParse(JSONstring) {
  try {
    return JSON.parse(JSONstring);
  } catch (e) {
    return null;
  }
}

module.exports = {
  getLives,
  setLives,
  getProgress,
  setProgress,
  clear
};
