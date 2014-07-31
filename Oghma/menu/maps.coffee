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
Oghma.Menu ?= {}

# Map menu.
#
# @param [Oghma.App] App.
# @return [Oghma.Ext.Menu] Map menu.
#
# @author Christopher Alfeld (calfeld@calfeld.net)
# @copyright 2014 Christopher Alfeld
Oghma.Menu.maps = ( O ) ->
  add_dialog = ->
    dialog = Ext.create( 'Oghma.Ext.EditObject',
      object:
        name:  'Example'
        image: ''
      types:
        name:  'string'
        image: 'string-blank'
      title: 'Spawn Avatar'
      onSave: ( mapinfo ) =>
        O.table.load_dropper( ( x, y, e) ->
          mapinfo.x = x
          mapinfo.y = y
          if mapinfo.image == ''
            mapinfo.image = mapinfo.name + '.png'
          O.tableverse.create( 'map', mapinfo )
        )
        dialog.close()
      onCancel: ->
        dialog.close()
    )

  default_items = [
    {
      text: 'Add...'
      handler: ->
        add_dialog().show()
    },
    {
      text: 'Add all at path...'
      handler: ->
        alert( 'Coming soon...' )
    },
    {
      text: 'Lock all'
      handler: ->
        O.tableverse.map.each( ( map ) ->
          map.set( locked: true )
        )
    },
    {
      text: 'Unlock all'
      handler: ->
        O.tableverse.map.each( ( map ) ->
          map.set( locked: false )
        )
    },
    '-'
  ]
  Ext.create( 'Oghma.Ext.Menu',
    items: [ 'placeholder' ]
    listeners:
      beforeshow: ->
        @removeAll()
        @add( default_items )
        O.tableverse.map.each( ( map ) =>
          do ( map ) =>
            @add( 
              text: map.gets( 'name' )
              checked: map.is_public()
              handler: ->
                if ! @checked
                  map.set( visible_to: [ O.me().gets( 'name' ) ] )
                else
                  map.set( visible_to: [] )
            )
        )
  )
