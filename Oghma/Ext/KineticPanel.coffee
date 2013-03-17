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

# Panel holding Kinetic stage.
#
# @author Christopher Alfeld (calfeld@calfeld.net)
# @copyright 2013 Christopher Alfeld
Ext.define( 'Oghma.Ext.KineticPanel',
  extend: 'Ext.panel.Panel'

  # The Kinetic Stage
  stage: null

  # If true, stage will automatically resize to match panel.
  autoResizeStage: true

  # Initialize stage.  Called at boxready.
  initStage: ( width, height ) ->
    @stage = new Kinetic.Stage(
      container: @body
      width:     width
      height:    height
    )

  # See ExtJS.
  initComponent: ->
    @on( 'boxready', ( it, width, height ) =>
      @initStage( width, height )

      @on( 'resize', =>
        if @autoResizeStage
          @stage.setSize( @getWidth(), @getHeight() )
      )
    )
    @callParent( arguments )

    null
)
