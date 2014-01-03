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

# Debug menu.
#
# @param [Oghma.App] App.
# @return [Oghma.Ext.Menu] Debug menu.
#
# @author Christopher Alfeld (calfeld@calfeld.net)
# @copyright 2013 Christopher Alfeld
Oghma.Menu.debug = ( O ) ->
  menu = Ext.create( 'Oghma.Ext.Menu',
    items: [
      {
        text: "Force Stage Redraw"
        handler: -> O.stage.draw()
      },
      {
        text: "Force Tableverse Redraw"
        handler: -> O.redraw_tableverse()
      },
      {
        text: "Force ZIndex Recalculate"
        handler: -> O.recalculate_zindices()
      },
      {
        text:    "Display Origin"
        checked: false
        handler: ->
          if @checked
            O.action.show_origin_marker()
          else
            O.action.hide_origin_marker()
      },
      {
        text: "Spawn Shape"
        handler: ->
          O.tableverse.create( 'shape' )
      }
    ]
  )
