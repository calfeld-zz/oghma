
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
# @return [Ext.menu.Menu] Dice menu.
#
# @author Christopher Alfeld (calfeld@calfeld.net)
# @copyright 2013 Christopher Alfeld
Oghma.Menu.dice = ( O ) ->
  dice = [ 4, 6, 8, 10, 12, 20, 100 ]
  items = []
  roll_die = ( sides, x, y, e ) ->
    is_private = e.shiftKey
    if is_private
      r = 18
      font_size = 18
      visible_to = [ O.me().gets( 'name' ), O.GM ]
    else
      r = 25
      font_size = 24
      visible_to = null
    O.tableverse.create( 'dice',
      sides:      sides
      x:          x
      y:          y
      r:          r
      font_size:  font_size
      visible_to: visible_to
    )
    null

  for die in dice
    do ( die ) =>
      items.push(
        text: "d#{die}"
        handler: ( item, e ) =>
          O.table.load_dropper( ( x, y, e ) ->
            roll_die( die, x, y, e )
          )
      )
  items.push('-')
  items.push(
      text: "Shift-Drop for private."
      disabled: true
  )

  menu = Ext.create( 'Ext.menu.Menu', items: items )
