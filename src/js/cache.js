const { localStorage } = window

function getTimes() {
  return safeParse(localStorage.getItem('times'))
}

function setTimes(times) {
  return localStorage.setItem('times', JSON.stringify(times))
}

function getProgress() {
  return safeParse(localStorage.getItem('progress'))
}

function setProgress(progress) {
  return localStorage.setItem('progress', JSON.stringify(progress))
}

function clear() {
  localStorage.clear()
}

function safeParse(JSONstring) {
  try {
    return JSON.parse(JSONstring)
  } catch (e) {
    return null
  }
}

module.exports = {
  getTimes,
  setTimes,
  getProgress,
  setProgress,
  clear
}
