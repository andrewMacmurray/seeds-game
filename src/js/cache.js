const { localStorage } = window;

export function getLives() {
  return safeParse(localStorage.getItem("lives"));
}

export function setLives(lives) {
  return localStorage.setItem("lives", JSON.stringify(lives));
}

export function getProgress() {
  return safeParse(localStorage.getItem("progress"));
}

export function setProgress(progress) {
  return localStorage.setItem("progress", JSON.stringify(progress));
}

export function clear() {
  localStorage.clear();
}

function safeParse(JSONstring) {
  try {
    return JSON.parse(JSONstring);
  } catch (e) {
    return null;
  }
}
