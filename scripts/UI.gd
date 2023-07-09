extends CanvasLayer
class_name UI

@onready var start_screen: Control = $Start
@onready var gameover: Control = $"Game Over"
@onready var thanks: Control = $Thanks
@onready var store: GameStore = Store

@export var cursor_default: Texture2D
@export var cursor_drag: Texture2D
@export var cursor_drop: Texture2D

func _ready() -> void:
  Input.set_custom_mouse_cursor(cursor_default)
  
  store.game_over.connect(on_game_over)
  store.complete.connect(on_finished)
  
  var platforms := get_tree().get_nodes_in_group("platform")
  for p in platforms:
    var platform: Platform = p
    platform.drag_hover.connect(set_cursor_drag)
    platform.drag_on.connect(set_cursor_drop)
    platform.drag_exit.connect(set_cursor_default)

func _input(event: InputEvent) -> void:
  if !store.game_running && event is InputEventMouseButton && event.is_pressed():
    start()

func start():
  store.start_game()
  start_screen.visible = false
  gameover.visible = false
  
func on_game_over():
  gameover.visible = true
func on_finished():
  thanks.visible = true

func set_cursor_drag():
  Input.set_custom_mouse_cursor(cursor_drag)
func set_cursor_drop():
  Input.set_custom_mouse_cursor(cursor_drop)
func set_cursor_default():
  Input.set_custom_mouse_cursor(cursor_default)
  
