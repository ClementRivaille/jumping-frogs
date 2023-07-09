extends CanvasLayer
class_name UI

@onready var start_screen: Control = $Start
@onready var messages: Control = $Messages
@onready var progress_bar: ScoreProgressBar = $ProgressBar
@onready var message_text: Label = $Messages/Label
@onready var store: GameStore = Store
@onready var timer: Timer = $Timer

@export var cursor_default: Texture2D
@export var cursor_drag: Texture2D
@export var cursor_drop: Texture2D

@export_multiline var end_text := ""
@export_multiline var game_over_text := ""
@export_multiline var tutorial_text := ""

var lock_tween: Tween

func _ready() -> void:
  Input.set_custom_mouse_cursor(cursor_default)
  
  store.game_over.connect(on_game_over)
  store.complete.connect(on_finished)
  store.tutorial_end.connect(on_tutorial_end)
  
  start_screen.visible = true
  
  message_text.text = tutorial_text
  
  var platforms := get_tree().get_nodes_in_group("platform")
  for p in platforms:
    var platform: Platform = p
    platform.drag_hover.connect(set_cursor_drag)
    platform.drag_on.connect(set_cursor_drop)
    platform.drag_exit.connect(set_cursor_default)
    
  var frogs := get_tree().get_nodes_in_group("frog")
  for f in frogs:
    var frog: Frog = f
    frog.mouse_hover.connect(set_cursor_drag)
    frog.mouse_exit.connect(set_cursor_default)

func _input(event: InputEvent) -> void:
  if !store.game_running && event is InputEventMouseButton && event.is_pressed():
    start()

func start():
  store.start_game()
  if start_screen.modulate.a > 0.0:
    fade(start_screen, false)
  else:
    if lock_tween && lock_tween.is_running():
      await lock_tween.finished
    await fade(messages, false).finished
    fade(progress_bar, true)
  
func on_game_over():
  lock_tween = fade(progress_bar, false, 0.3)
  await lock_tween.finished
  if store.game_running:
    return
  message_text.text = game_over_text
  lock_tween = fade(messages, true)
  

func on_finished():
  await fade(progress_bar, false).finished
  message_text.text = end_text
  fade(messages, true)

func set_cursor_drag():
  Input.set_custom_mouse_cursor(cursor_drag)
func set_cursor_drop():
  Input.set_custom_mouse_cursor(cursor_drop)
func set_cursor_default():
  Input.set_custom_mouse_cursor(cursor_default)
  
func fade(screen: Control, fade_in: bool, duration := 0.4) -> Tween:
  var tween := create_tween()
  tween.tween_property(screen, "modulate", Color.WHITE if fade_in else Color.TRANSPARENT, duration
    ).set_ease(Tween.EASE_IN_OUT
    ).set_trans(Tween.TRANS_SINE)
  return tween
  
func on_tutorial_end():
  timer.start()
  await timer.timeout
  await fade(messages, false).finished
  fade(progress_bar, true)
