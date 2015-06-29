AutoForm.addInputType 'fileUpload',
  template: 'afFileUpload'
  valueOut: ->
    @val()

getCollection = (context) ->
  if typeof context.atts.collection == 'string'
    context.atts.collection = FS._collections[context.atts.collection] or window[context.atts.collection]
  return context.atts.collection

getDocument = (context) ->
  collection = getCollection context
  id = Template.instance()?.value?.get?()
  collection?.findOne(id)

uploadImage = (collection, file, t) ->
  _URL = window.URL || window.webkitURL;
  img = new Image();
  img.onload = ->
    if this.width == 300 and this.height == 300
      collection.insert file, (err, fileObj) ->
        if err then return console.log err
        t.value.set fileObj._id
    else
      alert('Imagem deve ter dimensao: 300x300')
  img.src = _URL.createObjectURL(file)

Template.afFileUpload.onCreated ->
  @value = new ReactiveVar @data.value

Template.afFileUpload.onRendered ->
  self = @
  $(self.firstNode).closest('form').on 'reset', ->
    self.value.set null

Template.afFileUpload.helpers
  label: ->
    @atts.label or 'Choose file'
  removeLabel: ->
    @atts.removeLabel or 'Remove'
  value: ->
    doc = getDocument @
    doc?.isUploaded() and doc._id
  schemaKey: ->
    @atts['data-schema-key']
  previewTemplate: ->
    doc = getDocument @
    if doc?.isImage()
      'afFileUploadThumbImg'
    else
      'afFileUploadThumbIcon'
  file: ->
    getDocument @

Template.afFileUpload.events
  'click .js-select-file': (e, t) ->
    t.$('.js-file').click()

  'change .js-file': (e, t) ->
    files      = e.target.files
    collection = getCollection t.data
    if files[0].type.indexOf('image') != -1
      uploadImage collection, files[0], t
    else
      collection.insert files[0], (err, fileObj) ->
        if err then return console.log err
        t.value.set fileObj._id

  'click .js-remove': (e, t) ->
    e.preventDefault()
    t.value.set null

Template.afFileUploadThumbIcon.helpers
  icon: ->
    switch @extension()
      when 'pdf'
        'file-pdf-o'
      when 'doc', 'docx'
        'file-word-o'
      when 'ppt', 'avi', 'mov', 'mp4'
        'file-powerpoint-o'
      else
        'file-o'


