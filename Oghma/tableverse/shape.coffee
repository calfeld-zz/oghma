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
  circle:    true

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
    x:       Math.min( A[0], B[0] )
    y:       Math.min( A[1], B[1] )
    width:   Math.abs( B[0] - A[0] )
    height:  Math.abs( B[1] - A[1] )
    fill:    attrs.fill
    stroke:  attrs.stroke
    opacity: attrs.opacity

  rect_create = ( name, group, attrs, A, B ) ->
    rect = new Kinetic.Rect( rect_attrs( attrs, A, B ) )
    group.add( rect )
    rect

  rect_resize = ( rect, attrs, A, B ) ->
    console.debug( 'temp', rect_attrs( attrs, A, B ) )
    rect.setAttrs( rect_attrs( attrs, A, B ) )

  rect_finish = ( name, attrs, A, B ) ->
    attrs = rect_attrs( attrs, A, B )
    attrs.shape = 'rectangle'
    O.tableverse.create( 'shape', attrs )

  O.twopoint.define( 'rectangle', rect_create, rect_resize, rect_finish )
)
