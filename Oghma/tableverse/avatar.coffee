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
Oghma.Thingy ?= {}

# Layer for avatar.
c_layer       = 'avatars'

# Local data to tell set to not redraw.
c_no_redraw = 'no_redraw'

Oghma.Thingy.Tableverse.register( ( thingyverse, O ) ->
  thingyverse.avatar = new Heron.Index.MapIndex(
    'owner',
    'name',
    'category',
    'group'
  )

  draw_layer = ->
    O.layer[ c_layer ].draw()

  show_labels = ->
    thingyverse.avatar.each( ( avatar ) ->
      avatar.show_label()
    )
  hide_labels = ->
    thingyverse.avatar.each( ( avatar ) ->
      avatar.hide_label()
    )

  min_z = null
  max_z = null
  O.on( 'join_table', ->
    # XXX Sort all avatars by z and then raise/lower appropriately.

    # XXX set min_z and max_z
  )
  # XXX on create/raise set z to max_z+1 and increment max_z.
  # XXX on lower set z to min_z-1 and decrement min_z.

  thingyverse.define(
    'avatar',
    [
      'font_size',
      'r',
      'owner',
      'name',
      'index',
      'group',
      'category',
      'fill', 'stroke',
      'token'
    ],
    {
      vis: ['visible_to' ]
      loc: [ 'x', 'y' ]
    },
    ( attrs ) ->
      @__ =
        x:          attrs.x          ? 0
        y:          attrs.y          ? 0
        font_size:  attrs.font_size  ? 12
        r:          attrs.r          ? O.current_table.g2k(1)
        owner:      attrs.owner      ? O.me().gets( 'name' )
        name:       attrs.name       ? ''
        index:      attrs.index      ? ''
        group:      attrs.group      ? 'undetermined'
        category:   attrs.category   ? 'undetermined'
        fill:       attrs.fill       ? O.me().gets( 'primary' )
        stroke:     attrs.stroke     ? O.me().gets( 'secondary' )
        token:      attrs.token      ? ''
        visible_to: attrs.visible_to ? []
        id:         attrs.id         ? Heron.Util.generate_id()

      @after_construction( ->
        thingyverse.avatar.add( this )
      )

      @is_owned = =>
        O.me().gets('name') == @__.owner

      @is_visible = =>
        @__.visible_to.length == 0 ||
        @__.visible_to.indexOf( O.me().gets( 'name' ) ) != -1 ||
        O.isGM()

      @show_label = =>
        if @is_visible() && @__k?
          tween = new Kinetic.Tween(
            node:     @__klabel,
            duration: 0.25,
            opacity:  1
          )
          tween.play()
      @hide_label = =>
        if @is_visible() && @__k?
          tween = new Kinetic.Tween(
            node:     @__klabel,
            duration: 0.25,
            opacity:  0
          )
          tween.play()

      @__redraw = =>
        @__k.destroy() if @__k?
        if @is_visible()
          @__k = new Kinetic.Group(
            x: @__.x
            y: @__.y
          )
          @__kdisk = new Kinetic.Circle(
            radius:    @__.r
            fill:      @__.fill
            stroke:    @__.stroke
          )
          @__klabel = new Kinetic.Text(
            text:     @__.name + if @__.index? then ' ' + @__.index else ''
            align:    'center'
            y:        -1 * @__.r - @__.font_size
            fill:     @__.stroke
            stroke:   null
            fontSize: @__.font_size
            opacity:  0
          )
          @__klabel.setOffset( x: @__klabel.getWidth() / 2  )
          @__k.add( @__kdisk )
          @__k.add( @__klabel )

          if @__.token != ''
            image = new Image()
            image.onload = =>
              @__ktoken = new Kinetic.Image(
                image:   image
                offsetX: @__.r
                offsetY: @__.r
                width:   2 * @__.r
                height:  2 * @__.r
              )
              @__k.add(@__ktoken)
              draw_layer()
            image.src = @__.token

          @__kdisk.on( 'click', ( e ) =>
            if e.which == 3 && ( @is_owned() || e.shiftKey )
              items = [
                {
                  text: 'Remove'
                  handler: => @remove()
                }
              ]
              if O.isGM()
                items.push('-')
                items = items.concat( Oghma.SubMenu.visibility( O, this ) )
              menu = Ext.create( 'Oghma.Ext.Menu', items: items )
              e.stopPropagation()
              menu.showAt( [ e.pageX, e.pageY ] )
          )

          @__k.on( 'mousedown', ( e ) =>
            if @is_owned() || e.shiftKey
              @__k.setDraggable(true)
          )
          @__k.on( 'dragend', ( e ) =>
            @__k.setDraggable(false)
            @set( @__k.getPosition(), c_no_redraw )
          )

          @__kdisk.on( 'mouseenter', show_labels )
          @__kdisk.on( 'mouseleave', hide_labels )

          O.layer[ c_layer ].add( @__k )

      @__redraw()
      draw_layer()

      set: (thingy, attrs, local_data) ->
        need_redraw = false
        for k, v of attrs
          if v != thingy.__[k]
            thingy.__[k] = v
            need_redraw = true
        if need_redraw && local_data != c_no_redraw
          thingy.__redraw()
          draw_layer()

        null

      get: ( thingy, keys... ) ->
        thingy.__

      remove: ( thingy ) ->
        thingyverse.avatar.remove( thingy )
        thingy.__k.destroy()
        draw_layer()
        null
    )

  O.ui_colors.on_set( ->
    O.tableverse.avatar.each( ( avatar ) ->
      avatar.__redraw()
      draw_layer()
    )
  )
)