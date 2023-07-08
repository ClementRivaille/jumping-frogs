extends Node2D
class_name Music

signal beat(value: int)

@onready var player: meta_player = $MetaPlayer
@onready var store: GameStore = Store

var layer := 0
var playing := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  store.game_started.connect(start)
  store.level_updated.connect(update_layer)
  player.beat.connect(_on_beat)

func start():
  if !playing:
    player.mplay()
    playing = true

func update_layer(level: int):
  layer = level

func _on_beat(i: int):
  beat.emit((i-1)%player.beats_per_bar + 1)
