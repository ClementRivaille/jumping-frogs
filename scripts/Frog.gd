extends RigidBody2D
class_name Frog

@export var VFORCE = 1000.0
@export var MAX_HFORCE = 400.0

@onready var joint: PinJoint2D = $PinJoint2D
@onready var store: GameStore = Store

var reset_position_to := -1.0

func _input(event: InputEvent) -> void:
  if event.is_action_pressed("ui_accept"):
    jump()
    
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
  if reset_position_to > -1.0:
    state.transform.origin = Vector2(reset_position_to, state.transform.origin.y)
    reset_position_to = -1.0

func jump():
  joint.node_b = "."
  apply_central_impulse(Vector2(randf_range(-MAX_HFORCE, MAX_HFORCE), -VFORCE))


func _on_body_entered(body: Node) -> void:
  if body is Platform:
    joint.node_b = body.get_path()
  if body is Fly:
    store.catch_fly()
    var fly: Fly = body
    fly.on_catch()
    
func enter_game(xpos: float):
  freeze = false
  reset_position_to = xpos
  apply_central_impulse(Vector2(0, -1000.0))
