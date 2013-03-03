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

# userverse: user
#
# The user thingy is a plain data thingy that holds the user specific
# information.
#
# Attributes:
# - name      [string] Name.
# - primary   [string] Primary color.
# - secondary [string] Secondary color.
#
# Indices:
# - name
#
Oghma.Thingy.Userverse.register( ( thingyverse, O ) ->
  thingyverse.user = new Heron.Index.MapIndex( 'name' )

  thingyverse.define(
    'user',
    [ 'name' ],
    colors: [ 'primary', 'secondary' ]
    window: [ 'window' ]
    ( attrs ) ->
      @__ =
        name:      attrs.name      ? 'Guest'
        primary:   attrs.primary   ? 'orange'
        secondary: attrs.secondary ? 'blue'
        window:
          console:
            visible:  true
            box:      [ 50, 50, 200, 200 ]
      @__managed_windows =
         console: null

      for w, info of attrs.window
        @__.window[ w ] = info

      @after_construction( ->
        thingyverse.user.add( this )
      )

      update_window = ( which ) =>
        ext      = @__managed_windows[ which ]
        visible  = @__.window[ which ].visible
        box      = @__.window[ which ].box
        if visible
          ext.show()
        else
          ext.hide()
        ext.setPosition( box[0], box[1] )
        ext.setSize( box[2], box[3] )
        null

      @manage_window = ( which, ext ) ->
        @__managed_windows[ which ] = ext
        update_info = =>
          box = ext.getBox()
          @__.window[ which ] =
            visible: ext.isVisible()
            box: [ box.x, box.y, box.width, box.height ]
          @set( window: @__.window )
        ext.on( 'resize', update_info )
        ext.on( 'move',   update_info )
        ext.on( 'hide',   update_info )
        ext.on( 'show',   update_info )
        update_window( which )
        this

      set: (thingy, attrs) ->
        for k, v of attrs
          if k == 'name'
            thingyverse.user.remove( thingy )
            thingy.__[k] = v
            thingyverse.user.add( thingy )
          else
            thingy.__[k] = v
          if k == 'window'
            update_window( which ) for which of thingy.__managed_windows

        null

      get: ( thingy, keys... ) ->
        thingy.__

      remove: ( thingy ) ->
        thingyverse.user.remove( thingy )
        null
  )
)
