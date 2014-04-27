# Copyright 2013 Christopher Alfeld
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

root = this

# Enumeration Menu
#
# @author Christopher Alfeld (calfeld@calfeld.net)
# @copyright 2013 Christopher Alfeld
Ext.define( 'Oghma.Ext.EnumerationMenu',
  extend: 'Oghma.Ext.Menu'

  # Enumeration.
  enumeration: false

  # Function to turn value into menu label.
  namer: (x) -> x

  # Increment label.
  increment: "Increment"

  # Decrement label.
  decrement: "Decrement"

  initComponent: ->
    @callParent( arguments )

    if ! @enumeration
      throw "EnumerationMenu requires enumeration."

    me = this
    id = @getId()

    Ext.apply( this,
      listeners:
        beforeshow: ->
          current = me.enumeration.index()
          for v, i in me.enumeration.values()
            @child( '#'+i+'_'+id ).setChecked( i == current )

          n = me.enumeration.values().length
          if ! me.enumeration.cycle()
            if me.increment
              @child( '#incr' ).setDisabled( i >= n - 1 )
            if me.decrement
              @child( '#decr' ).setDisabled( i <= 0)
    )

    if @increment?
      @add(
        text:    @increment
        handler: => @enumeration.incr()
        id:      'incr'
      )
    if @decrement?
      @add(
        text:    @decrement
        handler: => @enumeration.decr()
        id:      'decr'
      )

    for v, i in @enumeration.values()
      do (i) =>
        @add(
          text:    @namer(v)
          id:      i+'_'+id
          checked: i == @enumeration.index()
          group:   id
          handler: =>
            @enumeration.set_index(i)
        )
)