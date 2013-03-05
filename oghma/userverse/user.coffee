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
            box:      Oghma.Ext.Console.defaultBox
      @__managed_windows =
         console: null
      @__update_guard = false

      for w, info of attrs.window
        @__.window[ w ] = info

      @after_construction( ->
        thingyverse.user.add( this )
      )

      update_info = ( which ) =>
        return if @__update_guard
        ext = @__managed_windows[ which ]
        window= @gets( 'window' )
        new_info =
          visible: ext.isVisible()
          box:     window[ which ].box
        if ext.isVisible()
          box = ext.getBox()
          new_info.box = [ box.x, box.y, box.width, box.height ]
        if window[ which ] != new_info
          window[ which ] = new_info
          @set( window: window )

      update_window = ( which, guard = false ) =>
        @__update_guard = true
        ext      = @__managed_windows[ which ]
        visible  = @__.window[ which ].visible
        box      = @__.window[ which ].box
        if visible
          ext.show()
        else
          ext.hide()
        ext.setPosition( box[0], box[1] )
        ext.setSize( box[2], box[3] )
        @__update_guard = false
        if ! guard
          update_info()
        null

      @manage_window = ( which, ext ) ->
        @__managed_windows[ which ] = ext
        ext.on( 'resize', -> update_info( which ) )
        ext.on( 'move',   -> update_info( which ) )
        ext.on( 'hide',   -> update_info( which ) )
        ext.on( 'show',   -> update_info( which ) )
        update_window( which, true )
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
            for which of thingy.__managed_windows
              update_window( which, true )

        null

      get: ( thingy, keys... ) ->
        thingy.__

      remove: ( thingy ) ->
        thingyverse.user.remove( thingy )
        null
  )
)
