
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

# Spawn menu.
#
# @param [Oghma.App] App.
# @return [Oghma.Ext.Menu] Shapes menu.
#
# @author Christopher Alfeld (calfeld@calfeld.net)
# @copyright 2014 Christopher Alfeld
Oghma.Menu.shapes = ( O ) ->
  spawn_dialog = ( which ) ->
    dialog = Ext.create( 'Oghma.Ext.EditObject',
      object:
        fill:    O.me().gets( 'primary' )
        stroke:  O.me().gets( 'secondary' )
        opacity: 1.0
      types:
        fill:    'color'
        stroke:  'color'
        opacity: 'string'
      title: 'Spawn'
      onSave: ( attrs ) =>
        attrs.opacity = parseFloat( attrs.opacity )
        O.twopoint.load( which, attrs )
        dialog.close()
      onCancel: ->
        dialog.close()
    )

  Ext.create( 'Oghma.Ext.Menu',
    items: [
      {
        text: 'Rectangle...'
        handler: ->
          spawn_dialog( 'rectangle' ).show()
      },
      {
        text: 'Circle...'
        handler: ->
          spawn_dialog( 'circle' ).show()
      }
    ]
  )
