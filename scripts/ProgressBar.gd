extends Control
class_name ScoreProgressBar

@onready var store: GameStore = Store
@onready var filler: Control = $Inside/Filler
@onready var timer: Timer = $Timer

var tween: Tween
var end_level := false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  store.score_updated.connect(on_score_update)
  store.level_up.connect(on_level_complete)
  filler.anchor_right = 0.0

func on_score_update(score: int):
  if store.finished || end_level:
    return

  var progress :float = float(score) / float(store.score_goal)
  if tween && tween.is_running():
    tween.kill()
  tween = create_tween()
  tween.tween_property(filler, "anchor_right", progress, 0.2
    ).set_trans(Tween.TRANS_SINE
    ).set_ease(Tween.EASE_IN_OUT)
  
func on_level_complete():
  end_level = true
  
  timer.start()
  await timer.timeout
  
  var fade_tween := create_tween()
  fade_tween.tween_property(filler, "modulate", Color.TRANSPARENT, 0.4
    ).set_trans(Tween.TRANS_SINE
    ).set_ease(Tween.EASE_IN_OUT)
  await fade_tween.finished

  filler.anchor_right = 0.0
  filler.modulate = Color.WHITE
  
  end_level = false
  
  if !store.finished && store.score > 0:
    on_score_update(store.score)
