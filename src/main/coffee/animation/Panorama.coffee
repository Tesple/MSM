class _.animation.Panorama
  n: {}

  constructor: ->
    window.pano = @
    if $.browser.isMobile
      @prepareMobileVersion()
      @pinMobileEvents()
    else
      @prepareDesktopVersion()

  prepareMobileVersion: =>
    $("#move-up, #move-down, #move-left, #move-right").remove()
    _t = this
    @p = {
      doc:    $(document)
      viewer: $("#viewer")
      cube:   $("#cube")
    }
    @m = {
      moving:   false
      width:    @p.viewer.width()
      height:   @p.viewer.height()
      currentX: 0 #degrees
      currentY: 0 #degrees
      perspective: 450
    }


  prepareDesktopVersion: =>
    @enableDragHandler()
    @n.up     = $("#move-up")
    @n.down   = $("#move-down")
    @n.left   = $("#move-left")
    @n.right  = $("#move-right")

    @n.right.on("click",     => @movePano(5 , 0 ))
    @n.left.on("click",   => @movePano(-5, 0 ))
    @n.down.on("click",   => @movePano(0 , -5))
    @n.up.on("click",  => @movePano(0 , 5 ))


  movePano: (mv1, mv2)=>
    @m.currentX += mv2
    @m.currentY += mv1
    vendors = ['-webkit-', '-moz-', '']
    for v in vendors
      @p.cube.css(v + 'transform', 'rotateX(' + @m.currentX + 'deg) rotateY(' + @m.currentY + 'deg)')

  enableDragHandler: ->
    _t = this
    @p = {
      doc:    $(document)
      viewer: $("#viewer")
      cube:   $("#cube")
    }
    @m = {
      moving:   false
      width:    @p.viewer.width()
      height:   @p.viewer.height()
      currentX: 0 #degrees
      currentY: 0 #degrees
      perspective: 450
    }

    @p.doc.on('mouseup', (e)->
      e.preventDefault()
      _t.m.moving = false
    )

    @p.viewer.on('mousedown', (e)->
      e.preventDefault()
      _t.m.x1 = e.pageX - $(this).offset().left
      _t.m.y1 = e.pageY - $(this).offset().top
      _t.m.moving = true
    )

    @p.doc.on('mousemove', (e)->
      if _t.m.moving
        x2 = e.pageX - _t.p.viewer.offset().left
        y2 = e.pageY - _t.p.viewer.offset().top
        deg_x  =  Math.atan2(y2 - _t.m.y1, _t.m.perspective) / Math.PI * 180
        deg_y  = -Math.atan2(x2 - _t.m.x1, _t.m.perspective) / Math.PI * 180
        vendors = ['-webkit-', '-moz-', '']

        _t.m.currentX += deg_x
        _t.m.currentY += deg_y
        _t.m.currentX = Math.min(90, _t.m.currentX)
        _t.m.currentX = Math.max(-90, _t.m.currentX)

        _t.m.currentY %= 360

        for v in vendors
          _t.p.cube.css(v + 'transform', 'rotateX(' + _t.m.currentX + 'deg) rotateY(' + _t.m.currentY + 'deg)')


        _t.m.x1 = x2
        _t.m.y1 = y2

      e.preventDefault()
    )

  ###

  loadBitmaps:=>
    ext = if @dat.nature then ".jpg" else ".png"
    for i in [0...6]
       @ns.bitmaps.push(new Image())
       @ns.loader.addImage(@ns.bitmaps[i], 'images/texture' + i + ext )

    @ns.loader.onLoadCallback(@initPhoria)
  ###
  pinMobileEvents:=>
    window.removeEventListener( "devicemotion",  @deviceMotionListener, false)
    window.addEventListener(    "devicemotion",  @deviceMotionListener, false)

  deviceMotionListener: (event)=>
    @alreadyToasted = false
    x  = event.rotationRate.beta * 360
    y = event.rotationRate.gamma * 360

    unless x? and y?
      unless @alreadyToasted
        alert "Sorry, your device probably doesn't support deviceMotion"
        @alreadyToasted = true
      return
    @evalAnimationUpdate(x, y)

  evalAnimationUpdate: (mv1, mv2)=>
    alert ""+ mv1+ " " + mv2
    @m.currentX = mv2
    @m.currentY = mv1
    vendors = ['-webkit-', '-moz-', '']
    for v in vendors
      @p.cube.css(v + 'transform', 'rotateX(' + @m.currentX + 'deg) rotateY(' + @m.currentY + 'deg)')
