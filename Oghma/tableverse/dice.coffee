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

# Layer for dice.
c_layer = 'dice'

Oghma.Thingy.Tableverse.register( ( thingyverse, O ) ->
  thingyverse.dice = new Heron.Index.MapIndex( 'owner' )

  class DiceDelegate extends Oghma.KineticThingyDelegate
    draw: ->
      if ! @__k?
        @__k =
          polygon: new Kinetic.RegularPolygon({})
          text:    new Kinetic.Text({})
        @group().add( @__k.polygon )
        @group().add( @__k.text )

      attrs = @thingy().get()
      @__k.polygon.setAttrs(
        sides:  attrs.sides
        radius: attrs.r
        x:      -attrs.r / 2
        y:      -attrs.r / 2
        fill:   attrs.fill
        stroke: attrs.stroke
      )
      @__k.text.setAttrs(
        text:     attrs.value + ''
        x:        -attrs.r / 2
        y:        -attrs.r / 2
        fill:     attrs.stroke
        stroke:   null
        fontSize: attrs.font_size
      )

      # Center text
      @__k.text.setOffset(
        x: @__k.text.getWidth()  / 2
        y: @__k.text.getHeight() / 2
      )

    remove: ( thingy ) ->
      thingyverse.dice.remove( thingy )
      super thingy

    is_dragable: ( event ) ->
      if event.evt.ctrlKey
        @thingy().remove()
        false
      else
        super event

    is_grid_controlled: -> false

  thingyverse.define(
     'dice',
    [
      'owner',
      'sides', 'value',
      'fill', 'stroke',
      'font_size',
      'r'
    ],
    {
      loc:    [ 'x', 'y' ]
      status: [ 'locked', 'visible_to', 'zindex' ]
    },
    ( attrs ) ->
      attrs.x          ?= 0
      attrs.y          ?= 0
      attrs.sides      ?= 10
      attrs.fill       ?= O.me().gets( 'primary' )
      attrs.stroke     ?= O.me().gets( 'secondary' )
      attrs.font_size  ?= 24
      attrs.r          ?= 25
      attrs.owner      ?= O.me().gets( 'name' )
      attrs.visible_to ?= []
      attrs.value      ?= Heron.Util.rand( attrs.sides ) + 1

      @after_construction( ->
        thingyverse.dice.add( this )
      )

      # Don't emit messages for dice created during sync process.
      if thingyverse.synced()
        @after_construction( =>
          vis = @visibility()
          if vis != 'none'
            msg = "d#{attrs.sides} = #{attrs.value}"
            if vis != 'public'
              msg += " [#{@gets('visible_to').join(', ')}]"
            O.console.message( O.me().gets( 'name' ), msg )
        )

      new DiceDelegate(
        O, this, O.layer[ c_layer ], O.zindex[ c_layer ],
        [ 'sides', 'value', 'fill', 'stroke', 'font_size', 'r' ],
        attrs
      )
  )
)
