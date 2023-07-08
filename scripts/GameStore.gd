extends Node2D
class_name GameStore

@export var score_goal = 20
@export var max_level = 3

var level = 0
var score = 0
var game_running = false
var finished = false

signal score_updated(value: int)
signal level_updated(value: int)
signal level_up
signal level_down
signal complete
signal game_over
signal game_started

func catch_fly():
  score += 1
  score_updated.emit(score)
  if score >= score_goal && !finished:
    level_success()
  
func level_success():
  level += 1
  level_updated.emit(level)
  score = 0
  score_updated.emit(score)
  if level >= max_level:
    finished = true
    complete.emit()
  else:
    level_up.emit()

func level_fail():
  level = maxi(0, level - 1)
  level_updated.emit(level)
  level_down.emit()
  if level == 0:
    game_running = false
    game_over.emit()
    
func start_game():
  game_running = true
  game_started.emit()
