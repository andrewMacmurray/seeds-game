var Elm = window.Elm;
var animations = require('./bounce.js');

function init() {
  var node = document.getElementById('main');
  var app = Elm.App.embed(node);

  app.ports.scrollToHubLevel.subscribe(function (level) {
    var levelOffset = document.getElementById('level-' + level).offsetTop
    app.ports.receiveHubLevelOffset.send(levelOffset)
  })

  app.ports.getExternalAnimations.subscribe(function (tileSize) {
    var anims = [
      animations.elasticBounceIn(),
      animations.hardBounceDown(),
      animations.hardBounceDowns(tileSize)
    ]
    .join(' ')

    app.ports.receiveExternalAnimations.send(anims)
  })
}

init()
