# Copyright 2013 Christopher Alfeld
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

# Simple ColorField for forms.
#
# @author Christopher Alfeld (calfeld@calfeld.net)
# @copyright 2013 Christopher Alfeld
Ext.define( 'Oghma.Ext.ColorField',
  extend: 'Ext.form.field.Trigger'

  showColorPicker: ( at ) ->
    value = @getValue()
    picker = Ext.create( 'Ext.menu.ColorPicker',
      value: @getValue()
      listeners:
        select: ( picker, color ) =>
          @setValue( color )
    )
    picker.showAt( at )

  onTriggerClick: ( event ) ->
    @showColorPicker( event.getXY() )

  setValue: ( color ) ->
    @callParent( arguments )
    if color?
      @setFieldStyle(
        'color':            '#' + color
        'background-color': '#' + color
        'background-image': 'none'
      )

  initComponent: ( args... ) ->
    Ext.apply( this,
      editable: false
      listeners:
        focus: ( event ) => @showColorPicker( @getPosition() )
    )
    @callParent( args )
)