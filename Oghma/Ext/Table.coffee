# Copyright 2010-2014 Christopher Alfeld
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

Oghma = @Oghma ?= {}

# A tabletop to place things on.
#
# @author Christopher Alfeld (calfeld@calfeld.net)
# @copyright 2013 Christopher Alfeld
Ext.define( 'Oghma.Ext.Table',
  extend: 'Oghma.Ext.InfiniteKineticPanel'

  # Zoom levels.
  zoomLevels: [ 0.25, 0.5, 0.75, 1, 1.5, 2, 3 ]

  # Default zoom level.
  defaultZoom: 1

  # Dropper
  #
  # Funcion to apply on next click to stage.
  dropper: null

  # The underlying keymap for keyboard bindings.  Use {#addBinding} instead.
  keymap: null

  # See ExtJS.
  initComponent: ->
    @callParent( arguments )

    @on( 'afterrender', =>
      @getEl().on( 'click', ( e ) =>
        O.reset_focus()
        @apply_dropper( @t( [ e.getX(), e.getY() ] )..., e )
        null
      )
    )

    @keymap = Ext.create( 'Ext.util.KeyMap', target: Ext.getDoc() )

    null

  # Load a function into the dropper.
  #
  # @param [function(x, y, event)] Event to load.
  # @return [Oghma.App] this
  load_dropper: ( f ) ->
    @dropper = f
    document.body.style.cursor = 'crosshair'
    this

  # Unload the dropper.
  #
  # @return [Oghma.App] this
  unload_dropper: ->
    @dropper = null
    document.body.style.cursor = 'default'
    this

  # Apply the dropper.
  #
  # @param [numeric] x X stage location.
  # @param [numeric] y Y stage location.
  # @param [Object] e Event
  # @return [Oghma.App] this
  apply_dropper: ( x, y, e = null ) ->
    @dropper?( x, y, e )
    if ! e? || ! e.altKey
      @unload_dropper()
    this

  # Add a binding.
  #
  # This method is similar to Ext.util.KeyMap#addBinding but executes if the
  # key is pressed anywhere with the body as focus.  The handler will be
  # passed the mouse x and y location in tabletop coordinates, followed by the
  # usual handler arguments.
  #
  # @param [Object] binding Binding to add.
  # @option binding [String/Array] key Keycode or array of keycodes to bind.
  # @option binding [Boolean] shift True if shift is required.
  # @option binding [Boolean] ctrl  True if ctrl is required.
  # @option binding [Boolean] alt   True if alt is required.
  # @option binding [Function] handler Function call if key is pressed.
  # @option binding [Object] scope Scope of `handler`.
  # @option binding [String] defaultEventAction Default action to apply.  See
  #   ExtJS documentation for options and discussion.
  # @return [Oghma.Ext.Table] this
  addBinding: ( binding ) ->
    binding = Ext.clone( binding )
    if binding.fn
      binding.handler = binding.fn
      delete binding.fn
    bound_handler = binding.handler
    binding.handler = ( args... ) =>
      active = Ext.get( Ext.Element.getActiveElement() )
      if active == Ext.getBody() || ! active.isVisible()
        pass = [ @mouse()..., args... ]
        bound_handler.apply( binding.scope, pass )
    @keymap.addBinding( binding )
    this

  # Synonym for `addBinding( key: key, handler: handler)`
  onKey: ( key, handler ) ->
    @addBinding( key: key, handler: handler )

  # Add multiple bindings.
  #
  # @param [Object] ons Map of key code to handler.
  # @return [Oghma.Ext.Table] this
  onKeys: ( ons ) ->
    for key, handler of ons
      @onKey( key, handler )

  # Increase zoom level.
  #
  # If current zoom level is not in zoomLevels, sets to default.
  # If already at highest zoom level, does nothing.
  # @return [Oghma.Ext.Table] this
  increaseZoom: ->
    zoom = @getZoom()
    i = @zoomLevels.indexOf( zoom )
    if i == -1
      @setZoom( @defaultZoom )
    else if @zoomLevels[ i + 1 ]?
      @setZoom( @zoomLevels[ i + 1 ] )
    this

  # Decrease zoom level.
  #
  # If current zoom level is not in zoomLevels, sets to default.
  # If already at lowest zoom level, does nothing.
  # @return [Oghma.Ext.Table] this
  decreaseZoom: ->
    zoom = @getZoom()
    i = @zoomLevels.indexOf( zoom )
    if i == -1
      @setZoom( @defaultZoom )
    else if @zoomLevels[ i - 1 ]?
      @setZoom( @zoomLevels[ i - 1 ] )
    this
)
