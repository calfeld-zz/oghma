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

#
#On local create, call acquire_top_index which provides a z index for the top of the heap.  Then create the thingy with that zindex.  Then call register.
#
#On remote create, call remote_create which checks if the z index is compatible and recalculates if not.
#
#On remove, nothing to do.
#
# On raise call acquire_top_index and set z index to it.
#
# On lower, call acquire_bottom_index and set z index to it.
#
# On z index set, call set_z_index which will either call _raise, _lower,
# or trigger a recalculate.
#
# A recalculate calls _raise or _lower for every thingy it knows about so that thingies are ordered by z index first and then id.

c_attribute = 'zindex'

# Manage overlap order of thingies within a layer.
#
# This class is best used when every thingy drawn into a layer  uses it.  It
# can be used with only a subset of thingies, but thingies not included will
# quickly end up at the bottom.
#
# Every thingy is assumed to have a 'zindex' attribute.  Thingies are then
# arranged in order of z index with ties broken by thingy id.  There is no
# requirement or expectation that indices are contiguous.  There is also no
# reindexing (keeps down interclient traffic).
#
# The new-thingy-on-top and new-thingy-on-bottom cases are handled quickly,
# as is raising a thingy to top or lowering it to the bottom.  Anything else
# will cause a recalculation, adjusting all thingies to be in proper order.
# In particular, if two thingies are created more or less simultaneously and
# have the same zindex, this will be detected and cause a recalculate on all
# clients.
#
# Thingies registered, must implement `_raise()` and `_lower()` methods which
# raise and lower their graphics.
#
# @author Christopher Alfeld (calfeld@calfeld.net)
# @copyright 2014 Christopher Alfeld
class Oghma.ZIndex
  # Construct a new, empty, zindex.
  constructor: ->
    @_ =
      max: null
      min: null
      thingies: {}

  # Register thingy.
  #
  # This method is guaranteed to not recalculate, raise, or lower.  As such,
  # it can be called early in thingy creation, e.g., just after zindex
  # acquisition.
  #
  # Be sure to call {#unregister} when finished.
  #
  # @param [Heron.Thingy] Thingy to register.  Must have `zindex` attribute
  #   and _raise() and _lower() methods.
  # @return [Oghma.ZIndex] this
  register: ( thingy ) ->
    z = thingy.gets( c_attribute )
    if ! @_.max? || z > @_.max
      @_.max = z
    if ! @_.min? || z < @_.min
      @_.min = z
    @_.thingies[ thingy.id() ] = thingy

    this

  # Unregister thingy.
  #
  # @param [Heron.Thingy] Thingy to unregister.
  # @return [Oghma.ZIndex] this
  unregister: ( thingy ) ->
    delete @_.thingies[ thingy.id() ]

    this


  # What is a zindex for being at the top?
  #
  # @return [number] Value for `zindex` attribute that would be at the top.
  acquire_top_index: ->
    if @_.max?
      @_.max + 1
    else
      1
  # What is a zindex for being at the bottom?
  #
  # @return [number] Value for `zindex` attribute that would be at the bottm.
  acquire_bottom_index: ->
    if @_.min?
      @_.min - 1
    else
      0

  # Adjust thingies to be in the proper order.
  #
  # This method forces a recalculation and calls _raise() or _lower() on every
  # thingie appropriately to put in the proper spot.  Calling this is
  # expensive.
  #
  # @return [Oghma.ZIndex] this
  recalculate: ->
    sort_function = ( a, b ) ->
      akey = [ a.gets( c_attribute ), a.id() ]
      bkey = [ b.gets( c_attribute ), b.id() ]
      if akey[0] < bkey[0]
        return -1
      else if akey[0] > bkey[0]
        return 1
      else
        if akey[1] < bkey[1]
          return -1
        else if akey[1] > bkey[1]
          return 1
        else
          return 0

    thingies = Heron.Util.values( @_.thingies )
    thingies.sort( sort_function )

    min = thingies[0]
    max = thingies[thingies.length - 1]
    for thingy in thingies
      thingy._raise()

    this

  # Update z index knowledge of thingy.
  #
  # This method can be used in three ways.  Setting to a top z index is cheap
  # and moves the thingy to the top.  Setting to a bottom z index is cheap and
  # moves the thingy to the bottom.  Setting to any other z index is expensive
  # as it calls recalculate().
  #
  # @param [Heron.Thingy] thingy Thingy with new zindex.
  # @return [Oghma.ZIndex] this
  update: ( thingy ) ->
    z = thingy.gets( c_attribute )
    if z <= @_.max || z >= @_.min?
      @recalculate()
    else if z > @_.max
      @_.max = z
      thingy._raise()
    else if z < @_.min
      @_.min = z
      thingy._lower()

    this

