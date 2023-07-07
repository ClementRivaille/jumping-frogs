extends StaticBody2D
class_name Platform

@export var min_pos := 0.0
@export var max_pos := 1000.0

var dragged := false
var mouse_inside := false
var pos_diff := 0.0

func _input(event: InputEvent) -> void:
  if event is InputEventMouseButton:
    if event.is_pressed() && mouse_inside:
      dragged = true
      pos_diff = get_viewport().get_mouse_position().x - global_position.x
    elif dragged && !event.is_pressed():
      dragged = false

func _process(_delta: float) -> void:
  if dragged:
    position.x = clampf(get_viewport().get_mouse_position().x - pos_diff, min_pos, max_pos)
    pos_diff = get_viewport().get_mouse_position().x - global_position.x

func _on_mouse_entered() -> void:
  mouse_inside = true
func _on_mouse_exited() -> void:
  mouse_inside = false

