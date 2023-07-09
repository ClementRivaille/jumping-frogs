extends CharacterBody2D
class_name Fly

@export var speed := 50.0
@export var speed_diff = 30.0

@onready var debug: ColorRect = $debugRect
@onready var timer: Timer = $Timer
@onready var sprite: AnimatedSprite2D = $Sprite

@export var min_y := 50.0
@export var max_y := 500.0
@export var max_x := 1100.0
@export var padding := 10.0

var destination: Vector2
var close := 2
var fly_speed = 50.0

signal catched(fly: Fly)

func _ready() -> void:
  sprite.play("default")
  pick_destination()

func pick_destination():
  destination = Vector2(randf_range(padding, max_x - padding), randf_range(padding, max_y))
  fly_speed = randf_range(speed - speed_diff, speed + speed_diff)
  timer.wait_time = randf_range(0.5, 1.6)
  timer.start()

func _process(delta: float) -> void:
  if position.distance_to(destination) < close:
    pick_destination()
  sprite.flip_h = velocity.x > 0
  
  velocity = position.direction_to(destination) * fly_speed
  debug.global_position = destination
  move_and_slide()

func on_catch():
  catched.emit(self)
