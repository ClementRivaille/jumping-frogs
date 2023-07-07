extends RigidBody2D
class_name Frog

@export var VFORCE = 1000.0
@export var MAX_HFORCE = 400.0

func _input(event: InputEvent) -> void:
  if event.is_action_pressed("ui_accept"):
    jump()

func jump():
  apply_central_impulse(Vector2(randf_range(-MAX_HFORCE, MAX_HFORCE), -VFORCE))
