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

# KineticPanel representing an "infinite" kinetic stage.
#
# At all times maintains an internal size of three times the window.
# Any scrolling will change the canvas offset and recenter the scroll.
#
# @author Christopher Alfeld (calfeld@calfeld.net)
# @copyright 2013 Christopher Alfeld
Ext.define( 'Oghma.Ext.InfiniteKineticPanel',
  extend: 'Oghma.Ext.KineticPanel'

  # How big the stage should be in terms of window.
  stageSizeMultiplier: 3

  # How many ms after scrolling ends to recenter.
  recenterDelay: 500

  # Called when zoom level changes with zoom level.
  onZoom: jQuery.Callbacks()

  # See ExtJS.
  initComponent: ->
    Ext.apply( this,
      autoScroll:      true
      autoResizeStage: false
    )
    recenter = =>
      clearTimeout( @_timeout ) if @_timeout?
      @setCenter( @getCenter()... )

    @on( 'boxready', ( it, width, height ) =>
      @on( 'resize', ( it, width, height ) =>
        @stage.setSize(
          width: width  * @stageSizeMultiplier
          height: height * @stageSizeMultiplier
        )
        recenter()
      )
      @body.on( 'scroll', =>
        if @_scrollProtect
          @_scrollProtect = false
          return
        clearTimeout( @_timeout ) if @_timeout?
        scroll = @body.getScroll()
        size = @getSize()
        if scroll.left <= 0 || scroll.top <= 0 || scroll.left + size.width >= size.width * 3 || scroll.top + size.height >= size.height * 3
          recenter()
        else
          @_timeout = setTimeout( recenter, @recenterDelay )
      )
    )
    @callParent( arguments )

    null

  # See KineticPanel#initStage
  initStage: ( width, height )->
    @callParent( [ width * @stageSizeMultiplier, height * @stageSizeMultiplier ] )
    return_to_origin = => @setCenter( 0, 0 )
    setTimeout( return_to_origin, 0 )

  # Centers the stage on the specified coordinate.
  #
  # @param [float] x Stage x coordinate to center on.
  # @param [float] y Stage y coordinate to center on.
  # @return [Oghma.Ext.InfiniteKineticPanel] this
  setCenter: ( x, y ) ->
    scale = @stage.getScale()
    size = @getSize()
    stage_width = @stageSizeMultiplier * size.width
    stage_height = @stageSizeMultiplier * size.height
    @stage.setOffset(
      x: x - ( stage_width  / 2 ) / scale.x
      y: y - ( stage_height / 2 ) / scale.y
    )
    @stage.draw()

    @_scrollProtect = true
    @scrollBy( -stage_width, -stage_height )
    @scrollBy(
      stage_width / 2  - size.width  / 2,
      stage_height / 2 - size.height / 2
    )

    this

  # Get center of view in screen coordinates.
  #
  # @return [float, float] x, y in screen coordinates.
  getScreenCenter: ->
    scroll = @body.getScroll()
    size = @getSize()
    stage_width = @stageSizeMultiplier * size.width
    stage_height = @stageSizeMultiplier * size.height

    [
      scroll.left + size.width / 2,
      scroll.top + size.height / 2
    ]

  # Get center of view in stage coordinates.
  #
  # @return [float, float] x, y in stage coordinates.
  getCenter: ->
    center = @getScreenCenter()
    scale = @stage.getScale()
    offset = @stage.getOffset()

    [
      center[0] / scale.x + offset.x,
      center[1] / scale.y + offset.y
    ]

  # Set zoom level.
  #
  # @param [Float] zoom Zoom level.
  # @return [Oghma.Ext.InfiniteKineticPanel] this
  setZoom: ( zoom ) ->
    center = @getCenter()
    @stage.setScale( x: zoom, y: zoom )
    @setCenter( center... )
    @onZoom.fire( zoom )

  # Get zoom level.
  #
  # @return [Float] Current zoom level.
  getZoom: ->
    @stage.getScale().x

  # Translate a point from screen coordinates to stage coordinates.
  #
  # @param [Array<Float, Float>] pt Location in screen coordinates.
  # @return [Array<Float, Float>] Location in stage coordinates.
  t: ( pt ) ->
    offset = @stage.getOffset()
    ex = @getEl().getX()
    ey = @getEl().getY()
    z = @getZoom()
    scroll = @body.getScroll()
    [
      ( pt[0] + scroll.left - ex ) / z + offset.x,
      ( pt[1] + scroll.top  - ey ) / z + offset.y
    ]

  # Convert client X to table X:
  tX: ( x ) ->
    @t( [ x, 0 ] )[0]

  # Convert client X to table X:
  tY: ( y ) ->
    @t( [ 0, y ] )[1]

  # Mouse position in table coordinates.
  mouse: ->
    pos = @stage.getPointerPosition()
    if pos?
      z = @getZoom()
      offset = @stage.getOffset()
      [ ( pos.x / z + offset.x ), ( pos.y / z + offset.y ) ]
    else
      [ null, null ]

)
