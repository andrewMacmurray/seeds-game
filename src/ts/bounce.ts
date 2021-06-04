import Bounce from "bounce.js/bounce.min.js";

export function generateKeyframes() {
    return [
        bounceDown(),
    ].join(" ");
}

const origin = {x: 0, y: 0};

function bounceDown() {
    return bounce()
        .translate({
            from: {x: 0, y: -200},
            to: origin,
            stiffness: 3,
            bounces: 5
        })
        .getKeyframeCSS({name: "bounce-down"});
}

function bounce() {
    return new Bounce();
}
