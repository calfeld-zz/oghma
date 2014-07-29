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

# Control for modifying grid.
#
# This class draws a 3x3 grid with draggable intersections.  When the grid is
# changed by dragging those intersections, a user provided function is called
# with the new grid and origin.
#
# @author Christopher Alfeld (calfeld@calfeld.net)
# @copyright 2014 Christopher Alfeld
class Oghma.GridControls
  # Construct new GridControls and draw.
  #
  # @param config [Object] Configuration.
  # @option config [Kinetic.Layer] layer Layer to draw to.  Required.
  # @option config [FixNum] grid Current grid size.  Required.
  # @option config [Array<Float, Float>] origin Current origin.  Required.
  # @option config [Function] Function to call with origin and grid on change.
  # @option config [String] color Color of controls.
  # @option config [String] origin_color Color of origin control.
  constructor: ( config = {} ) ->
    @_ =
      layer:        config.layer        ? throw 'Missing layer.'
      grid:         config.grid         ? throw 'Missing grid.'
      origin:       config.origin       ? throw 'Missing origin.'
      on_change:    config.on_change    ? ->
      color:        config.color        ? 'blue'
      origin_color: config.origin_color ? 'green'

    @_.g2k = ( pt ) =>
      [ pt[0] * @_.grid + @_.origin[0], pt[1] * @_.grid + @_.origin[1] ]

    @_.k =
      # Example Grid
      v1: new Kinetic.Line({})
      v2: new Kinetic.Line({})
      h1: new Kinetic.Line({})
      h2: new Kinetic.Line({})

      # Control Circles
      origin: new Kinetic.Circle({})
      up:     new Kinetic.Circle({})
      right:  new Kinetic.Circle({})
      both:   new Kinetic.Circle({})

    setup_drag = ( control, opposite_control, sx, sy, dx, dy ) =>
      @_.k[control].on( 'dragmove', ( event ) =>
        pos = @_.k[control].getPosition()
        if event.evt.shiftKey
          opposite = @_.k[opposite_control].getPosition()
          dx = Math.abs( pos.x - opposite.x )
          dy = Math.abs( pos.y - opposite.y )
          @_.grid = Math.max( dx, dy )
          @_.origin = [ opposite.x + sx * @_.grid, opposite.y + sy * @_.grid ]
        else
          @_.origin = [ pos.x + dx * @_.grid, pos.y + dy * @_.grid]
        @redraw()
      )
      @_.k[control].on( 'dragend',  =>
        @_.on_change( @_.origin, @_.grid )
      )

    setup_drag( 'origin', 'both',   -1,  1,  0, 0 )
    setup_drag( 'both',   'origin',  0,  0, -1, 1 )
    setup_drag( 'up',     'right',  -1,  0,  0, 1 )
    setup_drag( 'right',  'up',      0 , 1, -1, 0 )

    @_.group = new Kinetic.Group()
    for _, v of @_.k
      @_.group.add( v )

    @_.layer.add( @_.group )

    @redraw()

  # Redraw controls.
  #
  # It should not be necessary to call this directly.
  # @return [Oghma.GridControls] this
  redraw: ->
    line = ( src, dst ) =>
      points: [ @_.g2k( src )..., @_.g2k( dst )... ]
    vline = ( x ) ->
      line( [ x, -2 ], [ x, 1 ] )
    hline = ( y ) ->
      line( [ -1, y ], [ 2, y ] )
    common =
      stroke: @_.color
      strokeWidth: 1

    @_.k.v1.setAttrs( Heron.Util.extend( vline( 0  ), common ) )
    @_.k.v2.setAttrs( Heron.Util.extend( vline( 1  ), common ) )
    @_.k.h1.setAttrs( Heron.Util.extend( hline( 0  ), common ) )
    @_.k.h2.setAttrs( Heron.Util.extend( hline( -1 ), common ) )

    common =
      stroke: @_.color
      radius: 5
      draggable: true

    circle = ( x, y ) =>
      gpt = @_.g2k( [x, y] )
      { x: gpt[0], y: gpt[1] }

    origin_attrs = Heron.Util.extend( circle( 0, 0  ), common )
    origin_attrs.stroke = @_.origin_color
    @_.k.origin.setAttrs( origin_attrs )
    @_.k.up.setAttrs(     Heron.Util.extend( circle( 0, -1 ), common ) )
    @_.k.right.setAttrs(  Heron.Util.extend( circle( 1, 0  ), common ) )
    @_.k.both.setAttrs(   Heron.Util.extend( circle( 1, -1 ), common ) )

    @_.layer.draw()

    this

  # Change the color and origin_color.
  #
  # Automatically redraws group.
  #
  # @param [String] color Color for lines and controls.
  # @param [String] origin_color Color for origin control.
  # @return [Oghma.GridControls] this
  set_color: ( color, origin_color = color ) ->
    @_.color = color
    @_.origin_color = origin_color
    @_.group.draw()
    this

  # Destroy graphics and redraw layer.
  #
  # @return [Oghma.GridControls] this
  destroy: ->
    @_.group.destroy()
    @_.layer.draw()
    this
