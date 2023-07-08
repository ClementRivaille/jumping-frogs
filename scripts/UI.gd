extends CanvasLayer
class_name UI

@onready var start_screen: Control = $Start
@onready var store: GameStore = Store

func _input(event: InputEvent) -> void:
  if event.is_action_pressed("ui_accept") && !store.game_running:
    start()

func start():
  store.start_game()
  start_screen.visible = false
