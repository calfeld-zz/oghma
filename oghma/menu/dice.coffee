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

# dice menu.
#
# @param [Oghma.App] App.
# @return [Oghma.Ext.Menu] Dice menu.
#
# @author Christopher Alfeld (calfeld@calfeld.net)
# @copyright 2013 Christopher Alfeld
Oghma.Menu.dice = ( O ) ->
  dice = [ 4, 6, 8, 10, 12, 20, 100 ]
  items = []

  for die in dice
    do ( die ) =>
      items.push(
        text: "d#{die}"
        handler: ( item, e ) =>
          O.table.load_dropper( ( x, y, e ) ->
            O.action.roll_die( die, x, y, e.shiftKey )
          )
      )
  items.push('-')
  items.push(
      text: "Shift-Drop for private."
      disabled: true
  )

  menu = Ext.create( 'Oghma.Ext.Menu', items: items )
