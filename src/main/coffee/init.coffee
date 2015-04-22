class _.Init

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
          phoriaAnimation = new _.animation.PhoriaAnimation()
          datGUI   = $(".dg.ac").addClass("opened")
      )

$( document ).ready(()=>
    init  = new _.Init()
)