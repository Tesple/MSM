class _.animation.Panorama

  x1: undefined
  y1: undefined
  moving: false
  $viewer:  $('#viewer')
  $cube:    $('#cube')
  w_v:      undefined
  h_v:      undefined
  c_x_deg:  0 # current x
  c_y_deg:  0
  perspective: 450 #// current y

  constructor: ->
    @w_v:      $viewer.width() # width of viewer
    @h_v:      $viewer.height() # height of viewer
    window.pano = @
    if $.browser.isMobile
      @prepareMobileVersion()
      #@pinMobileEvents()
    else
      @prepareMobileVersion()

      #@prepareDesktopVersion()
      #@pinDesktopEvents()

  prepareMobileVersion: =>
    $("#move-up, #move-down, #move-left, #move-right").remove()

  pinMobileEvents: =>
    $viewer.on('mousedown',(e)=>
      @x1 = e.pageX - $(this).offset().left
      @y1 = e.pageY - $(this).offset().top

      @moving = true
      e.preventDefault()
    )

    $(document).on('mousemove', (e)=>
      if moving is true
        @x2 = e.pageX - $viewer.offset().left
        @y2 = e.pageY - $viewer.offset().top

        @dist_x = @x2 - @x1
        @dist_y = @y2 - @y1
        @perc_x = @dist_x / @w_v
        @perc_y = @dist_y / @h_v
        @deg_x = Math.atan2(@dist_y, @perspective) / Math.PI * 180
        @deg_y = -Math.atan2(@dist_x, @perspective) / Math.PI * 180

        @c_x_deg += @deg_x
        @c_y_deg += @deg_y
        @c_x_deg = Math.min(90, @c_x_deg)
        @c_x_deg = Math.max(-90, @c_x_deg)

        @c_y_deg %= 360

        @deg_x = @c_x_deg
        @deg_y = @c_y_deg

        @x1 = @x2
        @y1 = @y2

        e.preventDefault()
    ).on('mouseup', (e)=>
      @moving = false
      e.preventDefault()
    )






  ###

  loadBitmaps:=>
    ext = if @dat.nature then ".jpg" else ".png"
    for i in [0...6]
       @ns.bitmaps.push(new Image())
       @ns.loader.addImage(@ns.bitmaps[i], 'images/texture' + i + ext )

    @ns.loader.onLoadCallback(@initPhoria)

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

###