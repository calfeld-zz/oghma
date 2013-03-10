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
Oghma.Menu ?= {}

# Zoom menu.
#
# @param [Oghma.App] App.
# @return [Ext.menu.Menu] Zoom menu.
#
# @author Christopher Alfeld (calfeld@calfeld.net)
# @copyright 2013 Christopher Alfeld
Oghma.Menu.zoom = ( O ) ->
  to_text = ( zoom ) -> Math.floor( zoom * 100 )
  items = [
    {
      text: 'Zoom In'
      id:   'zoom_in'
      handler: ->
        O.table.increaseZoom()
    },
    {
      text: 'Zoom Out'
      id:   'zoom_out'
      handler: ->
        O.table.decreaseZoom()
    },
    '-'
  ]
  for zoom in O.table.zoomLevels
    do ( zoom ) =>
      text = to_text( zoom )
      items.push(
        text:    text + '%'
        id:      'zoom' + text
        checked: zoom == O.table.defaultZoom
        group:   'zoom'
        handler: ->
          O.table.setZoom( zoom )
      )

  Ext.create( 'Ext.menu.Menu',
    items: items
    listeners:
      beforeshow: ->
        current_zoom = O.table.getZoom()
        for zoom in O.table.zoomLevels
          @child( '#zoom' + to_text( zoom ) ).setChecked( zoom == current_zoom )
        current_zoom_i = O.table.zoomLevels.indexOf( current_zoom )
        @child( '#zoom_out' ).setDisabled( true )
        @child( '#zoom_in' ).setDisabled( true )
        if current_zoom_i < O.table.zoomLevels.length - 1
          @child( '#zoom_in' ).setDisabled( false )
        if current_zoom_i > 0
          @child( '#zoom_out' ).setDisabled( false )
  )
