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

# Console Window
#
# A simple window to display messages.
#
# @author Christopher Alfeld (calfeld@calfeld.net)
# @copyright 2013 Christopher Alfeld
Ext.define( 'Oghma.Ext.Console',
  extend: 'Ext.window.Window'

  # See ExtJS.
  initComponent: ->
    @_ ?= {}

    @_.messages = Ext.create( 'Ext.form.Panel',
      autoScroll: true
    )

    Ext.apply( this,
      title:    'Console'
      width:    200
      height:   200
      layout:   'fit'
      closeAction: 'hide'
      items: [ @_.messages ]
    )

    @callParent( arguments )

    null

  # Add raw html to console.
  #
  # @param [string] html HTML to add.
  # @return [Oghma.Ext.Console] this
  raw: ( html ) ->
    @_.messages.add( border: false, html: html )
    @_.messages.doLayout()
    @_.messages.body?.scroll( 'down', 10000000 )
    this

  # Add message to console.
  #
  # @param [string] from          Who message is from.
  # @param [string] msg           Message.
  # @param [string] from_color    Color to display from text in; in hex;
  #   default '000000'.
  # @param [string] message_color Color to display message in; in hex;
  #   default '00000'.
  message: ( from, message, from_color = '000000', message_color = '000000') ->
    escape = ( s ) ->
      jQuery('<div/>').text(s).html()
    @raw(
      "<span style=\"color:#{from_color}\">#{escape(from)}</span>: " +
      " <span style=\"color:#{message_color}\">#{escape(message)}</span>"
    )
)
