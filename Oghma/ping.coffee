# Copyright 2014 Christopher Alfeld
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


# One of these is chosen at random.
# K is the kinetic group to add to.
# color is the color.
# finish is a function to call when done.
c_animations = []

c_animations.push(
  ( K, color, finish ) ->
    star = new Kinetic.Star(
      x:           0
      y:           0
      numPoints:   20
      outerRadius: 70
      innerRadius: 70
      stroke:      color
      strokeWidth: 0.5
      lineJoin:    'bevel'
    )
    K.add( star )
    tween = new Kinetic.Tween(
      node:        star
      duration:    4
      innerRadius: 0
      easing:      Kinetic.Easings.EaseInOut
      onFinish:    finish
    )

    tween.play()
)

c_animations.push(
  ( K, color, finish ) ->
    star = new Kinetic.Star(
      x:           0
      y:           0
      numPoints:   8
      outerRadius: 70
      innerRadius: 0
      stroke:      color
      strokeWidth: 0.5
      lineJoin:    'bevel'
    )
    K.add( star )
    tween = new Kinetic.Tween(
      node:     star
      duration: 4
      rotation: 360
      easing:   Kinetic.Easings.EaseInOut
      onFinish: finish
    )

    tween.play()
)

# Visually a ping a location.
#
# @param [Kinetic.Layer] layer Layer to draw in.
# @param [string] color Color of ping.
# @param [Float] x X location of ping.
# @param [Float] y Y location of ping.
# @return null
Oghma.ping = ( layer, color, x, y ) ->
  K = new Kinetic.Group( x: x, y: y )
  layer.add( K )

  i = Math.floor( Math.random() * c_animations.length )
  c_animations[i]( K, color,
    ->
      K.destroy()
      layer.draw()
  )

  null

