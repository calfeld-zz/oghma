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

# clear menu.
#
# @param [Oghma.App] App.
# @return [Oghma.Ext.Menu] Clear menu.
#
# @author Christopher Alfeld (calfeld@calfeld.net)
# @copyright 2013 Christopher Alfeld
Oghma.Menu.clear = ( O ) ->
  Ext.create( 'Oghma.Ext.Menu',
    listeners:
      beforeshow: ->
        @child( '#dice'   ).setDisabled( O.tableverse.dice.empty()   )
        @child( '#shapes' ).setDisabled( O.tableverse.shapes.empty() )
        @child( '#rulers' ).setDisabled( O.tableverse.rulers.empty() )
    items: [
      {
        text:    'Dice'
        id:      'dice'
        handler: ( item, e ) =>
          all = e.shiftKey
          O.tableverse.dice.each( ( die ) ->
            if all || O.i_own( die )
              die.remove()
          )
      },
      {
        text: 'Rulers'
        id:   'rulers'
        handler: ( item, e ) =>
          all = e.shiftKey
          O.tableverse.rulers.each( ( ruler ) ->
            if all || O.i_own( ruler )
              ruler.remove()
          )
      },
      {
        text: 'Shapes'
        id:   'shapes'
        handler: ( item, e ) =>
          all = e.shiftKey
          O.tableverse.shapes.each( ( shape ) ->
            if all || O.i_own( shape )
              shape.remove()
          )
      }
      '-',
      {
        text: "Hold shift for all (vs. mine)."
        disabled: true
      }
    ]
  )
