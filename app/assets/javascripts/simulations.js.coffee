# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

#FUGLY!
scale_x = 0
scale_y = 0

jQuery ->
  world =  $('#world_data').data('world')
  world_ui = $("#world_ui")
  context = world_ui[0].getContext('2d')

  world_width = world.boundaries[0] - world.boundaries[1]
  world_height = world.boundaries[2] - world.boundaries[3]

  scale_x = world_ui.width()  / world_width
  scale_y = world_ui.height() / world_height

  draw_objects(context, world.obstacles)
  draw_robot(context, world.robot)


draw_objects = (context, objects) ->
  context.strokeStyle = '#00f'
  context.lineWidth   = 1
  context.fillStyle = "#88DDFF"
  for object in objects
    draw_object(context, object)

draw_robot = (context, robot) ->
  context.strokeStyle = '#f00'
  context.lineWidth   = 1
  context.fillStyle = "#FFDD88"
  draw_object(context, robot)


draw_object = (context, object) ->
  x = object.x * scale_x + 320
  y = object.y * scale_y + 240
  radius = object.radius * ( (scale_x + scale_y ) / 2)# TODO
  context.beginPath()
  context.arc(x, y, radius, 0, 2 * Math.PI, false)
  context.fill()
  context.stroke()


