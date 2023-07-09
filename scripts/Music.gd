extends Node2D
class_name Music

signal beat(value: int)
signal scale_built(notes: Array)

enum InstrumentKind {
  FROG,
  FLY
}

@export var scale_notes: Array[String] = []
@export var sheets: Array[MusicSheet] = []
@export var min_octave := 0
@export var max_octave := 3

@export var win_sounds: Array[AudioStream] = []

@onready var player: meta_player = $MetaPlayer
@onready var accordion: SamplerInstrument = $Accordion
@onready var frog: SamplerInstrument = $Frog
@onready var flies: SamplerInstrument = $Fly
@onready var store: GameStore = Store

@onready var win_sfx: AudioStreamPlayer = $WinSFX
@onready var fail_sfx: AudioStreamPlayer = $FailSFX

var layer := 0
var playing := false

var all_notes := []
var last_note: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  store.game_started.connect(start)
  store.tutorial_end.connect(on_tuto_end)
  store.level_updated.connect(update_layer)
  store.game_over.connect(on_game_over)
  store.level_up.connect(play_success)
  store.level_down.connect(play_fail)
  player.beat.connect(_on_beat)
  
  build_notes()
  var platforms := get_tree().get_nodes_in_group("platform")
  for p in platforms:
    var platform: Platform = p
    platform.set_steps(all_notes.size())
    platform.move_step.connect(play_step)
    
  var frogs := get_tree().get_nodes_in_group("frog")
  for f in frogs:
    var frog_inst: Frog = f
    beat.connect(frog_inst.on_beat)
    frog_inst.jumped.connect(func (): play_note(InstrumentKind.FROG))
  
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
  if !playing:
    player.mplay()
    playing = true
  else:
    layer = 1
  
func on_tuto_end():
  await beat
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

func pick_note(scores: Array[int]) -> String:
  var total: int = scores.reduce(func(sum, value): return sum + value, 0)
  var score = randi_range(0, total-1)
  
  var idx := 0
  var acc := scores[0]
  while (score >= acc && idx < scores.size()):
    idx += 1
    acc += scores[idx]
  return scale_notes[idx]
  
func play_note(kind: InstrumentKind):
  var instrument := frog if kind == InstrumentKind.FROG else flies
  var sheet_idx := 0
  while sheet_idx < sheets.size() - 1 && !sheets[sheet_idx].bars.has(player.current_bar):
    sheet_idx += 1
  var sheet := sheets[sheet_idx]
  
  var note := pick_note(sheet.scores)
  while note == last_note:
    note = pick_note(sheet.scores)
  last_note = note
  
  instrument.play_note(note, 4)

func on_play_fly():
  play_note(InstrumentKind.FLY)

func play_success():
  var sound: AudioStream = win_sounds.pick_random()
  win_sfx.stream = sound
  await beat
  win_sfx.play()
  
func play_fail():
  if !fail_sfx.playing:
    fail_sfx.play()
  
