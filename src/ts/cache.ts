const { localStorage } = window;

interface Lives {
  lastPlayed: number;
  timeTillNextLife: number;
}

interface Progress {
  levelId: number;
  worldId: number;
}

export function getLives(): Lives | null {
  return safeParse(localStorage.getItem("lives"));
}

export function saveLives(lives: Lives) {
  return localStorage.setItem("lives", JSON.stringify(lives));
}

export function getProgress(): Progress | null {
  return safeParse(localStorage.getItem("progress"));
}

export function saveProgress(progress: Progress) {
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
