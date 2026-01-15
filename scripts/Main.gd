extends Node2D

@export var spawn_interval := 0.75
@export var note_speed := 300.0
@export var hit_y := 400.0
@export var hit_window := 50.0
@export var lane_x := 320.0

var notes: Array[ColorRect] = []
var score := 0
var streak := 0
var status := "Ready"

@onready var score_label: Label = $HUD/ScoreLabel
@onready var status_label: Label = $HUD/StatusLabel

func _ready() -> void:
	var timer := Timer.new()
	timer.wait_time = spawn_interval
	timer.autostart = true
	timer.one_shot = false
	add_child(timer)
	timer.timeout.connect(_spawn_note)
	_update_labels()

func _process(delta: float) -> void:
	for note in notes.duplicate():
		note.position.y += note_speed * delta
		if note.position.y > hit_y + hit_window * 2.0:
			_register_miss(note, "Miss")
	_update_labels(false)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_try_hit()

func _spawn_note() -> void:
	var note := ColorRect.new()
	note.size = Vector2(40, 20)
	note.color = Color(0.2, 0.6, 1.0, 1)
	note.position = Vector2(lane_x - note.size.x / 2.0, -note.size.y)
	add_child(note)
	notes.append(note)

func _try_hit() -> void:
	var best_note: ColorRect = null
	var best_distance := INF
	for note in notes:
		var distance = abs((note.position.y + note.size.y / 2.0) - hit_y)
		if distance < best_distance:
			best_distance = distance
			best_note = note
	if best_note and best_distance <= hit_window:
		score += 100
		streak += 1
		status = "Hit! +100"
		_remove_note(best_note)
	else:
		status = "Miss"
		streak = 0
	_update_labels()

func _register_miss(note: ColorRect, message: String) -> void:
	streak = 0
	status = message
	_remove_note(note)
	_update_labels()

func _remove_note(note: ColorRect) -> void:
	notes.erase(note)
	note.queue_free()

func _update_labels(update_status := true) -> void:
	score_label.text = "Score: %d  |  Streak: %d" % [score, streak]
	if update_status:
		status_label.text = status
