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

# userverse: user
#
# The user thingy is a plain data thingy that holds the user specific
# information.
#
# Attributes:
# - name      [string] Name.
# - primary   [string] Primary color.
# - secondary [string] Secondary color.
#
# Indices:
# - name
#
Oghma.Thingy.Userverse.register( (thingyverse) ->
  thingyverse.user = new Heron.Index.MapIndex('name')

  thingyverse.define(
    'user',
    [ 'name' ],
    colors: [ 'primary', 'secondary' ]
    ( attrs ) ->
      @_ =
        name:      attrs.name      ? 'Guest'
        primary:   attrs.primary   ? 'orange'
        secondary: attrs.secondary ? 'blue'

      thingyverser.user.add(this)

      set: (thingy, attrs) ->
        for k, v of attrs
          if k == 'name'
            thingyverse.user.remove(thingy)
            @_[k] = v
            thingyverse.user.add(thingy)
          else
            @_[k] = v
        null

      get: ( thingy, keys... ) ->
        @_

      remove: ( thingy ) ->
        thingyverse.user.remove(thingy)
        null
  )
)
