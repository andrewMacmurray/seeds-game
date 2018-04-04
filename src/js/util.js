function _bumpDebuggerPanel () {
  var overlay = document.querySelector('.elm-overlay')
  if (overlay) {
    overlay.classList.add('z-999')
  }
}

function bumpDebuggerPanel () {
  setTimeout(_bumpDebuggerPanel, 100)
}

// pinched from https://github.com/elm-lang/virtual-dom/issues/11
// calls a dom manipulating function after particular element has been added to the dom
function whenMounted(id, cb) {
  const element = document.getElementById(id);
  if (element) {
    cb()
  } else {
    callWhenIdAdded(
      document.querySelector("body"),
      id,
      () => whenMounted.apply(null, arguments)
    )
  }
}

function callWhenIdAdded(parent, id, cb) {
  const observer = new MutationObserver((mutations) => {
    // Get an array of the added ids
    const addedIds = mutations.reduce((acc, mutationRecord) => {
      const ids = Array
        .from(mutationRecord.addedNodes)
        .filter(node => node.attributes.getNamedItem('id') !== null)
        .map(node => node.attributes.getNamedItem('id').value)

      return acc.concat(ids)
    }, [])

    // If that contains the id we are looking for then invoke the function and remove the observer
    if (addedIds.indexOf(id) >= 0) {
      observer.disconnect()
      cb()
    }
  })

  observer.observe(parent, {
    childList: true,
    subtree: true
  })
}

module.exports = {
  bumpDebuggerPanel,
  whenMounted
}
