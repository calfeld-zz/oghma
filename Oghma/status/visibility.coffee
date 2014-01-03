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
Oghma.Status ?= {}

# Visibility status.
#
# @param [Oghma.App] App.
# @param [function] Function to call on change with values of `show_hidden`
#   and `show_all`.  Default: nop.
# @return [Oghma.Ext.Menu] Visibility status menu.
#
# @author Christopher Alfeld (calfeld@calfeld.net)
# @copyright 2014 Christopher Alfeld
Oghma.Status.visibility = ( O, on_change = -> ) ->
  show_all = -> O.me().gets( 'show_all' )
  show_hidden = -> O.me().gets( 'show_hidden' )

  Ext.create( 'Oghma.Ext.Menu',
    items: [ 'Placeholder' ]
    listeners:
      beforeshow: ->
        @removeAll()
        @add(
          text: 'Show Hidden'
          checked: show_hidden()
          checkHandler: ( item, checked ) ->
            O.me().set( show_hidden: checked )
            O.redraw_tableverse()
            on_change( show_hidden(), show_all() )
        )
        if O.isGM()
          @add(
            text: 'Show All'
            checked: show_all()
            checkHandler: ( item, checked ) ->
              O.me().set( show_all: checked )
              O.redraw_tableverse()
              on_change( show_hidden(), show_all() )
          )
  )

