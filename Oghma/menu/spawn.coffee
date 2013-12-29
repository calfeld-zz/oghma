
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
Oghma.Menu ?= {}

# Spawn menu.
#
# @param [Oghma.App] App.
# @return [Oghma.Ext.Menu] Spawn menu.
#
# @author Christopher Alfeld (calfeld@calfeld.net)
# @copyright 2013 Christopher Alfeld
Oghma.Menu.spawn = ( O ) ->
  spawn_dialog = ->
    dialog = Ext.create( 'Oghma.Ext.EditObject',
      object:
        name:      'Example'
        index:     ''
        size:      1
        owner:     O.me().gets( 'name' )
        group:     'undetermined'
        category:  'undetermined'
        fill:      O.me().gets( 'primary' )
        stroke:    O.me().gets( 'secondary' )
      types:
        fill:   'color'
        stroke: 'color'
        index:  'string-blank'
      title: 'Spawn Avatar'
      onSave: ( avatarinfo ) =>
        O.table.load_dropper( ( x, y, e) ->
          avatarinfo.x = x
          avatarinfo.y = y
          O.tableverse.create( 'avatar', avatarinfo )
        )
        dialog.close()
      onCancel: ->
        dialog.close()
    )

  calculate_index = ( name ) ->
    max_existing_index = 0
    O.tableverse.avatar.each( ( avatar ) ->
      ++max_existing_index if name == avatar.gets('name')
    )
    if max_existing_index == 0 then null else max_existing_index + 1

  Ext.create( 'Oghma.Ext.Menu',
    items: [
      {
        text: 'Spawn Example Avatar'
        handler: ->
          O.table.load_dropper( ( x, y, e ) ->
            O.tableverse.create( 'avatar',
              name: 'Example'
              index: calculate_index( 'Example' )
              x: x
              y: y
            )
          )
      },
      {
        text: 'Spawn...'
        handler: ->
          spawn_dialog().show()
      }
    ]
  )
