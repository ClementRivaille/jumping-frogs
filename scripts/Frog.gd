extends RigidBody2D
class_name Frog

@export var VFORCE = 1000.0
@export var MAX_HFORCE = 400.0
@export var frames: SpriteFrames

var beats_scores: Array[Array] = [
  [1],
  [1,1,2,3],
  [1,2,3]
]

@onready var joint: PinJoint2D = $PinJoint2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var store: GameStore = Store

var reset_position_to := -1.0
var in_air := true
var scheduled_jump_on := -1

signal jumped

func _ready() -> void:
  sprite.sprite_frames = frames

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
  if reset_position_to > -1.0:
    state.transform.origin = Vector2(reset_position_to, state.transform.origin.y)
    reset_position_to = -1.0
    apply_central_impulse(Vector2(0, -1000.0))
    
  if absf(state.linear_velocity.x) > MAX_HFORCE && in_air:
    state.linear_velocity = state.linear_velocity.normalized() * MAX_HFORCE
    state.linear_velocity.y = -VFORCE
    
func _process(_delta: float) -> void:
  if in_air:
    sprite.flip_h = linear_velocity.x < 0.0

func jump():
  joint.node_b = "."
  apply_central_impulse(Vector2(randf_range(-MAX_HFORCE, MAX_HFORCE), -VFORCE))
  sprite.animation = "jump"
  in_air = true
  jumped.emit()

func _on_body_entered(body: Node) -> void:
  if body is Platform:
    joint.node_b = body.get_path()
    in_air = false
    sprite.animation = "still"
    schedule_jump()
  if body is Fly:
    store.catch_fly()
    var fly: Fly = body
    fly.on_catch()
    
func enter_game(xpos: float):
  set_deferred("freeze", false)
  reset_position_to = xpos
  
func exit_game():
  set_deferred("freeze", true)
  if scheduled_jump_on != -1:
    store.return_beat(scheduled_jump_on)
    scheduled_jump_on = -1
  
func schedule_jump():
  if scheduled_jump_on != -1:
    return
  var scores: Array = beats_scores[mini(store.level, beats_scores.size() - 1)]
  var planned_jump: int = scores.pick_random()
  scheduled_jump_on = store.schedule_beat(planned_jump)
  
func on_beat(beat: int):
  if !freeze && !in_air:
    if beat == scheduled_jump_on:
      store.return_beat(scheduled_jump_on)
      scheduled_jump_on = -1
      jump()
    elif beat == 1 && scheduled_jump_on == -1:
      schedule_jump()
