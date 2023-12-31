extends Node2D
class_name GameStore

@export var score_goal = 20
@export var max_level = 4

var level = 0
var score = 0
var game_running = false
var finished = false

var beats_available := [1,2,3]

var tutorial_active := true
@onready var tutorial_timer: Timer = $Timer

signal score_updated(value: int)
signal level_updated(value: int)
signal level_up
signal level_down
signal complete
signal game_over
signal game_started
signal tutorial_end

func catch_fly():
  score += 1
  score_updated.emit(score)
  if score >= score_goal && !finished:
    level_success()
  
func level_success():
  level += 1
  level_updated.emit(level)
  score = 0
  level_up.emit()
  score_updated.emit(score)
  if level >= max_level:
    finished = true
    complete.emit()

func level_fail():
  level = level - 1
  level_down.emit()
  level_updated.emit(level)
  if level < 0:
    game_running = false
    game_over.emit()
    level = 0
    score = 0
    score_updated.emit(score)
    
func start_game():
  game_running = true
  game_started.emit()

func schedule_beat(beat: int) -> int:
  if beats_available.has(beat):
    beats_available.erase(beat)
    return beat
  return -1
  
func return_beat(beat: int):
  beats_available.append(beat)

func complete_tutorial():
  if tutorial_active && tutorial_timer.is_stopped():
    tutorial_timer.start()
    await tutorial_timer.timeout
    tutorial_active = false
    tutorial_end.emit()
