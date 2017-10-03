var Elm = window.Elm;
var animations = require('./bounce.js');

function init() {
  var node = document.getElementById('main');
  var app = Elm.App.embed(node);

  app.ports.scrollToHubLevel.subscribe(function (level) {
    var levelEl = document.getElementById('level-' + level)
    if (levelEl) {
      app.ports.receiveHubLevelOffset.send(levelEl.offsetTop)
    }
  })

  app.ports.getExternalAnimations.subscribe(function (tileSize) {
    var anims = [
      animations.elasticBounceIn(),
      animations.bounceDown(),
      animations.bounceDowns(tileSize)
    ]
    .join(' ')

    app.ports.receiveExternalAnimations.send(anims)
  })
}

init()
