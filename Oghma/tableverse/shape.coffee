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

Oghma.Thingy.Tableverse.register( ( thingyverse, O ) ->

  class ShapeDelegate extends Oghma.KineticThingyDelegate
    draw: ->
      if @thingy().gets( 'shape' ) != 'rectangle'
        throw "Unsupported shape: #{shape}"

      if ! @__k?
        @__k = new Kinetic.Rect()
        @group().add( @__k )

      [ fill, stroke, width, height ] =
        @thingy().geta( 'fill', 'stroke', 'width', 'height' )
      @__k.setAttrs(
        fill:   fill
        stroke: stroke
        width:  width
        height: height
        x:      -width / 2
        y:      -height / 2
      )

    remove: ( thingy ) ->
      thingyverse.dice.remove( thingy )
      super thingy

  thingyverse.shapes = new Heron.Index.MapIndex( 'owner' )

  thingyverse.define(
    'shape',
    [
      'owner',
      'shape',
      'fill', 'stroke'
    ],
    {
      loc:    [ 'x', 'y', 'width', 'height' ]
      status: [ 'locked', 'visible_to', 'zindex' ]
    },
    ( attrs ) ->
      attrs.shape  ?= 'rectangle'
      attrs.fill   ?= O.me().gets( 'primary' )
      attrs.stroke ?= O.me().gets( 'secondary' )
      attrs.width  ?= 20
      attrs.height ?= 20

      @after_construction( =>
        thingyverse.shapes.add( this )
      )

      new ShapeDelegate(
        O, this, O.layer[ c_layer ], O.zindex[ c_layer ],
        [ 'shape', 'fill', 'stroke' ],
        attrs
      )
  )
)
