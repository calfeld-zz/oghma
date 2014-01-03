
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
Oghma.SubMenu ?= {}

# Users sub menu.
#
# This is a dynamic menu so the items should be called and added on menu
# display.
#
# @param [Oghma.App] O App.
# @param [string] mode Either `single` or `multi`.
# @param [string or array<string>] current Currently selected user(s).
# @param [function] on_set Called when user is chosen or unchosen.  First
#   argument is user name, second argument is true iff chosen.  For `single`
#   mode, second argument is always true.
# @return [Array<Object>] Menu items to add.
#
# @author Christopher Alfeld (calfeld@calfeld.net)
# @copyright 2014 Christopher Alfeld
Oghma.SubMenu.users = ( O, mode, current, on_set ) ->
  # users = O.allverse.user.each_name()
  # logged_in = O.allverse.login.each_name()

  id = Heron.Util.generate_id()

  make_item = ( name ) ->
    if mode == 'single'
      text: name
      checked: current == name
      group: id
      handler: -> on_set( name )
    else if mode == 'multi'
      text: name
      checked: current.indexOf(name) != -1
      checkHandler: ( item, checked ) ->
        on_set( name, checked )
    else
      throw "Unsupported mode: #{mode}"

  items = []
  logged_in = {}
  for n in O.allverse.login.each_name().sort()
    items.push( make_item( n ) )
    logged_in[ n ] = true

  items.push( '-' )

  for n in O.allverse.user.each_name().sort()
    items.push( make_item( n ) ) if ! logged_in[ n ]?

  items




