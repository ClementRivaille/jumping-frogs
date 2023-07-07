extends RigidBody2D
class_name Frog

@export var VFORCE = 1000.0
@export var MAX_HFORCE = 400.0

@onready var joint: PinJoint2D = $PinJoint2D

func _input(event: InputEvent) -> void:
  if event.is_action_pressed("ui_accept"):
    jump()

func jump():
  joint.node_b = "."
  apply_central_impulse(Vector2(randf_range(-MAX_HFORCE, MAX_HFORCE), -VFORCE))


func _on_body_entered(body: Node) -> void:
  if body is Platform:
    joint.node_b = body.get_path()
