class _.Init

    constructor: ()->
        @plugNaviListeners()

    plugNaviListeners: =>
      elements = $("body > div")
      phoria   = $("#phoria")
      splash   = $("#splash")
      panorama = $("#panorama")
      $("#open-phoria", elements).on("click",
        =>
          elements.removeClass("opened")
          phoria.addClass("opened")
          phoriaAnimation = new _.animation.PhoriaAnimation()
      )

$( document ).ready(()=>
    init  = new _.Init()
)