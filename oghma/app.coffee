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

# Main application class.
#
# A single instance of this class is instantiated as the O global variable
# once the document is ready.  It holds all application data and serves as
# the `main` routine.
#
# @author Christopher Alfeld (calfeld@calfeld.net)
# @copyright 2013 Christopher Alfeld
class Oghma.App
  # Constructor
  #
  # Sets up server connections for {Heron.Comet} and {Heron.Dictionary} and
  # initializes the thingyverses from the primordial thingyverses.  Once the
  # userverse is loaded, displays the login screen.
  #
  # @param [object] config Configuration.
  # @option config [boolean] debug If true, additional information is sent to
  #   the console.  Default: false.
  #
  # **Properties**:
  #
  # - client_id [string]
  # - dictionary [{Heron.Dictionary}]
  # - comet [{Heron.Comet}]
  # - userverse [{Heron.Thingyverse}]
  # - tableverse [{Heron.Thingyverse}]
  #
  constructor: (config = {}) ->
    @_ = {}
    @_.debug = config.debug ? false

    Ext.getBody().mask( 'Initialising...' )

    # Communication
    @client_id = Heron.Util.generate_id()

    @dictionary = new Heron.Dictionary(
      client_id: @client_id
      debug:     @_.debug
    )

    @comet = new Heron.Comet(
      client_id:  @client_id
      on_message: ( msg )  => @dictionary.receive( msg )
      on_verbose: ( text ) => @verbose( text )
      on_connect: => @login_phase()
    )

    # Thingyverses
    @userverse = new Heron.Thingyverse()
    Oghma.Thingy.Userverse.generate( @userverse, this )

    @tableverse = new Heron.Thingyverse( ready: false )
    Oghma.Thingy.Tableverse.generate( @tableverse, this )

    # Connect
    @comet.connect()

  # Login Phase.
  #
  # Display Login window.  Also handles user creation logic.
  login_phase: ->
    @userverse.connect( @dictionary, 'oghma.thingy.user', =>
      create = Ext.create( 'Oghma.Ext.EditObject',
        object:
          Name:      ''
          Primary:   'FF0000'
          Secondary: '00FF00'
        types:
          Primary:   'color'
          Secondary: 'color'
        title: 'Create User'
        onSave: (userinfo) ->
          if userinfo.Name == ''
            alert( 'Name cannot be blank.' )
          else
            create.close()
            login.close()
            alert( "Creating user: #{userinfo.Name}" )
        onCancel: ->
          create.hide()
          login.show()
      )
      login = Ext.create( 'Oghma.Ext.Login',
        O: this
        onLogin: ( user ) ->
          login.close()
          create.close()
          alert( "Login #{user}" )
        onCreate: ->
          login.hide()
          create.show()
      )
      login.show()
      Ext.getBody().unmask()
    )
    @tableverse.connect( @dictionary, 'oghma.thingy.table' )
    null

  # Send verbose message to the console.
  #
  # @param [string] msg Message to send.
  # @return [Oghma.App] this
  verbose: ( msg ) ->
    console.info( msg )
    this

  # Send error message to the console.
  #
  # @param [string] msg Message to send.
  # @return [Oghma.App] this
  error: ( msg ) ->
    console.error( msg )
    this

  # Send a debug message to the console.
  #
  # @param [string] msg Message to send.
  # @return [Oghma.App] this
  debug: ( msg ) ->
    console.debug( msg )
    this
