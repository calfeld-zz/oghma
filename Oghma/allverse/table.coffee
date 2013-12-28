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
# - grid       [float]         Width of grid square in Kinetic points.
# - origin     [float, float]  Origin of grid in Kinetic coordinates.
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
    {
      'grid': [ 'grid', 'origin' ]
    },
    ( attrs ) ->
      @__ =
        name:       attrs.name       ? throw 'name required.'
        visible_to: attrs.visible_to ? []
        grid:       attrs.grid       ? 32
        origin:     attrs.origin     ? [ 0, 0 ]

      @after_construction( =>
        thingyverse.table.add( this )
      )

      # Grid distance to kinetic distance.
      @g2k = ( d ) ->
        d * @__.grid

      # Grid vector to kinetic vector.
      @vec_g2k = ( v ) ->
        [ @g2k(v[0]) + @__.origin[0], @g2k(v[1]) + @__.origin[1] ]

      # Origin in kinetic coordinates.
      @origin_k = ->
        @vec_g2k( [ 0, 0 ] )

      set: ( thingy, attrs ) ->
        for k, v of attrs
          thingy.__[k] = v
        null

      get: ( thingy, keys... ) ->
        thingy.__

      unload: ( thingy ) ->
        thingyverse.table.remove( thingy )
        null

      remove: ( thingy, local_data ) ->
        @unload( thingy )
        if local_data
          # Fire and forget for now.  Eventually could check.
          jQuery.get( "/remove_table", table: thingy.gets( 'name' ) )
        null
  )
)
