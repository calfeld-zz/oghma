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
Oghma.Thingy ?= {}

# allverse: table
#
# A table is a virtual tabletop, populated with Tableverse thingies.  Each
# login is in a single table and may move between tables at will.  A table
# may be visible to everyone (empty `visible_to`) or to only a subset of
# users (e.g., GM only).
#
# Attributes:
# - name       [string]        Name of table.
# - visible_to [array<string>] Users table is visible to.  Empty list means
#   all.
#
# Indices:
# - name
#
# @author Christopher Alfeld (calfeld@calfeld.net)
# @copyright 2013 Christopher Alfeld
Oghma.Thingy.Allverse.register( ( thingyverse, O ) ->
  thingyverse.table= new Heron.Index.MapIndex( 'name' )

  thingyverse.define(
    'table',
    [ 'name', 'visible_to' ],
    {},
    ( attrs ) ->
      @__ =
        name:       attrs.name      ? throw 'name required.'
        visible_to: attrs.visible_to ? []

      @after_construction( =>
        thingyverse.table.add( this )
      )

      set: (thingy, attrs) ->
        for k, v of attrs
          thingy.__[k] = v
        null

      get: ( thingy, keys... ) ->
        thingy.__

      remove: ( thingy ) ->
        thingyverse.login.remove( thingy )
        null
  )
)
