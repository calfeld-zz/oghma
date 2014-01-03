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

# Login Manager Component
#
# This class works closely with the login allverse thingy.  It maintains
# information about current connections and logins and provides an API to
# access that information.
#
# @author Christopher Alfeld (calfeld@calfeld.net)
# @copyright 2013 Christopher Alfeld
class Oghma.Login
  # Constructor.
  #
  # @param [Oghma.App] Application.
  constructor: ( O ) ->
    @_ =
      O:         O
      clients:   {}
      callbacks:
        login:      jQuery.Callbacks()
        logout:     jQuery.Callbacks()
        connect:    jQuery.Callbacks()
        disconnect: jQuery.Callbacks()
      ready: false
      # Called from allverse.Login
      login_create: ( thingy ) =>
        return if ! @_.ready
        if @is_client( thingy.gets( 'client_id' ) )
          @_.callbacks.login.fire( thingy.geta( 'name', 'client_id' )... )
        null
      # Called from allverse.Login
      login_remove: ( thingy ) =>
        return if ! @_.ready
        if @is_client( thingy.gets( 'client_id' ) )
          @_.callbacks.logout.fire( thingy.geta( 'name', 'client_id' )... )
        null

    @_.O.dictionary.subscribe( 'oghma.login',
      create: ( domain, key, value ) =>
        switch key
          when '_clients'
            for client_id in value
              @_.clients[ client_id ] = true
              @_.callbacks.connect.fire( client_id )
          when '_subscribe'
            if @_.clients[ value ]?
              @_.O.warn( "Duplicate client: #{client_id}" )
            @_.clients[ value ] = true
            for login in @_.O.allverse.login.with_client_id( value )
              @_.callbacks.login.fire( thingy.geta( 'name', 'client_id' )... )
            @_.callbacks.connect.fire( value )
          when '_unsubscribe'
            for login in @_.O.allverse.login.with_client_id( value )
              # Remove will fire logout.
              login.remove()
            delete @_.clients[ value ]
            @_.callbacks.disconnect.fire( value )
          when '_synced'
            @_.ready = true
            @cleanup_logins()
            @_.O.allverse.login.each( ( thingy ) =>
              @_.callbacks.login.fire( thingy.geta( 'name', 'client_id' )... )
            )
          else
            @_.O.error( "Unknown key on oghma.login: #{key}" )
        null
      update: ( domain, key, value ) ->
        @_.O.error( "Received update on oghma.login domain: #{key}" )
        null
      delete: ( domain, key ) ->
        @_.O.error( "Received delete on oghma.login domain: #{key}" )
        null
    )

  # Register callback.
  #
  # @param [string] which One of 'login', 'logout', 'connect', or
  #   'disconnect'.
  # @param [function] f Function to call on specified event.  Login/out
  #   are passed username and client_id.  (Dis)connect are passed client_id.
  # @return [Oghma.Login] this
  on: ( which, f ) ->
     @_.callbacks[ which ].add( f )
     this

  # Update login information.
  #
  # This calculates which logins have logged out and updates the login
  # information.  It is usually called automatically when appropriate.
  #
  # @return [Oghma.Login] this
  cleanup_logins: ->
    to_delete = []
    @_.O.allverse.login.each( ( thingy ) =>
      [ name, client_id ] = thingy.geta( 'name', 'client_id' )
      if ! @is_client( client_id )
        to_delete.push( thingy )
    )
    for thingy in to_delete
      thingy.remove()
    this

  # Iterate through logins.
  #
  # @param [function(name, client_ids)] f Called for each login.
  # @return [array] Return values of `f`.
  each: ( f = ( x... ) -> x ) ->
    @_.O.allverse.login.each_name( ( name ) =>
      client_ids = ( t.gets( 'client_id' ) for t in @_.O.allverse.login.with_name( name ) )
      f( name, client_ids )
    )

  # @param [string] client_id ID of client to query.
  # @return [boolean] True iff `client_id` is a current client.
  is_client: ( client_id ) ->
    @_.clients[ client_id ]?

  # @return [array<string>] All connected client ids.
  clients: ->
    Heron.Util.keys( @_.clients )

  # @return [array<string>] All logged in usernames.
  who: ->
    @each( ( name ) -> name )
