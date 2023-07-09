extends StaticBody2D
class_name Platform

@export var min_pos := 0.0
@export var max_pos := 1000.0

var dragged := false
var mouse_inside := false
var pos_diff := 0.0

var nb_steps := 2
var step_length := 10.0
var last_step := 0

signal move_step(step: int)
signal drag_hover
signal drag_on
signal drag_exit

func _input(event: InputEvent) -> void:
  if event is InputEventMouseButton:
    if event.is_pressed() && mouse_inside:
      dragged = true
      pos_diff = get_viewport().get_mouse_position().x - global_position.x
      drag_on.emit()
    elif dragged && !event.is_pressed():
      dragged = false
      if mouse_inside:
        drag_hover.emit()
      else:
        drag_exit.emit()
      
func calc_step() -> int:
  return mini(floori((position.x - min_pos) / (step_length)), nb_steps - 1)

func _process(_delta: float) -> void:
  if dragged:
    position.x = clampf(get_viewport().get_mouse_position().x - pos_diff, min_pos, max_pos)
    pos_diff = get_viewport().get_mouse_position().x - global_position.x
    
    var step := calc_step()
    if step != last_step:
      move_step.emit(step)
      last_step = step

func _on_mouse_entered() -> void:
  mouse_inside = true
  if !dragged:
    drag_hover.emit()
func _on_mouse_exited() -> void:
  mouse_inside = false
  if !dragged:
    drag_exit.emit()

func set_steps(nb: int):
  nb_steps = nb
  step_length = (max_pos - min_pos) / float(nb_steps)
  last_step = calc_step()
