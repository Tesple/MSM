class _.animation.PhoriaAnimation
  # define namespace for animation
  ns: {}
  pos: {
    alpha: .4
    beta : .4
    gamma: .4
  }
  dat: {
    orientation:  true
    rotationRate: false
    acceleration: false
    stop:         false
    keepGoing:    false
    nature:       true
  }
  constructor: ->
    window.an = @
    @statusNode = $("body #status")
    @setupNamespace()
    @loadBitmaps()

    if $.browser.isMobile
      @pinMobileEvents()
      @pinMobileGUIControls()
    else
      @pinGUIControls()

  setupNamespace:=>
    # define requestAnimationFrame as requestAnimFrame
    window.requestAnimFrame =
        window.requestAnimationFrame       or
        window.webkitRequestAnimationFrame or
        window.mozRequestAnimationFrame    or
        window.msRequestAnimationFrame     or
        ((c)-> window.setTimeout(c, 15))

    @ns.loader   = new Phoria.Preloader()
    @ns.bitmaps  = []
    @ns.canvas   = $('body canvas')[0]
    @ns.scene    = new Phoria.Scene()
    @ns.renderer = new Phoria.CanvasRenderer(@ns.canvas)
    @ns.c        = Phoria.Util.generateUnitCube()
    @ns.cube     = Phoria.Entity.create(
        {
          points:   @ns.c.points
          edges:    @ns.c.edges
          polygons: @ns.c.polygons
        }
    )
    @ns.pause    = false
    @ns.heading  = 0.0
    @ns.lookAt   = vec3.fromValues(0, -5, 1)

  loadBitmaps:=>
    ext = if @dat.nature then ".jpg" else ".png"
    for i in [0...6]
       @ns.bitmaps.push(new Image())
       @ns.loader.addImage(@ns.bitmaps[i], 'images/texture' + i + ext )

    @ns.loader.onLoadCallback(@initPhoria)

  initPhoria: =>
    @ns.scene.camera.position = {
        x:0.0
        y:5.0
        z:-15.0
    }
    @ns.scene.perspective.aspect = @ns.canvas.width / @ns.canvas.height
    @ns.scene.viewport.width     = @ns.canvas.width
    @ns.scene.viewport.height    = @ns.canvas.height

    for i in [0...6]
      @ns.cube.textures.push(@ns.bitmaps[i])
      @ns.cube.polygons[i].texture = i

    @ns.scene.graph.push(@ns.cube)
    @ns.scene.graph.push(
      Phoria.DistantLight.create(
        {
          direction: {
            x:0
            y:-3
            z:5
          }
        }
      )
    )

    fnAnimate = =>
      if !@ns.pause
        if not $.browser.isMobile or @dat.keepGoing
          @ns.cube.rotateX(@pos.alpha * Phoria.RADIANS)
          @ns.cube.rotateY(@pos.beta * Phoria.RADIANS)
          @ns.cube.rotateZ(@pos.gamma * Phoria.RADIANS)
        @ns.scene.modelView()
        @ns.renderer.render(@ns.scene)
      window.requestAnimFrame(fnAnimate)

    @ns.scene.perspective.fov = 12

    window.requestAnimFrame(fnAnimate)


  pinGUIControls: =>
    @ns.gui = new dat.GUI()
    f = @ns.gui.addFolder('Rotation speed')
    f.add(@pos, "alpha").min(-1).max(1).step(0.01)
    f.add(@pos, "beta" ).min(-1).max(1).step(0.01)
    f.add(@pos, "gamma").min(-1).max(1).step(0.01)
    f = @ns.gui.addFolder('Images type')
    f.add(@dat, 'nature').listen().onChange(=>@loadBitmaps())

  pinMobileGUIControls: =>
    @ns.gui = new dat.GUI()
    changeValue = (v1, v2, v3, v4, v5)=>
      @dat.orientation  = v1
      @dat.rotationRate = v2
      @dat.acceleration = v3
      @dat.stop         = v4
      @dat.keepGoing    = v5

    f = @ns.gui.addFolder('Gyroscope')
    f.add(@dat, 'orientation').listen().onChange(
      =>
        changeValue(true, false, false, false, @dat.keepGoing)
        @pinMobileEvents()
    )
    f.add(@dat, 'rotationRate').listen().onChange(
      =>
        changeValue(false, true, false, false, @dat.keepGoing)
        @pinMobileEvents()
    )
    f.add(@dat, 'acceleration').listen().onChange(
      =>
        changeValue(false, false, true, false, @dat.keepGoing)
        @pinMobileEvents()
    )

    f = @ns.gui.addFolder('Motion')
    f.add(@dat, 'stop').listen().onChange(
      => changeValue(false, false, false, true, false)
    )
    f.add(@dat, 'keepGoing').listen().onChange(
      =>
        @dat.keepGoing != @dat.keepGoing
        changeValue(@dat.orientation, @dat.rotationRate, @dat.acceleration, false, @dat.keepGoing)
    )
    f = @ns.gui.addFolder('Images type')
    f.add(@dat, 'nature').listen().onChange(=>@loadBitmaps())


  pinMobileEvents:=>
    window.removeEventListener("deviceorientation", @deviceOrientationListener, false)
    window.removeEventListener("devicemotion",      @deviceMotionListener,      false)
    if @dat.orientation
      unless window.DeviceOrientationEvent
        alert("DeviceOrientationEvent is not supported!")
      else
        window.addEventListener('deviceorientation', @deviceOrientationListener, false)

    if @dat.rotationRate or @dat.acceleration
      unless window.DeviceMotionEvent
        alert "DeviceMotionEvent is not supported!"
      else
        window.addEventListener('devicemotion', @deviceMotionListener, false)

  deviceOrientationListener: (event)=>
    if @dat.orientation
      alpha = (event.alpha - 180) / 180
      beta  = event.beta  / 180
      gamma = event.gamma / 90

      @statusNode.text("Alpha: #{alpha.toFixed(2)} Beta: #{beta.toFixed(2)} Gamma: #{gamma.toFixed(2)} Orientation: #{window.orientation}")
      @evalAnimationUpdate(alpha, beta, gamma)

  deviceMotionListener: (event)=>
    if @dat.rotationRate
      alpha = event.rotationRate.alpha
      beta  = event.rotationRate.beta
      gamma = event.rotationRate.gamma
      @statusNode.text("Alpha: #{alpha} Beta: #{beta} Gamma: #{gamma} Orientation: #{window.orientation}")
      @evalAnimationUpdate(alpha, beta, gamma)

    if @dat.acceleration
      x = event.acceleration.x
      y = event.acceleration.y
      z = event.acceleration.z
      @statusNode.text("X: #{x} Y: #{y} Z: #{z} Orientation: #{window.orientation}")
      @evalAnimationUpdate(x, y, z)


  evalAnimationUpdate: (alpha, beta, gamma)=>
    unless isNaN(alpha)
      @ns.cube.rotateX(alpha * Phoria.RADIANS)
      @pos.alpha = alpha
    unless isNaN(beta)
      @ns.cube.rotateY(beta  * Phoria.RADIANS)
      @pos.beta  = beta
    unless isNaN(gamma)
      @ns.cube.rotateZ(gamma * Phoria.RADIANS)
      @pos.gamma = gamma
