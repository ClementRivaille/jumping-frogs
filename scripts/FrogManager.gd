extends Node2D
class_name FrogManager

@onready var store: GameStore = Store

@export var platform_length: float = 200.0

var frogs: Array[Frog] = []
var platforms: Array[Platform] = []

func _ready() -> void:
  for c in $Frogs.get_children():
    frogs.append(c)
  for p in get_tree().get_nodes_in_group("platform"):
    platforms.append(p)
    
  store.level_up.connect(spawn_frog)
  store.game_started.connect(spawn_frog)

func spawn_frog():
  if store.finished:
    return

  var available_frogs = frogs.filter(func (frog: Frog): return frog.freeze)
  if available_frogs.size() == 0:
    return
  var frog: Frog = available_frogs[0]
  
  var platform := choose_platform()
  frog.enter_game(platform.position.x + platform_length / 2.0)

func choose_platform() -> Platform:
  var available_platform: Platform = platforms.pick_random()
  while available_platform.dragged:
    available_platform = platforms.pick_random()
  return available_platform

func on_frog_fall(frog: Frog):
  if !store.game_running:
    return
  elif store.finished:
    var platform := choose_platform()
    frog.exit_game()
    frog.enter_game(platform.position.x + platform_length / 2.0)
    return
  else:
    frog.exit_game()
    store.level_fail()
