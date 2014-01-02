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


Oghma.bind_keys = ( O ) ->
  dice_map =
    '1': 20
    '2': 4
    '3': 6
    '4': 8
    '5': 10
    '6': 12
    '0': 100

  bind_both = ( key, handler ) ->
    O.table.addBinding(
      key:     key
      ctrl:    false
      handler: handler
    )
    O.keymap.addBinding(
      key:     key
      ctrl:    true
      handler: handler
    )

  for k, sides of dice_map
    do ( sides ) ->
      O.table.addBinding(
        key:  k
        ctrl: false
        handler: ( x, y, k, e ) ->
          O.action.roll_die( sides, x, y, e.shiftKey )
      )
      O.keymap.addBinding(
        key:  k
        ctrl: true
        handler: ->
          O.table.load_dropper( ( x, y, e ) ->
            O.action.roll_die( sides, x, y, e.shiftKey )
          )
      )

  # +
  bind_both( 187, -> O.table.increaseZoom() )
  # -
  bind_both( 189, -> O.table.decreaseZoom() )

  # Escape
  bind_both( 27, -> O.table.unload_dropper() )

  # Return to origin
  bind_both( 'o', -> O.action.return_to_origin() )
  null
