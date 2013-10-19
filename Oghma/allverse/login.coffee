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

# allverse: login
#
# The login thingy is a plain data thingy that holds the user specific
# information.  It works closely with {Oghma.Login} which it assumes is held
# at `O.login`.
#
# Attributes:
# - name      [string] Name of user.
# - client_id [string] Client ID.
#
# Indices:
# - name
# - client_id
#
# @author Christopher Alfeld (calfeld@calfeld.net)
# @copyright 2013 Christopher Alfeld
Oghma.Thingy.Allverse.register( ( thingyverse, O ) ->
  thingyverse.login = new Heron.Index.MapIndex( 'name', 'client_id' )

  thingyverse.define(
    'login',
    [ 'name', 'client_id' ],
    {},
    ( attrs ) ->
      @__ =
        name:      attrs.name      ? throw 'name required.'
        client_id: attrs.client_id ? throw 'client_id required.'

      @after_construction( =>
        thingyverse.login.add( this )
        O.login?._.login_create( this )
      )

      set: (thingy, attrs) ->
        throw 'login thingies are immutable.'
        null

      get: ( thingy, keys... ) ->
        thingy.__

      remove: ( thingy ) ->
        O.login?._.login_remove( thingy )
        thingyverse.login.remove( thingy )
        null
  )
)
