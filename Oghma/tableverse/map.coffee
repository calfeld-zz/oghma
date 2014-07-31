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

c_layer = 'maps'
c_base_path = '/resources/maps/'

Oghma.Thingy.Tableverse.register( ( thingyverse, O ) -> 
  thingyverse.map = new Heron.Index.MapIndex( 'owner', 'name' )

  class MapDelegate extends Oghma.KineticThingyDelegate
    draw: ->
      if ! @__k
        @__k = 
          image: new Kinetic.Image({})
          label: new Kinetic.Text({})
        @group().add( @__k.image )
        @group().add( @__k.label )

      attrs = @thingy().get()
      
      set_image_attrs = =>
        @__k.image.setAttrs( image: @__image )

      if ! @__image?
        @__image = new Image()
        @__image.onload = =>
          set_image_attrs()
          @draw_layer()
        @__image.src = c_base_path + attrs.image
      if @__image.complete
        set_image_attrs()

      @__k.label.setAttrs(
        text:     attrs.name + ''
        fill:     O.ui_colors.value().primary
        stroke:   O.ui_colors.value().primary
        fontSize: 16
      )
      @__k.label.setOffset(
        x: @__k.label.getWidth() / 2
      )

    remove: ( thingy ) ->
      thingyverse.map.remove( thingy )
      super thingy

    context_menu_items: ->
      map = @thingy()
      [
        {
          text: 'Visible'
          checked: map.is_public()
          handler: ->
            if ! @checked
              map.set( visible_to: [ O.me().gets( 'name' ) ] )
            else
              map.set( visible_to: [] )
        },
        {
          text: 'Make other maps private'
          handler: =>
            this_map = @thingy().id()
            my_name = O.me().gets( 'name' )
            thingyverse.map.each( ( map ) ->
              if map.id() != this_map
                map.set( visible_to: [ my_name ] )
            )
        },
        '-'
      ].concat( super )

  thingyverse.define(
    'map',
    [ 'name', 'owner', 'image' ],
    {
      loc: [ 'x', 'y' ],
      status: [ 'locked', 'visible_to', 'zindex' ] 
    },
    ( attrs ) ->
      attrs.x          ?= 0
      attrs.y          ?= 0
      attrs.visible_to ?= []
      attrs.owner      ?= O.me().gets( 'name' )

      @after_construction( ->
        thingyverse.map.add( this )
      )

      new MapDelegate(
        O, this, O.layer[ c_layer ], O.zindex[ c_layer ],
        [ 'name' ],
        attrs
      )
  )

  O.ui_colors.on_set( ->
    O.tableverse.map.each( ( map ) ->
      map.redraw()
    )
  )
)
