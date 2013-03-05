
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

# window menu.
#
# @param [Oghma.App] App.
# @return [Ext.menu.Menu] Window menu.
#
# @author Christopher Alfeld (calfeld@calfeld.net)
# @copyright 2013 Christopher Alfeld
Oghma.Menu.window = ( O ) ->
  Ext.create( 'Ext.menu.Menu',
    items: [
      {
        text:    'Console'
        checked: true
        checkHandler: ( item, state ) ->
          if state
            O.console.show()
          else
            O.console.hide()
        listeners: beforerender: ->
          @setChecked( O.console.isVisible() )
      },
      '-',
      {
        text: 'Reset Window Positions'
        handler: ->
          for key, klass of { console: Oghma.Ext.Console }
            box = klass.defaultBox
            O[ key ].setPosition( box[0], box[1] )
            O[ key ].setSize(     box[2], box[3] )
      }
    ]
  )
