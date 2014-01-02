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

# Oghma Action Environment
#
# This class will be extended by code in action.  It provides "actions",
# code that modifies the table, with this class serving as a holding location
# and environment.
#
# @author Christopher Alfeld (calfeld@calfeld.net)
# @copyright 2013 Christopher Alfeld
class Oghma.Action
  # Oghma.App
  O: null

  # Constructor.
  #
  # @param [Oghma.App] O Oghma.App instance.
  constructor: ( O ) ->
    @O = O
