class _.animation.PhoriaAnimation

  requestAnimation: window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.msRequestAnimationFrame || ((c)=>window.setTimeout(c, 15))

  constructor: ->
    @initScene()

  initScene:=>
