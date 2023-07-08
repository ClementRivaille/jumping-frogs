extends Control
class_name Debug

@onready var score_label: Label = $Score
@onready var level_label: Label = $Level
@onready var event_label: Label = $Event
@onready var store: GameStore = Store

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  store.score_updated.connect(on_update_score)
  store.level_updated.connect(on_update_level)
  store.game_over.connect(on_game_over)
  store.complete.connect(on_complete)
  
func on_update_score(score: int):
  score_label.text = "%s" % score
  
func on_update_level(level: int):
  level_label.text = "%s" % level
  
func on_game_over():
  event_label.text = "GAME OVER"
  
func on_complete():
  event_label.text = "FINISHED"

