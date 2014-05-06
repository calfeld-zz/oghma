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

# Services for creating drawings by specifying two points.
#
# Once a drawing is defined, it follows the following canonical lifecycle.
#
# 1. Load.  The drawing is specified along with initial attributes and loaded
#    into the dropper.
# 2. Create.  The create function is called with any attributes provided at
#    load and with points A and B set to the mouse down location.
# 3. Update.  As the mouse moves, the update function is called with updated
#    A and B locations.  If alt is not held, B is moved.  If alt is held,
#    then both are moved.
# 4. Finish.  When mouse up, the kinetic group is destroyed, and the
#    drawing finish function is called with the final A and B.  It is expected
#    that the finish function will create a thingy to instantiate a permanent
#    drawing.
#
# @author Christopher Alfeld (calfeld@calfeld.net)
# @copyright 2013 Christopher Alfeld
class Oghma.TwoPoint
  # Constructor.
  #
  # @param [Oghma.App] O Oghma App.
  # @param [Kinetic.Layer] layer Layer to draw on.
  constructor: ( O, layer ) ->
    @_ =
      O: O
      layer: layer
      shapes: {}

  # Define a drawing.
  #
  # @param [string] name Name of shape.  Must be unique.
  # @param [function] create Create function.  Passed same arguments as
  #        {#create}.
  # @param [function] update Update function.  Passed same arguments as
  #        {#update}.
  # @param [function] finish Finish function.  Passed same arguments as
  #        {#finish}.
  # @return [Oghma.TwoPoint] this
  define: ( name, create, update, finish ) ->
    @_.shapes[name] =
      create: create
      update: update
      finish: finish
    this

  # Load a drawing into the dropper.
  #
  # @param [string] name Name of drawing to load.
  # @param [object] attrs Initial attributes.
  # @return [Oghma.TwoPoint] this
  load: ( name, attrs ) ->
    group = null
    data = null
    A = null
    B = null
    prev = null

    unload = =>
      group?.destroy()
      group = null
      @_.layer.draw()
      null

    move = ( x, y, event ) =>
      if group?
        if ! event.altKey
          B = [ x, y ]
        else
          dx = x - prev[0]
          dy = y - prev[1]
          A = [ A[0] + dx, A[1] + dy ]
          B = [ B[0] + dx, B[1] + dy ]
        @update( name, data, attrs, A, B )
        @_.layer.draw()
        prev = [ x, y ]
      null

    up = ( x, y, event ) =>
      B = [ x, y ]
      group?.destroy()
      group = null
      @_.layer.draw()
      @finish( name, attrs, A, B )
      if event.altKey
        @load( name, attrs )
      null

    down = ( x, y ) =>
      group = new Kinetic.Group()
      @_.layer.add( group )
      A = [ x, y ]
      B = A
      prev = A
      data = @create( name, group, attrs, A, B )
      group.draw()

      null

    @_.O.table.load_dropper( up, down, move, unload )
    this

  # Call create function of drawing.
  #
  # @param [string] name Name of drawing to create.
  # @param [Kinetic.Group] group Group drawing should place objects in.
  # @param [object] attrs Initial attributes.
  # @param [array<float, float>] A Initial value of A point.
  # @param [array<float, float>] B Initial value of B point.
  # @return [object] Data to pass to {#update}.
  create: ( name, group, attrs, A, B ) ->
    @_.shapes[name].create( name, group, attrs, A, B )

  # Call update function of drawing.
  #
  # @param [string] name Name of drawing to create.
  # @param [object] data Data returned by {#create}.
  # @param [object] attrs Initial attributes.
  # @param [array<float, float>] A Current value of A point.
  # @param [array<float, float>] B Current value of B point.
  # @return [Oghma.TwoPoint] this
  update: ( name, data, attrs, A, B ) ->
    @_.shapes[name].update( data, attrs, A, B )
    this

  # Call finish function of drawing.
  #
  # @param [string] name Name of drawing to create.
  # @param [object] attrs Initial attributes.
  # @param [array<float, float>] A Final value of A point.
  # @param [array<float, float>] B Final value of B point.
  # @return [Oghma.TwoPoint] this
  finish: ( name, attrs, A, B ) ->
    @_.shapes[name].finish( name, attrs, A, B )
    this
