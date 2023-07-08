extends Node2D
class_name Music

signal beat(value: int)
signal scale_built(notes: Array)

@export var scale_notes: Array[String] = []
@export var min_octave := 0
@export var max_octave := 3

@onready var player: meta_player = $MetaPlayer
@onready var accordion: SamplerInstrument = $Accordion
@onready var store: GameStore = Store

var layer := 0
var playing := false

var all_notes := []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  store.game_started.connect(start)
  store.level_updated.connect(update_layer)
  store.game_over.connect(on_game_over)
  player.beat.connect(_on_beat)
  player.mplay()
  
  
  build_notes()
  var platforms := get_tree().get_nodes_in_group("platform")
  for p in platforms:
    var platform: Platform = p
    platform.set_steps(all_notes.size())
    platform.move_step.connect(play_step)
  
func build_notes():
  var octave := min_octave
  var note_idx := 0
  var calculator = NoteValue
  var prev_note_value := 0
  while octave < max_octave || note_idx > 0:
    var note_name: String = scale_notes[note_idx]
    if (calculator.get_note_value(note_name, octave) < prev_note_value):
      octave = octave + 1
    all_notes.push_back([note_name, octave])
    prev_note_value = calculator.get_note_value(note_name, octave)
    note_idx = (note_idx + 1) % scale_notes.size()
  all_notes.push_back([scale_notes[0], max_octave])
  scale_built.emit(all_notes)

func start():
  layer = 1
  
func on_game_over():
  layer = 0

func update_layer(level: int):
  layer = level + 1

func _on_beat(i: int):
  beat.emit((i-1)%player.beats_per_bar + 1)

func play_step(value: int):
  var note: Array = all_notes[value]
  accordion.play_note(note[0], note[1])
