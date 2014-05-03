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

# Table status.
#
# @param [Oghma.App] App.
# @return [Oghma.Ext.EnumerationMenu] Table status menu.
#
# @author Christopher Alfeld (calfeld@calfeld.net)
# @copyright 2013 Christopher Alfeld
Oghma.Status.table = ( O ) ->
  create_table = ( name ) ->
    O.allverse.create('table', name: name, visible_to: [ O.GM ])
    O.join_table( name )
  delete_table = ( table ) ->
    if table.gets( 'name' ) == O.default_table
      O.error( "Cannot remove default table." )
    else
      O.join_table( O.default_table )
      table.remove()
  pull_to = ( table ) ->
    O.event.fire( 'table.pull', table.gets( 'name' ) )

  who = ( table ) ->
    visible_to = table.gets( 'visible_to' )
    if visible_to.length == 0
      'Everyone'
    else
      visible_to.join( ', ' )

  is_visible = ( table ) ->
    visible_to = table.gets( 'visible_to' )
    visible_to.length == 0 ||
    visible_to.indexOf( O.me().gets( 'name' ) ) != -1

  O.ui_colors.on_set( -> O.action.update_grid_controls( O ) )

  Ext.create( 'Oghma.Ext.Menu',
    items: [ 'Placeholder' ]
    listeners:
      beforeshow: ->
        current_table = O.current_table
        current = current_table.gets( 'name' )
        @removeAll()
        if O.isGM()
          @add(
            Ext.create('Ext.form.field.Text',
              fieldLabel: 'Create'
              listeners:
                specialkey: ( field, e ) =>
                  if e.getKey() == e.ENTER
                    name = field.getValue()
                    if confirm( "Create new table: #{name}?" )
                      create_table( name )
                      O.join_table( name )
                    @hide()
            )
          )
          @add( '-' )
          @add( Oghma.SubMenu.visibility( O, current_table ) )
          @add( '-' )
          @add(
            text: "Pull to #{current}"
            handler: -> pull_to( current_table )
          )
          @add(
            text: "Delete #{current}"
            disabled: current_table.gets( 'name' ) == O.default_table
            handler: ->
              if confirm( "Delete #{current}" )
                delete_table( current_table )
          )
          @add('-')
          @add(
            text: 'Edit Grid'
            checked: O.action.grid_controls_visible()
            checkHandler: ( item, checked ) =>
              if checked
                O.action.show_grid_controls( O )
                O.action.return_to_origin()
              else
                O.action.hide_grid_controls()
              @hide()
          )
          @add('-')

        for table in O.allverse.table.each()
          if is_visible( table )
            do ( table ) =>
              name = table.gets( 'name' )
              @add(
                text:    if O.isGM() then "#{name} (#{who( table )})" else name
                checked: table == O.current_table
                group:   'tables'
                handler: -> O.join_table( name )
              )
  )
