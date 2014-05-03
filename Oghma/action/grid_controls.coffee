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

s_grid_controls = null

Oghma.Action.prototype.show_grid_controls = ( O ) ->
  if s_grid_controls?
    O.action.return_to_origin()
  else
    s_grid_controls = new Oghma.GridControls(
      layer:        O.layer.controls
      origin:       O.grid.origin()
      grid:         O.grid.grid()
      color:        O.ui_colors.value().primary
      origin_color: O.ui_colors.value().secondary
      on_change: ( origin, grid ) ->
        O.verbose( "Changing grid: origin=#{origin[0]}, #{origin[1]} grid=#{grid}" )
        O.current_table.set( origin: origin, grid: grid )
    )

Oghma.Action.prototype.update_grid_controls = ( O ) ->
  s_grid_controls?.set_color(
    O.ui_colors.value().primary,
    O.ui_colors.value().secondary
  )
  s_grid_controls?.redraw()

Oghma.Action.prototype.hide_grid_controls = ->
  s_grid_controls?.destroy()
  s_grid_controls = null

Oghma.Action.prototype.grid_controls_visible = ->
  s_grid_controls?