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

Oghma = @Oghma ?= {}

root = this

# Edit Object Window
#
# @author Christopher Alfeld (calfeld@calfeld.net)
# @copyright 2013 Christopher Alfeld
Ext.define( 'Oghma.Ext.EditObject',
  extend: 'Ext.window.Window'

  # Object to edit. (Required)
  object: {}

  # Types of fields of object.
  #
  # Supported types are:
  # - color
  # - string
  # - auto
  types: {}

  # Function to call with edited object if save is pressed. (Required)
  onSave: false

  # Function to call if cancel is pressed. (Required)
  onCancel: false

  # See ExtJS.
  initComponent: ->
    Ext.apply( this,
      width:    400
      layout:   'fit' # XXX?
      listeners: [
        'close': => @onCancel()
      ]
    )

    @callParent( arguments )

    if ! @onSave
      throw 'onSave required.'
    if ! @onCancel
      throw 'onCancel required.'

    form_id = Heron.Util.generate_id()
    root.debug = form = Ext.create( 'Ext.form.Panel',
      layout: 'anchor'
      defaults:
        anchor: '100%'
      buttons: [
        {
          text: 'Save'
          disabled: true
          formBind: true
          handler: =>
            return if ! form.getForm().isValid()
            new_object = {}
            for field in form.items.items
              key = field.fieldLabel
              new_object[key] = field.getValue()
            @onSave( new_object )
        },
        {
          text: 'Cancel'
          handler: => @onCancel()
        }
      ]
    )
    fields = []
    for k, v of @object
      type = @types[k] ? 'auto'
      switch type
        when 'color'
          field = Ext.create( 'Oghma.Ext.ColorField' )
        else
          if type != 'auto' && type != 'string'
            throw "Unknown type: #{type}"
          else
            field = Ext.create( 'Ext.form.field.Text' )

      Ext.apply( field,
        fieldLabel: k
        labelStyle: 'text-transform: capitalize'
        name:       k
        allowBlank: false
      )
      field.setValue( v )

      form.add( field )

    @add( form )
)