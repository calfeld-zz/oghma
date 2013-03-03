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

root = this

# Main application class.
#
# A single instance of this class is instantiated as the O global variable
# once the document is ready.  It holds all application data and serves as
# the `main` routine.
#
# @author Christopher Alfeld (calfeld@calfeld.net)
# @copyright 2013 Christopher Alfeld
class Oghma.App
  # Callbacks
  callbacks:
    post_login: jQuery.Callbacks()

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
    # Store in global for easy introspection from console.
    root.O = this

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
      on_verbose: ( text ) => console.info( text )
      on_connect: =>
        @verbose( 'Connected to server.' )
        @login_phase()
    )

    # Thingyverses
    @userverse = new Heron.Thingyverse()
    Oghma.Thingy.Userverse.generate( @userverse, this )

    @tableverse = new Heron.Thingyverse( ready: false )
    Oghma.Thingy.Tableverse.generate( @tableverse, this )

    # Console
    @console = Ext.create( 'Oghma.Ext.Console',
      x: 50
      y: 50
    )
    @on( 'post_login', ( me ) =>
      me.manage_window( 'console', @console )
    )

    @verbose( 'Oghma is connecting...' )

    # Connect
    @comet.connect()

  # Login Phase.
  #
  # Display Login window.  Also handles user creation logic.
  #
  # @return [null] null
  login_phase: ->
    # Create login Manager
    @login = new Oghma.Login( this )
    @login.on( 'login', ( username ) => @message( username, 'Logged In' ) )
    @login.on( 'logout', ( username ) => @message( username, 'Logged Out' ) )

    @userverse.connect( @dictionary, 'oghma.thingy.user', =>
      # Check for ?user parameter.
      result = /^\?user=([^?]+)/.exec( window.location.search )
      if result?
        user = decodeURI( result[1] )
        @verbose( "Auto logging in as #{user}" )
        @login_user( user )
      else
        create = Ext.create( 'Oghma.Ext.EditObject',
          object:
            name:      ''
            primary:   'FF0000'
            secondary: '00FF00'
          types:
            primary:   'color'
            secondary: 'color'
          title: 'Create User'
          onSave: ( userinfo ) =>
            if @create_user( userinfo )
              login.close()
              create.close()
              @login_user( userinfo.name )

          onCancel: ->
            create.hide()
            login.show()
        )
        login = Ext.create( 'Oghma.Ext.Login',
          O: this
          onLogin: ( user ) =>
            login.close()
            create.close()
            @login_user( user, @client_id )
          onCreate: ->
            login.hide()
            create.show()
        )
        login.show()
      Ext.getBody().unmask()
    )
    @tableverse.connect( @dictionary, 'oghma.thingy.table' )
    null

  # Login as user.
  #
  # @param [string] username User to login as.
  # @return [Oghma.App] this
  login_user: ( username ) ->
    @userverse.create( 'login',
      name:      username
      client_id: @client_id
    )
    window.history?.replaceState?(
      null,
      document.title,
      encodeURI( "?user=#{username}" )
    )
    @callbacks.post_login.fire( @me() )
    this

  # Register callback.
  #
  # Available events:
  # - post_login: Called with user thingy on successful login.
  #
  # @param [string] which Which event.
  # @param [function] f Function to call on specified event.
  # @return [Oghma.App] this
  on: ( which, f ) ->
    @callbacks[ which ].add( f )
    this

  # @return [userverse.user] Thingy for current user.
  me: ->
    username = @userverse.login.with_client_id( @client_id )[0].gets( 'name' )
    if username?
      @userverse.user.with_name( username )?[0]
    else
      null

  # Create a new user.
  #
  # See {#login_phase()}.
  #
  # @param [object] userinfo User info.
  # @option userinfo [string] username User name.
  # @option userinfo [string] primary Primary color.
  # @option userinfo [string] secondary Seconary color.
  # @return [null] null
  create_user: ( userinfo ) ->
    if @userverse.user.with_name( userinfo.name ).length > 0
      # TODO: Do something better with errors.
      alert( "User #{userinfo.name} already exists." )
      false
    else
      @userverse.create( 'user', userinfo )
      true

  # Send verbose message to the console.
  #
  # @param [string] msg Message to send.
  # @return [Oghma.App] this
  verbose: ( msg ) ->
    @console?.message( 'verbose', msg )
    console.info( msg )
    this

  # Send warn message to the console.
  #
  # @param [string] msg Message to send.
  # @return [Oghma.App] this
  warn: ( msg ) ->
    @console?.message( 'warning', msg, '#ff7f00', '#ff7f00' )
    console.warn( msg )
    this

  # Send error message to the console.
  #
  # @param [string] msg Message to send.
  # @return [Oghma.App] this
  error: ( msg ) ->
    @console?.message( 'error', msg, '#ff0000', '#ff0000' )
    console.error( msg )
    this

  # Send a debug message to the console.
  #
  # @param [string] msg Message to send.
  # @return [Oghma.App] this
  debug: ( msg ) ->
    @console?.message( 'debug', msg, '#0000ff', '#0000ff' )
    console.debug( msg )
    this

  # Send a message from a user to the console
  #
  # @param [string] username Name of user.
  # @param [string] message Message.
  # @return [Oghma.App] this
  message: ( from, msg ) ->
    user = @userverse.user.with_name( from )[0]
    if ! user?
      @error( "Message from non-existent user #{from}: #{msg}" )
    else
      color = user.gets( 'primary' )
      @console?.message( from, msg, color, color )
