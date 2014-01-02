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

Oghma.Action.prototype.show_origin_marker = ( layer = 'dice' ) ->
  origin = new Kinetic.Circle(
    radius: 20
    x:      0
    y:      0
    fill:   'blue'
    stroke: 'red'
    id:     'origin_marker'
  )
  @O.layer[ layer ].add( origin )
  @O.layer[ layer ].draw()

Oghma.Action.prototype.hide_origin_marker = ( layer = 'dice' ) ->
  for obj in @O.layer[ layer ].get( '#origin_marker' )
    obj.destroy()
  @O.layer[ layer ].draw()
