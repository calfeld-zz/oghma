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

# Class to allow other modules to register thingy definitions.
#
# This class is part of the Oghma bootstrap process.  It allows modules to
# register functions to be called during thingyverse setup, e.g., to define
# thingies, and then have that code called at the appropriate point in the
# bootstrapping process.
#
# This class is not intended for use outside of this file which also defines
# the Oghma.Thingy.* primordial thingyverses.  Those currently are:
#
# - Oghma.Thingy.Userverse: All userverse thingies will be instantiated before
#   tableverse thingies and before login (i.e., before there is a current
#   user).  As such, they should operate with minimal context, e.g., be plain
#   data.
# - Oghma.Thingy.Tableverse: All tableverse thingies will not be instantiated
#   until all userverse thingies are and until a successful login has
#   occurred.  As such, they can require user data to be available and a
#   current user to be set.
#
#
# @author Christopher Alfeld (calfeld@calfeld.net)
# @copyright 2013 Christopher Alfeld
class Oghma.PrimordialThingyverse
  # Constructor.
  constructor: ->
    @_ =
      generators: []

  # Register a generator function to be called at thingyverse creation.
  #
  # @param [function({Heron.Thingyverse}, {Oghma.App})] Function to be called
  #   with thingyverse and application at thingyverse creation.
  # @return [Oghma.PrimordialThingyverse] this
  register: ( generator ) ->
    @_.generators.push( generator )
    this

  # Call all generators with `thingyverse`.
  #
  # @param [Heron.Thingyverse] thingyverse Thingyverse to pass to generators.
  # @return [Oghma.PrimordialThingyverse] this
  generate: ( thingyverse, O ) ->
    g( thingyverse, O ) for g in @_.generators
    this

# See {Oghma.PrimordialThingyverse}
Oghma.Thingy.Userverse  = new Oghma.PrimordialThingyverse()
# See {Oghma.PrimordialThingyverse}
Oghma.Thingy.Tableverse = new Oghma.PrimordialThingyverse()
