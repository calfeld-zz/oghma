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
    b_attrs: ( attrs, B ) ->
      attrs.width  = B[0]
      attrs.height = B[1]
  circle:
    create: -> new Kinetic.Circle()
    extra: ( attrs ) ->
      attrs.r = attrs.width / 2
    b_attrs: ( attrs, B ) ->
      r = Math.max( B[0], B[1] )

      attrs.width  = 2*r
      attrs.height = 2*r
      attrs.r      = r
  line:
    create: -> new Kinetic.Line(points: [ 0, 0, 0, 0 ])
    extra: ( attrs ) ->
      attrs.points = [ 0, 0, attrs.width, attrs.height ]
    b_attrs: ( attrs, B ) ->
      attrs.width  = B[0]
      attrs.height = B[1]
      attrs.points = [ 0, 0, B[0], B[1] ]

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
        x:       0
        y:       0
        fill:    fill
        stroke:  stroke
        opacity: opacity
        width:   width
        height:  height
      c_shapes[shape].extra?( attrs )
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

  for k, v of c_shapes
    do ( k, v ) ->
      calculate_attrs = ( attrs, B ) ->
        attrs =
          x:       0
          y:       0
          fill:    attrs.fill
          stroke:  attrs.stroke
          opacity: attrs.opacity
        v.b_attrs?( attrs, B )
        console.debug( attrs.width, attrs.height, B[0], B[1] )
        attrs

      create = ( name, group, attrs, A, B ) ->
        obj = v.create()
        group.add( obj )
        obj

      resize = ( obj, attrs, A, B ) ->
        obj.setAttrs( calculate_attrs( attrs, B ) )

      finish = ( name, attrs, A, B ) ->
        attrs = calculate_attrs( attrs, B )
        attrs.shape = k
        attrs.x = A[0]
        attrs.y = A[1]
        O.tableverse.create( 'shape', attrs )

      O.twopoint.define( k, create, resize, finish )
)
