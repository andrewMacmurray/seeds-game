const { TweenMax, Elastic } = require('gsap')
const { whenMounted } = require('./util')

function animateHills () {
  const hillVals = [
    [ 800, 700 ],
    [ 800, 600 ],
    [ 800, 500 ],
    [ 800, 400 ],
    [ 800, 300 ]
  ]
  const hills = Array.from(document.querySelectorAll('.hill')).reverse()
  hills.forEach((hill, i) => {
    const [ from, to ] = hillVals[i]
    const toConfig = {
      y: to,
      delay: i * 0.3,
      ease: Elastic.easeOut.config(0.2, 0.3)
    }
    TweenMax.fromTo(hill, 2, { y: from }, toConfig)
  })
}

function growSeeds () {
  const seeds = Array.from(document.querySelectorAll('.growing-seed'))
  const seedVals = seeds
    .map(s => [ s.getAttribute('gsap-val-delay'), s ])
    .forEach(([ delay, s]) => {
      const toConfig = {
        scale: 1,
        opacity: 1,
        delay: parseInt(delay) / 1000,
        ease: Elastic.easeOut.config(0.3, 0.1)
      }
      TweenMax.fromTo(s, 0.8, { scale: 0.5, opacity: 0 }, toConfig)
    })
}

module.exports = {
  animateHills: () => whenMounted("rolling-hills", animateHills),
  growSeeds: () => whenMounted("growing-seeds", growSeeds)
}
