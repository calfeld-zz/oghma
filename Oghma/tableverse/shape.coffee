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

c_layer = 'annotations'
c_shapes =
  rectangle:
    create: -> new Kinetic.Rect()
    extra:  -> { x:0, y:0 }
  circle:
    create: -> new Kinetic.Circle()
    extra:  ( thingy ) ->
      x: 0
      y: 0
      r: thingy.gets( 'width' ) / 2

Oghma.Thingy.Tableverse.register( ( thingyverse, O ) ->

  class ShapeDelegate extends Oghma.KineticThingyDelegate
    draw: ->
      shape = @thingy().gets( 'shape' )
      if ! c_shapes[shape]?
        throw "Unsupported shape: #{shape}"

      if ! @__k?
        @__k = c_shapes[shape].create()
        @group().add( @__k )

      [ fill, stroke, width, height, opacity ] =
        @thingy().geta( 'fill', 'stroke', 'width', 'height', 'opacity' )
      attrs =
        fill:    fill
        stroke:  stroke
        opacity: opacity
        width:   width
        height:  height
      for k, v of c_shapes[shape].extra( @thingy() )
        attrs[k] = v
      @__k.setAttrs( attrs )

    remove: ( thingy ) ->
      thingyverse.dice.remove( thingy )
      super thingy

  thingyverse.shapes = new Heron.Index.MapIndex( 'owner' )

  thingyverse.define(
    'shape',
    [
      'owner',
      'shape',
      'fill', 'stroke', 'opacity'
    ],
    {
      loc:    [ 'x', 'y', 'width', 'height' ]
      status: [ 'locked', 'visible_to', 'zindex' ]
    },
    ( attrs ) ->
      console.debug( 'attrs', attrs.opacity )
      attrs.shape   ?= 'rectangle'
      attrs.fill    ?= O.me().gets( 'primary' )
      attrs.stroke  ?= O.me().gets( 'secondary' )
      attrs.width   ?= 20
      attrs.height  ?= 20
      attrs.opacity ?= 1.0

      @after_construction( =>
        thingyverse.shapes.add( this )
      )

      new ShapeDelegate(
        O, this, O.layer[ c_layer ], O.zindex[ c_layer ],
        [ 'shape', 'fill', 'stroke' ],
        attrs
      )
  )

  rect_attrs = ( attrs, A, B ) ->
    x:       0
    y:       0
    width:   B[0]
    height:  B[1]
    fill:    attrs.fill
    stroke:  attrs.stroke
    opacity: attrs.opacity

  rect_create = ( name, group, attrs, A, B ) ->
    rect = new Kinetic.Rect( rect_attrs( attrs, A, B ) )
    group.add( rect )
    rect

  rect_resize = ( rect, attrs, A, B ) ->
    rect.setAttrs( rect_attrs( attrs, A, B ) )

  rect_finish = ( name, attrs, A, B ) ->
    attrs = rect_attrs( attrs, A, B )
    attrs.shape = 'rectangle'
    attrs.x = A[0]
    attrs.y = A[1]
    O.tableverse.create( 'shape', attrs )

  O.twopoint.define( 'rectangle', rect_create, rect_resize, rect_finish )

  circle_attrs = ( attrs, A, B ) ->
    r = Math.max( B[0], B[1] )

    x:       0
    y:       0
    width:   2*r
    height:  2*r
    r:       r
    fill:    attrs.fill
    stroke:  attrs.stroke
    opacity: attrs.opacity

  circle_create = ( name, group, attrs, A, B ) ->
    circle = new Kinetic.Circle( circle_attrs( attrs, A, B ) )
    group.add( circle )
    circle

  circle_resize = ( circle, attrs, A, B ) ->
    circle.setAttrs( circle_attrs( attrs, A, B ) )

  circle_finish = ( name, attrs, A, B ) ->
    attrs = circle_attrs( attrs, A, B )
    attrs.shape = 'circle'
    attrs.x = A[0]
    attrs.y = A[1]
    O.tableverse.create( 'shape', attrs )

  O.twopoint.define( 'circle', circle_create, circle_resize, circle_finish )
)
