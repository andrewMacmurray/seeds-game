const { TweenMax, Elastic } = require('gsap')

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

module.exports = {
  animateHills
}
