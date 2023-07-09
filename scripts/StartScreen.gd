extends Control
class_name StartScreen

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var store: GameStore = Store


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  animation.play("click_blink")
  
  store.game_started.connect(stop_animation)

func stop_animation():
  animation.pause()
