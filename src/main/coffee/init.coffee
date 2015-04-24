class _.Init
  phoriaStarted: false

  constructor: ()->
      @plugNaviListeners()

  plugNaviListeners: =>
    elements = $("body > div")
    phoria   = $("#phoria")
    splash   = $("#splash")
    panorama = $("#panorama")
    datGUI   = $(".dg.ac")
    $("#open-phoria", elements).on("click",
      =>
        elements.removeClass("opened")
        phoria.addClass("opened")
        splash.addClass("hidden")
        unless @phoriaStarted
          phoriaAnimation = new _.animation.PhoriaAnimation()
          @phoriaStarted = true
        datGUI   = $(".dg.ac").addClass("opened")
    )
    $("#open-panorama", elements).on("click",
    =>
      elements.removeClass("opened")
      panorama.addClass("opened")
      splash.addClass("hidden")
      datGUI   = $(".dg.ac").removeClass("opened")
    )

    $("#go-back").on("click",
    =>
      elements.removeClass("opened")
      splash.removeClass("hidden")
    )

$( document ).ready(()=>
    init  = new _.Init()
)