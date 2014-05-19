
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

# Tools menu.
#
# @param [Oghma.App] App.
# @return [Oghma.Ext.Menu] Tools menu.
#
# @author Christopher Alfeld (calfeld@calfeld.net)
# @copyright 2014 Christopher Alfeld
Oghma.Menu.tools = ( O ) ->
  Ext.create( 'Oghma.Ext.Menu',
    items: [
      {
        text: 'Ruler'
        handler: ->
          O.twopoint.load( 'ruler', {} )
      },
      {
        text: 'Ping'
        handler: ->
          O.table.load_dropper( ( x, y, e ) ->
            O.action.ping( x, y, O )
          )
      }
    ]
  )
