var localStorage = window.localStorage

function getTimes () {
  return safeParse(localStorage.getItem('times'))
}

function setTimes (times) {
  return localStorage.setItem('times', JSON.stringify(times))
}

function getProgress () {
  return safeParse(localStorage.getItem('progress'))
}

function setProgress (progress) {
  return localStorage.setItem('progress', JSON.stringify(progress))
}

function clear () {
  localStorage.clear()
}

function safeParse (rawJSON) {
  try {
    return JSON.parse(rawJSON)
  } catch (e) {
    return null
  }
}

module.exports = {
  getTimes: getTimes,
  setTimes: setTimes,
  getProgress: getProgress,
  setProgress: setProgress,
  clear: clear
}
