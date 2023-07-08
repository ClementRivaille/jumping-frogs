extends Node2D
class_name FrogManager

@onready var store: GameStore = Store

@export var platform_length := 200.0

var frogs: Array[Frog] = []
var platforms: Array[Platform] = []

func _ready() -> void:
  for c in $Frogs.get_children():
    frogs.push_front(c)
  for p in get_tree().get_nodes_in_group("platform"):
    platforms.append(p)
    
  store.level_up.connect(spawn_frog)
  store.game_started.connect(spawn_frog)

func spawn_frog():
  var available_frogs = frogs.filter(func (frog: Frog): return frog.freeze)
  if available_frogs.size() == 0:
    return
  var frog: Frog = available_frogs[0]
  
  var available_platform: Platform = platforms.pick_random()
  while available_platform.dragged:
    available_platform = platforms.pick_random()
  
  frog.enter_game(available_platform.position.x + platform_length / 2.0)

func on_frog_fall(frog: Frog):
  frog.set_deferred("freeze", true)
  store.level_fail()
