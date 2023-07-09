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
  
  start_screen.visible = true
  
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
  if start_screen.modulate.a > 0.0:
    fade(start_screen, false)
  else:
    fade(gameover, false, 0.2)
  
func on_game_over():
  fade(gameover, true, 0.2)
func on_finished():
  fade(thanks, true)  

func set_cursor_drag():
  Input.set_custom_mouse_cursor(cursor_drag)
func set_cursor_drop():
  Input.set_custom_mouse_cursor(cursor_drop)
func set_cursor_default():
  Input.set_custom_mouse_cursor(cursor_default)
  
func fade(screen: Control, fade_in: bool, duration := 0.4):
  var tween := create_tween()
  tween.tween_property(screen, "modulate", Color.WHITE if fade_in else Color.TRANSPARENT, duration
    ).set_ease(Tween.EASE_IN_OUT
    ).set_trans(Tween.TRANS_SINE)
