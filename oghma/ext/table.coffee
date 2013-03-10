# Copyright 2010-2013 Christopher Alfeld
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
  extend: 'Oghma.Ext.KineticPanel'

  # Dropper
  #
  # Funcion to apply on next click to stage.
  dropper: null

  # See ExtJS.
  initComponent: ->

    @callParent( arguments )

    @on( 'afterrender', =>
      @getEl().on( 'click', ( e ) =>
        @apply_dropper( @tX( e.getX() ), @tY( e.getY() ), e )
        null
      )
    )

    null

  # Convert client X to table X:
  tX: ( x ) ->
    x - @getEl().getX()

  # Convert client X to table X:
  tY: ( y ) ->
    y - @getEl().getY()

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
    @unload_dropper()
    this
)
