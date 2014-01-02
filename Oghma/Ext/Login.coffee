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

# Login Window
#
# @author Christopher Alfeld (calfeld@calfeld.net)
# @copyright 2013 Christopher Alfeld
Ext.define( 'Oghma.Ext.Login',
  extend: 'Ext.window.Window'

  # Context
  #
  # - userverse
  O: false

  # Called with username if login button is pressed.
  onLogin: false

  # Call if create button is pressed.
  onCreate: false

  # See ExtJS.
  initComponent: ->
    throw 'onLogin required.' if ! @onLogin
    throw 'onCreate required.' if ! @onCreate
    throw 'O required.' if ! @O

    users = @O.allverse.user.each_name()

    form = Ext.create( 'Ext.form.Panel',
      layout: 'anchor'
      defaults:
        anchor: '100%'
      items: [
        xtype:      'combo'
        editable:   false
        store:      users
        allowBlank: false
      ]
      buttons: [
        {
          disabled: true
          formBind: true
          text: 'Login'
          handler: =>
            user = form.child( 'combo' ).getValue()
            if user?
              @onLogin( user )
        },
        {
          text: 'Create'
          handler: =>
            @onCreate()
        }
      ]
    )

    Ext.apply( this,
      title:    'Oghma Login'
      width:    400
      closable: false
      layout:   'fit'
    )

    @callParent( arguments )

    @add( form )
)