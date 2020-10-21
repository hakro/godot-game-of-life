extends Node2D

const CELL_SIZE : int = 32
const YELLOW := Color.yellowgreen

onready var window_width := get_viewport_rect().size.x
onready var window_height := get_viewport_rect().size.y
onready var timer : Timer = $NextGenTimer
onready var stats_label : Label = $StatsLabel
onready var stats_text : String = stats_label.text

onready var grid_width : int = window_width / CELL_SIZE
onready var grid_height : int = window_height / CELL_SIZE

var generation := 0
var active_cells : Array = []
var is_running : bool = false

func _draw() -> void:
	for col in range(0, window_width, CELL_SIZE):
		draw_line(Vector2(col, 0), Vector2(col, window_height), YELLOW)

	for row in range(0, window_height, CELL_SIZE):
		draw_line(Vector2(0, row), Vector2(window_width, row), YELLOW)

	for cell in active_cells:
		draw_rect(Rect2(cell * CELL_SIZE, Vector2(CELL_SIZE, CELL_SIZE)), YELLOW)

	# Update stats
	stats_label.text = stats_text % [generation, active_cells.size()]

func _input(event : InputEvent) -> void:
	if event is InputEventMouse:
		var click_pos : Vector2 = (event.position / Vector2(CELL_SIZE, CELL_SIZE)).floor()
		if event.button_mask == BUTTON_LEFT:
			activate_cell(click_pos)
		elif event.button_mask == BUTTON_RIGHT:
			deactivate_cell(click_pos)
	
	if event is InputEventKey and event.is_pressed() and event.get_scancode() == KEY_SPACE:
		is_running = not is_running
		if is_running:
			timer.start()
		else:
			timer.stop()

func activate_cell(pos : Vector2) -> void:
	if not active_cells.has(pos):
		active_cells.append(pos)
		update()

func deactivate_cell(pos: Vector2) -> void:
	active_cells.erase(pos)
	update()

func is_active(pos: Vector2) -> bool:
	if active_cells.has(pos):
		return true
	return false

func get_active_neighbors(pos: Vector2) -> Array:
	var all_neighbors : Array = [
		Vector2(pos.x - 1, pos.y -1),
		Vector2(pos.x, pos.y -1),
		Vector2(pos.x + 1, pos.y -1),
		Vector2(pos.x - 1, pos.y),
		Vector2(pos.x + 1, pos.y),
		Vector2(pos.x - 1, pos.y + 1),
		Vector2(pos.x, pos.y + 1),
		Vector2(pos.x + 1, pos.y + 1)
	]
	
	var active_neighbors : Array = []
	for neighbor in all_neighbors:
		if neighbor.x < 0 or neighbor.x >= grid_width:
			continue
		if neighbor.y < 0 or neighbor.y >= grid_height:
			continue
		if is_active(neighbor):
			active_neighbors.append(neighbor)
	return active_neighbors

func next_generation() -> void:	
	var marked_activation : Array = []
	var marked_deactivation : Array = []
	for y in range(grid_height):
		for x in range(grid_width):
			var current_cell = Vector2(x, y)
			if is_active(current_cell) and (get_active_neighbors(current_cell).size() < 2 or get_active_neighbors(current_cell).size() > 3) :
				marked_deactivation.append(current_cell)
			elif not is_active(current_cell) and get_active_neighbors(current_cell).size() == 3:
				marked_activation.append(current_cell)
	for cell in marked_activation:
		activate_cell(cell)
	for cell in marked_deactivation:
		deactivate_cell(cell)
	generation += 1

func _on_NextGenTimer_timeout():
	next_generation()
