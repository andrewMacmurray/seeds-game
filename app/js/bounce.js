var Bounce = require('../../node_modules/bounce.js/bounce.min.js');


function elasticBounceIn () {
  return new Bounce()
    .translate({
      from: { x: 0, y: -300 },
      to: { x: 0, y: 0 },
      stiffness: 4
    })
    .getKeyframeCSS({
      name: 'elastic-bounce-in'
    })
}

function hardBounceDown () {
  return new Bounce()
    .translate({
      from: { x: 0, y: -200 },
      to: { x: 0, y: 0 },
      stiffness: 2,
      bounces: 4,
      easing: "hardbounce"
    })
    .getKeyframeCSS({
      name: 'hard-bounce-down'
    })
}


function hardBounceDowns (tileSize) {
  var anims = []
  for (var i = 1; i <= 8; i++) {
    var b = new Bounce()
      .translate({
        from: { x: 0, y: 0 },
        to: { x: 0, y: tileSize * i },
        stiffness: 1,
        bounces: 2,
        easing: "hardbounce"
      })
      .getKeyframeCSS({
        name: 'hard-bounce-down-' + i
      })

    anims.push(b)
  }
  return anims.join(' ')
}


module.exports = {
  elasticBounceIn,
  hardBounceDown,
  hardBounceDowns
}
