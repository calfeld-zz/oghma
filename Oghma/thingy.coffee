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
# - Oghma.Thingy.Allverse: A single thingyverse that holds thingies that must
#   always be able such as userinfo and tableinfo.  This thingyverse is
#   connected to immediately upon load.  No thingy in it can depend on the
#   current user.
# - Oghma.Thingy.Tableverse: A per-table thingyverse that holds thingies that
#   represent table objects such as dice, rulers, and avatars.  A tableverse
#   is connected to after login and the user is free to switch to another
#   tableverse at any time.
# - Oghma.Thingy.Userverse: A per-user thingyverse that holds thingies that
#   only a particular user needs such as avatar-templates.  The appropriate
#   userverse is connected to after login and never changed.
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
Oghma.Thingy.Allverse  = new Oghma.PrimordialThingyverse()
# See {Oghma.PrimordialThingyverse}
Oghma.Thingy.Userverse  = new Oghma.PrimordialThingyverse()
# See {Oghma.PrimordialThingyverse}
Oghma.Thingy.Tableverse = new Oghma.PrimordialThingyverse()
