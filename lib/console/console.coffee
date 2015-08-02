# TODO: more generic commands
# TODO: buffering
# TODO: autocomplete
# TODO: refactor into a class

{Emitter} = require 'atom'
ConsoleView = require './view'

module.exports =
  activate: ->
    # TODO: eval only in last editor
    @evalCmd = atom.commands.add '.console atom-text-editor',
      'console:evaluate': (e) -> e.currentTarget.getModel().inkEval()

    @clearCmd = atom.commands.add '.console',
      'console:clear': (e) -> atom.workspace.getActivePaneItem().getModel().clear()

  deactivate: ->
    @openCmd.dispose()
    @clearCmd.dispose()

  create: ->
    c = @basic()
    c.view.getModel = -> c
    c

  basic: ->
    view: new ConsoleView

    isInput: false

    setGrammar: (g) ->
      @view.setGrammar g

    input: ->
      v = @view.inputView this
      @view.add v
      @isInput = true

    done: -> @isInput = false

    out: (s) -> @view.add @view.outView(s), @isInput

    err: (s) -> @view.add @view.errView(s), @isInput

    info: (s) -> @view.add @view.infoView(s), @isInput

    clear: ->
      @done()
      @view.clear()

    reset: ->
      focus = @view.hasFocus()
      @clear()
      @input()
      @view.focusInput focus

    emitter: new Emitter

    onEval: (f) -> @emitter.on 'eval', f

    openInTab: ->
      p = atom.workspace.getActivePane()
      if p.items.length > 0
        p = p.splitDown()
        p.setFlexScale 1/2
      p.activateItem @view
      @view.focusInput true

    toggle: ->
      if atom.workspace.getPaneItems().indexOf(@view) > -1
        @view[0].parentElement.parentElement.getModel().removeItem @view
      else
        @openInTab()
        @view.focusInput()
