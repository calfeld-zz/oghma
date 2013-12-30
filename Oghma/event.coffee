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

# Event Component
#
# This class provides a mechanism for sending events to all clients.
#
# @author Christopher Alfeld (calfeld@calfeld.net)
# @copyright 2013 Christopher Alfeld
class Oghma.Event
  # Constructor.
  #
  # @param [Oghma.App] Application.
  constructor: ( O ) ->
    @_ =
      O:         O
      callbacks: {}
      ready: false

    @_.O.dictionary.subscribe( 'oghma.event',
      create: ( domain, key, value ) =>
        if key[0] != '_' and key != '%event'
          @_.O.error( "Unexpected key received on oghma.event domain: #{key}" )
        else if key == '%event'
          if ! value.which?
            @_.O.error( "Missing which for event." )
            return null
          if ! value.data?
            @_.O.error( "Missing data for event." )
            return null
          @_.callbacks[ value.which ]?.fire( value.which, value.data, false )
        null
      update: ( domain, key, value ) ->
        @_.O.error( "Received update on oghma.event domain: #{key}" )
        null
      delete: ( domain, key ) ->
        @_.O.error( "Received delete on oghma.event domain: #{key}" )
        null
    )

  # Register callback.
  #
  # @param [string] which Which event to attach callback to.
  # @param [function] f Function to call on specified event.  Which event,
  #  local and remote data are passed as arguments.
  # @return [Oghma.Event] this
  on: ( which, f ) ->
    @_.callbacks[ which ] ?= jQuery.Callbacks()
    @_.callbacks[ which ].add( f )
    this

  # Fire an event.
  #
  # @param [string] which Which even to fire.
  # @param [object] data Data of event.
  # @param [object] local_data Local data of event.  Default: true
  # @return [Oghma.Event] this
  fire: ( which, data, local_data = true ) ->
    @_.callbacks[ which ]?.fire( which, data, local_data )
    @_.O.dictionary.create( 'oghma.event', '%event',
      which: which
      data: data
    )
    this
