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

# Base class for table thingies, i.e., those drawn with Kinetic.
#
# This class provides a variety of common behaviors for the Oghma table
# thingies.  It is used by deriving from it and then providing an instance of
# the derived class as the Thingy delegate.  At its most basic, only {#draw}
# needs to be overridden, although most thingies also override
# {#remove} to keep indices updated.
#
# Every Kinetic Thingy has a "standard set" of attributes:
# - x, y: The center of the drawing.  Default: 0, 0.
# - owner: The name of the user that owns the thingy.  Owners can (usually)
#   move the thingy by dragging and access the context menu.  Default:
#   name of current user.
# - locked: If true, the thingy cannot be moved.  Default: false.
# - visible_to: List of names of users the thingy is visible to.  An empty
#   list means all users.  Default: empty
# - zindex: An integer that determines the stacking order of thingies in the
#   layer.  Default: An integer large enough to put the thingy above all other
#   currently existing thingies in the layer.
#
# To use, subclass and implement {#draw}.  The super of {#draw} should
# never be called.  You may implement other methods.  In most cases, the super
# of such methods should be called.  This class is designed to give subclasses
# significant power to override behavior.  However, it is difficult to do so
# without understanding the code in this file.
#
# When overriding methods, use {#group}} to access the top {Kinetic.Group}
# to draw in; {#thingy}} to access the thingy the delegate is for, and
# {#O} to access the Oghma application.
#
# Provided behavior is:
#
# - Movement: Can be dragged to move.
# - Context Menu: Right click displays a context menu allowing a variety of
#   manipulations.
# - Visibility: Can be visible to a subset of users.
# - Owner: Owned by a single user who alone has the ability to change.
#   Ownership can be overridden by holding shift.
# - ZIndex: Cooperates with a ZIndex to allow layering control.
# - Lock: Can be locked to prevent movement.
# - Thingy Methods: The thingy is extended with several useful methods.  See
#  {#extend_thingy()]
#
# @author Christopher Alfeld (calfeld@calfeld.net)
# @copyright 2014 Christopher Alfeld
class Oghma.KineticThingyDelegate
  # Construct a new delegate.
  #
  # Overriding: May be overridden to perform actions at creation, however,
  # it is generally easier to do so in the initializer.  Call super as soon as
  # possible and before using any provided methods.
  #
  # @param [Oghma.App] O Oghma application.
  # @param [Heron.Thingy] thingy Thingy to be delegate for.
  # @param [Kinetic.Layer] layer Layer to draw in.
  # @param [Oghma.ZIndex] zindex ZIndex to participate in.
  # @param [list<string>] draw_attrs Attributes that require a redraw if
  #   changed.
  # @param [object] attrs  Initial attributes.
  constructor: ( O, thingy, layer, zindex, draw_attrs, attrs ) ->
    @__kt =
      O:          O
      thingy:     thingy
      layer:      layer
      zindex:     zindex
      group:      new Kinetic.Group(
                    x: attrs.x ? 0
                    y: attrs.y ? 0
                  )
      group_in_layer: false

    @setup( draw_attrs, attrs )

    # ZIndex support.
    thingy._raise = =>
      @group().moveToTop() if @is_drawn()
      @thingy()
    thingy._lower = =>
      @group().moveToBottom() if @is_drawn()
      @thingy()

    @extend_thingy()

    thingy.after_construction( =>
      zindex.register( thingy )
      @bind()
      @redraw()
    )


  # Thingy delegate methods

  # See {Heron.ThingyDelegate#set}
  #
  # If `local_attrs` contains a `no_redraw` member, no redrawing will occur.
  set: ( thingy, attrs, local_attrs ) ->
    need_redraw = false
    new_zindex = null
    for k, v of attrs
      if k == 'zindex'
        new_zindex = v
      if @__kt.draw_attrs[k]
        need_redraw = true
      @__kt.attrs[k] = v
    if new_zindex?
      @__kt.zindex.update( thingy )
    if need_redraw && ! local_attrs.no_redraw?
      @redraw()
    this

  # See {Heron.ThingyDelegate#get}
  get: ( thingy, keys... ) ->
    @__kt.attrs ? throw 'Missing implementation of get.'

  # See {Heron.ThingyDelegate#remove}
  remove: ( thingy ) ->
    @group().destroy()
    @draw_layer()
    @__kt.zindex.unregister( thingy )

  # Accessor methods.  Do not override.

  # Oghma Application
  # @return [Oghma.App] Oghma application.
  O:      -> @__kt.O

  # Kinetic Group
  # @return [Kinetic.Group] Kinetic group to draw in.
  group:  -> @__kt.group

  # Kinetic Layer
  # @return [Kinetic.Layer] Kinetic layer group is in.
  layer:  -> @__kt.layer

  # ZIndex
  # @return [Oghma.ZIndex] ZIndex participating in.
  zindex: -> @__kt.zindex

  # Thingy
  # @return [Oghma.Thingy] Thingy delegate for.
  thingy: -> @__kt.thingy

  # Convenience methods.  Do not override.

  # Name of current user.
  # @return [string] Name of current user.
  current_user_name: -> @__kt.O.me().gets( 'name' )

  # Tell the layer to draw.
  # @return [Oghma.KineticThingyDelegate] this
  draw_layer: -> @layer().draw(); this

  # Does current user want to show hidden?
  show_hidden: -> @__kt.O.me().gets( 'show_hidden' )

  # Does current user want to show all?
  show_all: -> @__kt.O.me().gets( 'show_all' )

  # Required Methods

  # Draw the thingy.
  #
  # Overriding: This method *must be overridden*.  Super should never be
  # called.  The method should create any kinetic objects needed to visually
  # represent the thingy and add them to the group ({#group}).  This method
  # may be called multiple times.  Subsequent calls should either update
  # existing objects or destroy them and create new ones.
  #
  # @return [any] Ignored.
  draw: ->
    throw 'Missing implementation of draw.'

  # Optional methods.

  # Called to "draw" the visibility.
  #
  # Overriding: This method may be overridden if alternate styling is
  # desired.
  #
  # Public objects are shown normally, otherwise objects are shown not at all
  # or transparently depending on {#show_hidden} and {#show_all}.  If
  # {#show_all}, all objects are shown even if not normally visible to user.
  # If {#show_hidden}, hidden objects (not visible but owned) are shown.
  #
  # This method is called automatically from {#redraw}.
  #
  # @param [string] visibility Visibility to draw.
  # @return [Oghma.KineticThingyDelegate] this
  draw_visibility: ( visibility ) ->
    if ! @is_drawn()
      @group().remove() if @__kt.group_in_layer
      @__kt.group_in_layer = false
    else
      @layer().add( @group() ) if ! @__kt.group_in_layer
      @__kt.group_in_layer = true
      if visibility == 'public'
        @group().setOpacity( 1.0 )
      else if visibility == 'none'
        @group().setOpacity( 0.33 )
      else
        @group().setOpacity( 0.66 )
    this

  # Determine visibility.
  #
  # Overriding: This method may be overridden to provide a different
  # visibility policy.  It could also be overridden to add additional
  # possibilities, in which case {#draw_visibility} should also be
  # overridden.
  #
  # The `visible_to`, `owner`, and current user interact to determine the
  # visibility.  This method returns the current visibility.  See
  # {#draw_visibility} for doing something with it.
  #
  # Possibilities are:
  # - `public` if object is visible to everyone.
  # - `shared` if object is visible to more than one user, including current.
  # - `private` if object is visible only to current user.
  # - `hidden` if object is not visible to current user but is owned by
  #    current user.
  # - `none` if none of the above.
  visibility: ->
    if @is_visible()
      if @is_public()
        return 'public'
      else if @visible_to().length == 1
        return 'private'
      else
        return 'shared'
    else if @is_hidden()
      return 'hidden'
    else
      return 'none'

  # Redraw the object.
  #
  # Overriding: This method may be overriden, but there is no clear reason to.
  #
  # This method calls {#visibility}, {#draw_visibility}, {#draw}, and
  # {#draw_layer} and updates the position of the group.
  #
  # @param [bool] draw_layer If true, tell layer to draw itself.
  #   Default: true
  # @return [Oghma.KineticThingyDelegate] this
  redraw: ( draw_layer = true ) ->
    @draw_visibility( @visibility() )
    @group().setPosition( @x(), @y() )
    @draw()
    @draw_layer() if draw_layer
    this

  # Setup common attributes.
  #
  # Overriding: This method should be overridden if the standard attributes
  # are not wanted or are wanted with different names.  In that case, the
  # methods based on those attributes must also be overriden: {#owner},
  # {#visible_to}, {#locked}, {#x}, {#y}, #{zindex}.  In addition, the
  # automatic implementations of {#get} and {#set} will not work and must be
  # overriden.  If overriden, super should not be called for this method or
  # any of the methods mentioned above.
  #
  # @param [array<string>] draw_attrs Which attributes require a redraw if
  #   changed.  'x' and 'y' are automatic and do not need to be included.
  # @param [object] attrs Initial attributes.
  # @return [Oghma.KineticThingyDelegate] this
  setup: ( draw_attrs, attrs ) ->
    @__kt.attrs = attrs
    @__kt.attrs.x          ?= 0
    @__kt.attrs.y          ?= 0
    @__kt.attrs.owner      ?= @O().me().gets( 'name' )
    @__kt.attrs.visible_to ?= []
    @__kt.attrs.locked     ?= false
    @__kt.attrs.zindex     ?= @__kt.zindex.acquire_top_index()

    @__kt.draw_attrs = { x: true, y: true, visible_to: true, zindex: true }
    for key in draw_attrs
      @__kt.draw_attrs[ key ] = true
    this

  # X coordinate of center.
  # @return [float] X coordinate of center.
  x:            -> @__kt.thingy.gets( 'x' )

  # Y coordinate of center.
  # @return [float] Y coordinate of center.
  y:            -> @__kt.thingy.gets( 'y' )

  # Name of owning user.
  # @return [string] Name of owning user.
  owner:        -> @__kt.thingy.gets( 'owner' )

  # List of names of users visible to.
  # @return [array<string>] Names of users visible to.
  visible_to:   -> @__kt.thingy.gets( 'visible_to' )

  # True if locked.
  # @return [bool] True if locked.
  locked:       -> @__kt.thingy.gets( 'locked' )

  default_thingy_methods = [
    'redraw',
    'is_locked', 'is_public', 'is_visible', 'is_hidden', 'is_owned',
    'raise', 'lower',
    'redraw',
    'visibility'
  ]

  # Add common methods to thingy.
  #
  # Overriding: This can be overriden if a subset of the methods are wanted.
  # In that case, call super with a list of which methods are desired.
  #
  # By default, the following methods are added to the thingy, each behaves
  # as the same method of this class: {#redraw}, {#is_locked}, {#is_public},
  # {#is_visible}, {#is_hidden}, {#is_owned}, {#raise}, {#lower}, {#redraw},
  # {#visibility}.
  #
  # @param [array<string>] what Which methods to add.
  # @return [Oghma.KineticThingyDelegate] this
  extend_thingy: ( what = default_thingy_methods ) ->
    for f in what
      do ( f ) =>
        @thingy()[ f ] = => this[ f ]()
    this


  # Raise to top.
  #
  # Overriding: Do not override; instead, override {#set} and check for
  # `zindex` set.
  #
  # Convenience method to set the `zindex` attribute to a number high enough
  # to put thingy on top.
  #
  # @return [Oghma.KineticThingyDelegate] this
  raise: ->
    @thingy().set( zindex: @__kt.zindex.acquire_top_index() )
    this

  # Lower to top.
  #
  # Overriding: Do not override; instead, override {#set} and check for
  # `zindex` set.
  #
  # Convenience method to set the `zindex` attribute to a number low enough
  # to put thingy on bottom.
  #
  # @return [Oghma.KineticThingyDelegate] this
  lower: ->
    @thingy().set( zindex: @__kt.zindex.acquire_bottom_index() )

  # Setup event bindings.
  #
  # Overriding: Good method to override to add additional bindings.  Be sure
  # to call super or {#bind_context_menu} and {#bind_drag} if you want the
  # normal bindings too.
  #
  # @return [Oghma.KineticThingyDelegate] this
  bind: ->
    @bind_context_menu()
    @bind_drag()
    this

  # Setup event bindings for context menu.
  #
  # Overriding: Consider overriding {#bind} instead.
  #
  # @return [Oghma.KineticThingyDelegate] this
  bind_context_menu: ->
    @group().on( 'click', ( event ) => @context_menu( event ) )
    this

  # Setup event bindings for dragging.
  #
  # Overriding: Consider overriding {#bind} instead.  If you want to disable
  # or otherwise control drag behavior, override {#is_dragable} instead.
  #
  # @return [Oghma.KineticThingyDelegate] this
  bind_drag: ->
    @group().on( 'mousedown', ( event ) =>
      if @is_dragable( event )
        @group().setDraggable( true )
    )
    @group().on( 'mouseup', => @group().setDraggable( false ) )
    @group().on( 'dragend', ( event ) =>
      @thingy().set( @group().getPosition(), no_redraw: true )
    )
    drag_start_pos = null
    @group().on( 'dragstart', => drag_start_pos = @group().getPosition() )
    @group().on( 'dragmove', ( event ) =>
      if @is_grid_controlled()
        pos = @group().getPosition()
        new_pos = O.grid.nearest(
          [ pos.x, pos.y ],
          [ drag_start_pos.x, drag_start_pos.y]
        )
        if new_pos[0] != pos.x or new_pos[1] != pos.y
          @group().setPosition( x: new_pos[0], y: new_pos[1] )
    )
    this

  # Return list of standard context menu items.
  #
  # Overriding: Override to change/add context menu items.  Use super and
  # append/prepend if you want to add to the normal menu.
  #
  # @return [array<object>] Standard context meny items.
  context_menu_items: ->
    [
      {
        text: 'Remove'
        handler: => @thingy().remove()
      },
      {
        text: 'Raise to top'
        handler: => @raise()
      },
      {
        text: 'Lower to bottom'
        handler: => @lower()
      },
      '-'
    ].concat( Oghma.SubMenu.visibility( @O(), @thingy() ) ).concat(
      {
        text: 'Owner'
        menu: Oghma.SubMenu.users( O, 'single', @thingy().gets( 'owner' ),
          ( name ) =>
            @thingy().set( owner: name )
        )
      },
      {
        text: 'Locked'
        checked: @thingy().gets( 'locked' )
        checkHandler: ( item, checked ) =>
          @thingy().set( locked: checked )
      }
    )

  # Display context menu.
  #
  # Overriding: Override if you want custom context menu (right click)
  # behavior.  Alternately, override {#bind} to prevent {#bind_context_menu}
  # and add your own `click` binding.
  #
  # @param [Ext.Event] event Event triggering context menu.
  # @return [Oghma.KineticThingyDelegate] this
  context_menu: ( event ) ->
    if @is_context_menuable( event )
      menu = Ext.create( 'Oghma.Ext.Menu', items: @context_menu_items() )
      event.evt.stopPropagation()
      menu.showAt( [ event.evt.pageX, event.evt.pageY ] )
    this

  # Policy methods.  Override to change policies.

  # Is thingy currently owned?
  # @return [bool] Is thingy currently owned?
  is_owned: ->
    @owner() == @current_user_name()

  # Is thingy visible to everyone?
  # @return [bool] Is thingy visible only to current user?
  is_public: ->
    @visible_to().length == 0

  # Is thingy hidden: owned but not visible?
  # @return [bool] Is thingy hidden: owned but not visible?
  is_hidden: ->
    ! @is_visible() && @is_owned()

  # Is thingy visible to current user?
  # @return [bool] Is thingy visible to current user?
  is_visible:  ->
    vt = @visible_to()
    vt.length == 0 || vt.indexOf( @current_user_name() ) != -1

  # Is thingy locked?
  # @return [bool] Is thingy locked?
  is_locked: ->
    @locked()

  # Is thingy dragable?
  # @return [bool] Is thingy dragable?
  is_dragable: ( event ) ->
    @is_drawn() && ! @is_locked() && ( event.evt.shiftKey || @is_owned() )

  # Is thingy drawn?
  # @return [bool] Is thingy drawn?
  is_drawn: ->
    @show_all() || ( @visibility() == 'hidden' && @show_hidden() ) || ( @visibility() != 'hidden' && @visibility() != 'none' )

  # Is thingy context menuable?
  # @return [bool] Is thingy context menuable?
  is_context_menuable: ( event ) ->
    event.evt.which == 3 && @is_drawn() && ( ( ! @is_locked() && @is_owned() ) || event.evt.shiftKey )

  # Is thingy controlled by grid mode.
  # @return [bool] Is thingy controlled by grid mode.
  is_grid_controlled: ->
    true

