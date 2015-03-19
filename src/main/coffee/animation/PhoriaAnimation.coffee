class _.animation.PhoriaAnimation
  # define namespace for animation
  ns: {}

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
        @ns.cube.rotateY(.4 * Phoria.RADIANS)
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
    f = @ns.gui.addFolder('Camera Up')
    f.add(@ns.scene.camera.up, "x")
    .min(-10)
    .max(10)
    .step(0.1)
    f.add(@ns.scene.camera.up, "y")
    .min(-10)
    .max(10)
    .step(0.1)
    f.add(@ns.scene.camera.up, "z")
    .min(-10)
    .max(10)
    .step(0.1)


  pinMobileEvents:=>
    unless window.DeviceOrientationEvent?
      @statusNode.text("DeviceOrientationEvent is not supported!")
    else
      @statusNode.text("DeviceOrientationEvent SUPPORTED!")
      lastEvent = Date.now()

      window.addEventListener('deviceorientation',
        ((eventData)=>
          if Date.now() - lastEvent > 100

            gamma = eventData.gamma

            if -60 < gamma < 0
              lastEvent = Date.now()
              beta = eventData.beta
              beta = if beta < -90 then -90 else if beta > 90 then 90 else beta
              beta = beta / 9
              sign = beta / Math.abs(beta)
              beta = sign * Math.floor(Math.abs(beta) * 10) / 10

              @ns.scene.camera.up.x = beta

              gammaPrim = (-30 - gamma) / 2.5
              @ns.scene.camera.position.y = gammaPrim

              @statusNode.text("#{window.orientation}") # 0, 90 or 180 [orientation portrait//landscape]





          # gamma is the left-to-right tilt in degrees, where right is positive
          tiltLR = eventData.alpha.toFixed(2)
          # beta is the front-to-back tilt in degrees, where front is positive
          tiltFB = eventData.beta.toFixed(2)
          # alpha is the compass direction the device is facing in degrees
          dir = eventData.gamma.toFixed(2)
          # call our orientation event handler

          #@statusNode.text(JSON.stringify(eventData))
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
    @statusNode.text("#{height} #{width}")

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
    @statusNode.text("#{height} #{width}")
