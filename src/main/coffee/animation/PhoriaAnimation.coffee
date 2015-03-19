class _.animation.PhoriaAnimation
  # define namespace for animation
  ns: {}
  pos: {
    alpha: .4
    beta : .2
    gamma: .2
  }
  constructor: ->
    @statusNode = $("body #status")
    @setupNamespace()
    @loadBitmaps()

    if $.browser.isMobile
      @pinMobileEvents()
      setInterval(@pinMobileScreenResize, 20)
    else
      @pinGUIControls()
      $(window).on("resize",@pinScreenResize)
      @pinScreenResize()

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
     for i in [0...6]
       @ns.bitmaps.push(new Image())
       @ns.loader.addImage(@ns.bitmaps[i], 'images/texture'+i+'.png')

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
        @ns.cube.rotateX(@pos.alpha * Phoria.RADIANS)
        @ns.cube.rotateY(@pos.beta * Phoria.RADIANS)
        @ns.cube.rotateZ(@pos.gamma * Phoria.RADIANS)
        @ns.scene.modelView()
        @ns.renderer.render(@ns.scene)
      window.requestAnimFrame(fnAnimate)

    fnPositionLookAt = (forward, heading, lookAt)=>
      pos = vec3.fromValues(@ns.scene.camera.position.x, @ns.scene.camera.position.y, @ns.scene.camera.position.z)
      ca  = Math.cos(heading)
      sa = Math.sin(heading);
      rx = forward[0] * ca - forward[2] * sa
      rz = forward[0] * sa + forward[2] * ca
      forward[0] = rx
      forward[2] = rz
      vec3.add(pos, pos, forward)
      @ns.scene.camera.position.x = pos[0]
      @ns.scene.camera.position.y = pos[1]
      @ns.scene.camera.position.z = pos[2]

      rx = lookAt[0] * ca - lookAt[2] * sa
      rz = lookAt[0] * sa + lookAt[2] * ca
      vec3.add(pos, pos, vec3.fromValues(rx, lookAt[1], rz))

      @ns.scene.camera.lookat.x = pos[0]
      @ns.scene.camera.lookat.y = pos[1]
      @ns.scene.camera.lookat.z = pos[2]

    @ns.scene.perspective.fov = 12

    window.requestAnimFrame(fnAnimate)


  pinGUIControls: =>
    @ns.gui = new dat.GUI()
    f = @ns.gui.addFolder('Rotation speed')
    f.add(@pos, "alpha").min(-1).max(1).step(0.01)
    f.add(@pos, "beta").min(-1).max(1).step(0.01)
    f.add(@pos, "gamma").min(-1).max(1).step(0.01)

  pinMobileEvents:=>
    unless window.DeviceOrientationEvent?
      @statusNode.text("DeviceMotionEvent is not supported!")
    else
      @statusNode.text("DeviceMotionEvent SUPPORTED!")

      window.addEventListener('deviceorientation',
        ((event)=>
          alpha = (event.alpha - 180) / 180
          beta  = event.beta  / 180
          gamma = event.gamma / 90

          @statusNode.text("Alpha: #{alpha.toFixed(2)} Beta: #{beta.toFixed(2)} Gamma: #{gamma.toFixed(2)} Orientation: #{window.orientation}")
          @ns.cube.rotateZ(beta  * Phoria.RADIANS) unless isNaN(beta)
          @ns.cube.rotateX(alpha * Phoria.RADIANS) unless isNan(alpha)
          @ns.cube.rotateY(gamma * Phoria.RADIANS) unless isNaN(gamma)
        ), false
      )

  pinMobileScreenResize:=>
    height = screen.availHeight
    width  = screen.availWidth
    dimension = Math.min(width, height)
    dimension = dimension - 100

    $("body canvas").css(
      width: dimension,
      height: dimension
    )

  pinScreenResize:=>
    screen = $(window)
    height = screen.height()
    width  = screen.width()
    dimension = Math.min(width, height)
    dimension = dimension - 100

    $("body canvas").css(
      width: dimension,
      height: dimension
    )