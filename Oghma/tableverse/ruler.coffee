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
Oghma.Thingy ?= {}

V = Heron.Vector

c_layer = 'annotations'
c_offset = 2
c_font_size = 10

label_location = ( B ) ->
  b = V.vec2( B... )

  midpoint = V.dup2( b )
  V.scale2( midpoint, 1 / 2 )

  if b[0] == 0 && b[1] == 0
    normal = V.vec2( 1 , 0 )
  else
    normal = V.dup2( b )
  V.normal2( normal )
  if normal[1] < 0
    V.scale2( normal, -1 )
  V.scale2( normal, c_offset / V.length2( normal ) )
  V.add2( midpoint, normal )
  midpoint

label_rotation = ( B ) ->
  b = V.vec2( B... )

  if b[0] == 0 and b[1] == 0
    return 0

  phi = V.angle2( b )
  if phi >= Math.PI / 2 and phi <= 3*Math.PI / 2
    phi += Math.PI
  else
    phi

Oghma.Thingy.Tableverse.register( ( thingyverse, O ) ->

  class RulerDelegate extends Oghma.KineticThingyDelegate
    draw: ->
      attrs = @thingy().get()
      if ! @__k?
        @__k = O.twopoint.create( 'ruler', @group(), attrs )
      O.twopoint.update( 'ruler', @__k, attrs )

    remove: ( thingy ) ->
      thingyverse.rulers.remove( thingy )
      super thingy

  thingyverse.rulers = new Heron.Index.MapIndex( 'owner' )

  thingyverse.define(
    'ruler',
    [
      'owner',
      'stroke', 'opacity'
    ],
    {
      loc:    [ 'x', 'y', 'width', 'height' ]
      status: [ 'locked', 'visible_to', 'zindex' ]
    },
    ( attrs ) ->
      attrs.stroke  ?= O.me().gets( 'primary' )
      attrs.width   ?= 0
      attrs.height  ?= 0
      attrs.opacity ?= 1.0

      @after_construction( =>
        thingyverse.rulers.add( this )
      )

      new RulerDelegate(
        O, this, O.layer[ c_layer ], O.zindex[ c_layer ],
        [ 'stroke' ],
        attrs
      )
  )

  calculate_line_attrs = ( attrs, B ) ->
    B ?= [ attrs.width, attrs.height ]

    x:           0
    y:           0
    stroke:      attrs.stroke  ? O.me().gets( 'primary' )
    strokeWidth: 1
    opacity:     attrs.opacity ? 1
    points:      [ 0, 0, B[0], B[1] ]

  calculate_label_attrs = ( attrs, B ) ->
    B ?= [ attrs.width, attrs.height ]
    loc = label_location( B )
    rotation = label_rotation( B ) * 180 / Math.PI
    if rotation == 360
      rotation = 0
    dist = Math.sqrt( B[0]*B[0] + B[1]*B[1] ) / O.grid.grid()

    x:        loc[0]
    y:        loc[1]
    text:     '' + dist.toFixed( 1 )
    fontSize: c_font_size
    fill:     O.ui_colors.value().primary
    rotation: rotation


  create = ( name, group, attrs, A, B ) ->
    objs =
      line:  new Kinetic.Line(points: [ 0, 0, 0, 0 ])
      label: new Kinetic.Text({})
    group.add( objs.line )
    group.add( objs.label )
    objs

  update = ( objs, attrs, A, B ) ->
    objs.line.setAttrs(  calculate_line_attrs(  attrs, B ) )
    objs.label.setAttrs( calculate_label_attrs( attrs, B ) )

  finish = ( name, attrs, A, B ) ->
    attrs = 
      x:       A[0]
      y:       A[1]
      width:   B[0]
      height:  B[1]
      stroke:  attrs.stroke
      opacity: attrs.opacity
    attrs
    
  O.twopoint.define( 'ruler', create, update, finish )

  O.ui_colors.on_set( ->
    O.tableverse.rulers.each( ( ruler ) ->
      ruler.redraw()
    )
  )
)
