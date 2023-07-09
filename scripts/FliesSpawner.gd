extends Node2D
class_name FliesSpawner

@export var fly_prefab: PackedScene
@export var max_flies := 10
@export var max_v_pos = 250.0
@export var h_margin = 50.0

var flies_count = 0
var h_limit := 0.0

@onready var timer: Timer = $Timer
@onready var store: GameStore = Store

signal fly_catched

func _ready() -> void:
  var camera := get_viewport().get_camera_2d()
  h_limit = get_viewport_rect().size.x / camera.zoom.x
  store.game_started.connect(activate)
  store.game_over.connect(deactivate)

func spawn_fly():
  var fly: Fly = fly_prefab.instantiate()
  fly.position.x = - h_margin if randi_range(0,1) == 0 else h_limit + h_margin
  fly.position.y = randf_range(0, max_v_pos)
  fly.catched.connect(on_fly_catched)
  add_child(fly)
  flies_count += 1

func _on_timer_timeout() -> void:
  if flies_count < max_flies:
    spawn_fly()

func on_fly_catched(fly: Fly):
  flies_count = maxi(0, flies_count - 1)
  fly.queue_free()
  fly_catched.emit()

func activate():
  spawn_fly()
  timer.start()

func deactivate():
  timer.stop()
