class _.animation.OptionsController
  memesArr:    [
    'images/texture0.png',
    'images/texture1.png',
    'images/texture2.png',
    'images/texture3.png',
    'images/texture4.png',
    'images/texture5.png'
  ]
  natureArr:   [
    'images/texture0.jpg',
    'images/texture1.jpg',
    'images/texture2.jpg',
    'images/texture3.jpg',
    'images/texture4.jpg',
    'images/texture5.jpg'
  ]
  panoramaArr: [
    'images/panorama/top.jpg',
    'images/panorama/left.jpg',
    'images/panorama/front.jpg',
    'images/panorama/right.jpg',
    'images/panorama/back.jpg',
    'images/panorama/bottom.jpg'
  ]
  selectedFiles: []
  invoker:  null

  constructor: (ctx)->
    @invoker = ctx
    @modal    = $("#options-modal")
    @memes    = $("#select-memes", @modal)
    @nature   = $("#select-nature", @modal)
    @panorama = $("#select-panorama", @modal)
    @cancel   = $("#options-cancel", @modal)
    @confirm  = $("#options-confirm", @modal)
    @files    = $("input[type='file']", @modal)
    @files.on("change", => @handleFilesChange())
    @memes.on("click",    => @handleSelection(@memesArr))
    @nature.on("click",   => @handleSelection(@natureArr))
    @panorama.on("click", => @handleSelection(@panoramaArr))
    @confirm.on("click",    => @handleSelection(@selectedFiles))
    @cancel.on("click",@close)
    @

  handleFilesChange:=>
    selected = 0
    for file, idx in @files
      file = $(file)
      if file.context.files.length > 0
        selected++
        tmppath = URL.createObjectURL(file.context.files[0])
        @selectedFiles[idx] = tmppath
    if selected is 6
      @enableConfirm()

  enableConfirm: =>
    @confirm.css("display", "inline-block")

  disableConfirm: =>
    @confirm.css("display", "none")

  handleSelection: (selectedImages)=>
    @invoker.handleOptionsChange(selectedImages)
    @close()

  open: =>
    @disableConfirm()
    @handleFilesChange()
    @modal.css("z-index", 10)

  close: =>
    @modal.css("z-index", -10)
