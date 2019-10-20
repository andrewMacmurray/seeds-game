import Bounce from "bounce.js/bounce.min.js";

export function generateKeyframes(tileSize) {
  return [
    elasticBounceIn(),
    bounceDown(),
    bounceUp(),
    bounceDowns(tileSize)
  ].join(" ");
}

const origin = { x: 0, y: 0 };

function elasticBounceIn() {
  return bounce()
    .translate({
      from: { x: 0, y: -300 },
      to: origin,
      stiffness: 4
    })
    .getKeyframeCSS({ name: "elastic-bounce-in" });
}

function bounceDown() {
  return bounce()
    .translate({
      from: { x: 0, y: -200 },
      to: origin,
      stiffness: 3,
      bounces: 5
    })
    .getKeyframeCSS({ name: "bounce-down" });
}

function bounceUp() {
  return bounce()
    .translate({
      from: { x: 0, y: 200 },
      to: origin,
      stiffness: 3,
      bounces: 5
    })
    .getKeyframeCSS({ name: "bounce-up" });
}

function bounceDowns(tileSize) {
  let anims = [];
  for (let i = 1; i <= 8; i++) {
    const b = bounce()
      .translate({
        from: origin,
        to: { x: 0, y: tileSize * i },
        stiffness: 2,
        bounces: 2
      })
      .getKeyframeCSS({ name: "bounce-down-" + i });
    anims.push(b);
  }
  return anims.join(" ");
}

function bounce() {
  return new Bounce();
}
