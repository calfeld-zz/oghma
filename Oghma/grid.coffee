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

# Grid Services
#
# This class provides grid related services.
#
# @author Christopher Alfeld (calfeld@calfeld.net)
# @copyright 2013 Christopher Alfeld
class Oghma.Grid
  constructor: ( O ) ->
    @_ =
      O: O
      mode: 'auto'

  # Convert table coordinates to grid coordinates.
  to_grid: ( pt ) ->
    origin = @origin()
    grid = @grid()
    [
      (pt[0] - origin[0]) /  grid,
      (pt[1] - origin[1]) /  grid
    ]

  # Convert grid coordinate to table coordinates.
  from_grid: ( grid_pt ) ->
    origin = @origin()
    grid = @grid()
    [
      grid_pt[0] * grid + origin[0],
      grid_pt[1] * grid + origin[1]
    ]

  # Grid size.  In table dimension.
  #
  # @note Always 1 in grid dimension.
  grid: ->
    O.current_table.gets( 'grid' )

  # Grid origin.  In table coordinates.
  #
  # @note Always 0, 0 in grid
  origin: ->
    O.current_table.gets( 'origin' )

  # Find nearest coordinate on grid, according to current mode.
  #
  # Parameter and result are in table coordinates.
  #
  # @param [x, y] pt Point in table coordinates to find nearest grid point of.
  # @param [x, y] from Point moving from for auto mode.
  # @param [string] mode Mode to use, defaults to @_.mode.
  #
  # Modes:
  # - null -- Identity function.
  # - grid -- Nearest grid coordinate.
  # - antigrid -- Nearest antigrid coordinate.
  # - both -- Nearest grid or antigrid coordinate.
  # - auto -- Choose grid or antigrid based on from parameter.
  nearest: ( pt, from = null, mode = @_.mode ) ->
    if mode == 'auto'
      if from?
        distance = ( a, b ) ->
          Math.max( Math.abs( b[1] - a[1] ), Math.abs( b[0] - a[0] ) )
        nearest_grid = @nearest( from, null, 'grid' )
        nearest_antigrid = @nearest( from, null, 'antigrid' )
        if distance( from, nearest_grid ) < distance( from, nearest_antigrid )
          mode = 'grid'
        else
          mode = 'antigrid'
      else
        mode = 'both'

    round = switch mode
      when null then ( x ) -> x
      when 'grid'
        # Round to nearest integer.
        Math.round
      when 'antigrid'
        # Round to nearest half integer.
        ( x ) -> Math.round(x + 0.5) - 0.5
      when 'both'
        # Round to nearest half or full integer.
        ( x ) -> Math.round( x * 2 ) / 2
      else
        throw "Unknown grid mode: #{mode}"

    grid_pt = @to_grid( pt )
    @from_grid( [ round( grid_pt[0] ), round( grid_pt[1] ) ] )

  # Current mode.
  mode: -> @_.mode

  # Set current mode.
  set_mode: ( mode ) -> @_.mode = mode
