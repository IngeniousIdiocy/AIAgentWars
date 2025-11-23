class_name WorldCamera
extends Camera2D

@export var pan_speed := 900.0
@export var drag_speed := 1.5
@export var zoom_step := 0.1
@export var min_zoom := 0.1
@export var max_zoom := 8.0

var _world: Node = null
var _dragging := false
var _last_mouse := Vector2.ZERO

func _ready() -> void:
	_world = get_parent()
	make_current()
	set_process(true)

func _process(delta: float) -> void:
	_handle_keyboard_pan(delta)
	_clamp_to_world()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			_dragging = event.pressed
			_last_mouse = event.position
			if _dragging:
				_consume_event()
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom_by(-zoom_step)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom_by(zoom_step)
	elif event is InputEventMouseMotion and _dragging:
		var delta_pos = event.position - _last_mouse
		position -= delta_pos * drag_speed
		_last_mouse = event.position
		_consume_event()
		_clamp_to_world()

func _handle_keyboard_pan(delta: float) -> void:
	var move := Vector2.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		move.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		move.y += 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		move.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		move.x += 1.0
	if move != Vector2.ZERO:
		position += move.normalized() * pan_speed * delta

func _zoom_by(step: float) -> void:
	var z = clamp(zoom.x + step, min_zoom, max_zoom)
	zoom = Vector2.ONE * z
	_clamp_to_world()

func _clamp_to_world() -> void:
	if not _world or not _world.has_method("get_map_bounds"):
		return
	var bounds: Rect2 = _world.get_map_bounds()
	if bounds.size == Vector2.ZERO:
		return
	var half_view = get_viewport_rect().size * 0.5 * zoom
	var min_x = bounds.position.x - half_view.x
	var max_x = bounds.position.x + bounds.size.x + half_view.x
	var min_y = bounds.position.y - half_view.y
	var max_y = bounds.position.y + bounds.size.y + half_view.y
	position.x = clamp(position.x, min_x, max_x)
	position.y = clamp(position.y, min_y, max_y)

func _consume_event() -> void:
	var vp := get_viewport()
	if vp:
		vp.set_input_as_handled()
