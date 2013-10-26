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
    alert("Not yet implemented.")

  make_gm_only = ( table ) ->
    table.set( visible_to: [ O.GM ] )
  make_public = ( table ) ->
    table.set( visible_to: [] )
  make_visible_to = ( table, who ) ->
    table.set(
      visible_to: table.gets( 'visible_to' ).concat( [ who ] )
    )
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
          if O.current_table.gets( 'visible_to' ).length == 0
            @add(
              text: "Make #{current} #{O.GM} only"
              handler: -> make_gm_only( current_table )
            )
          else
            @add(
              text: "Make #{current} public"
              handler: -> make_public( current_table )
            )
            @add(
              Ext.create('Ext.form.field.Text',
                fieldLabel: 'Make visible to '
                listeners:
                  specialkey: ( field, e ) =>
                    if e.getKey() == e.ENTER
                      name = field.getValue()
                      make_visible_to( current_table, name )
                      @hide()
              )
            )
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
