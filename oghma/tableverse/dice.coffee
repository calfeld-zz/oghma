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
Oghma.Thingy ?= {}

# Layer for dice.
c_layer = 'dice'

Oghma.Thingy.Tableverse.register( ( thingyverse, O ) ->
  thingyverse.dice = new Heron.Index.MapIndex( 'owner' )

  thingyverse.define(
    'dice',
    [
      'sides', 'value',
      'fill', 'stroke',
      'font_size',
      'x', 'y', 'r',
      'owner',
      'visible_to'
    ],
    {},
    ( attrs ) ->
      @__ =
        x:          attrs.x          ? 0
        y:          attrs.y          ? 0
        sides:      attrs.sides      ? 10
        value:      attrs.value
        fill:       attrs.fill       ? O.me().gets( 'primary' )
        stroke:     attrs.stroke     ? O.me().gets( 'secondary' )
        font_size:  attrs.font_size  ? 24
        r:          attrs.r          ? 25
        owner:      attrs.owner      ? O.me().gets( 'name' )
        visible_to: attrs.visible_to ? []

      @__.value ?= Heron.Util.rand( @__.sides ) + 1

      @after_construction( ->
        thingyverse.dice.add( this )
      )

      is_visible = =>
        @__.visible_to.length == 0 ||
        @__.visible_to.indexOf( O.me().gets( 'name' ) ) != -1

      if is_visible
        @__k =
          polygon: new Kinetic.RegularPolygon(
            sides:  @__.sides
            radius: @__.r
            x:      @__.x
            y:      @__.y
            fill:   @__.fill
            stroke: @__.stroke
          )
          text: new Kinetic.Text(
            text:     @__.value + ''
            x:        @__.x
            y:        @__.y
            fill:     @__.stroke
            stroke:   null
            fontSize: @__.font_size
          )

        # Center text
        @__k.text.setOffset(
          x: @__k.text.getWidth()  / 2
          y: @__k.text.getHeight() / 2
        )

        layer = O.layer[ c_layer ]
        layer.add( @__k.polygon )
        layer.add( @__k.text )
        layer.draw()

        for name, k of @__k
          k.on( 'click', ( event )=>
            if O.i_own( this ) || event.shiftKey
              @remove()
          )

        O.console.message( O.me().gets( 'name' ), "d#{@__.sides} = #{@__.value}" )

      set: (thingy, attrs) ->
        throw "Can't modify dice."

        null

      get: ( thingy, keys... ) ->
        thingy.__

      remove: ( thingy ) ->
        thingyverse.dice.remove( thingy )
        for name, k of thingy.__k
          k.destroy()
        O.layer[ c_layer ].draw()
        null
  )
)
