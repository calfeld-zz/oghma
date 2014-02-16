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

Oghma.Action.prototype.roll_die =
  ( sides, x, y, is_private = false ) ->
    if is_private
      r = 18
      font_size = 18
      visible_to = [ @O.me().gets( 'name' ) ]
      if visible_to[0] != O.GM
        visible_to.push( O.GM )
    else
      r = 25
      font_size = 24
      visible_to = null
    @O.tableverse.create( 'dice',
      sides:      sides
      x:          x
      y:          y
      r:          r
      font_size:  font_size
      visible_to: visible_to
    )
    null
