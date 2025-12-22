extends CharacterBody3D

@export var movement_speed = 7.5
@export var jump_velocity = 3.0
@export var fall_acceleration = 9.81
@export var turn_speed_radians = 1.0

@export_range(0.0, 1.0) var mouse_sensitivity = 0.01
@export var tilt_limit = deg_to_rad(75)

@onready var _camera := %Camera3D as Camera3D
@onready var _camera_pivot := %CameraPivot as Node3D

var level = 0
var character_name = ""

var is_left_mouse_down = false
var is_right_mouse_down = false

var is_transform_dirty = false
var input_vector = Vector2()


func _physics_process(delta):
	var turn_input = Input.get_axis("turn_right", "turn_left")
	if turn_input != 0:
		is_transform_dirty = true
		self.rotate_y(turn_input * turn_speed_radians * delta)

	input_vector = Input.get_vector("move_left", "move_right", "move_back", "move_forward")
	var direction = (transform.basis * Vector3(input_vector.x, 0, -input_vector.y)).normalized()
	if direction:
		is_transform_dirty = true
		velocity.x = direction.x * movement_speed
		velocity.z = direction.z * movement_speed
		# %Character/AnimationPlayer.current_animation = "run"
	else:
		velocity.x = move_toward(velocity.x, 0, movement_speed)
		velocity.z = move_toward(velocity.z, 0, movement_speed)
		# %Character/AnimationPlayer.current_animation = "idle"

	if not is_on_floor():  # If in the air, fall towards the floor. Literally gravity
		velocity.y -= fall_acceleration * delta
	elif is_on_floor() and Input.is_action_just_pressed("jump"):
		NetworkManager.queue_jump()
		velocity.y = jump_velocity

	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				is_left_mouse_down = true
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else:
				is_left_mouse_down = false
				if not is_right_mouse_down:
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.is_pressed():
				is_right_mouse_down = true
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else:
				is_right_mouse_down = false
				if not is_left_mouse_down:
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if is_left_mouse_down or is_right_mouse_down:
			_camera_pivot.rotation.x -= event.relative.y * mouse_sensitivity
			# Prevent the camera from rotating too far up or down.
			_camera_pivot.rotation.x = clampf(_camera_pivot.rotation.x, -tilt_limit, tilt_limit)

			if is_right_mouse_down:
				self.rotate_y(-event.relative.x * mouse_sensitivity)
				is_transform_dirty = true
			else:
				_camera_pivot.rotation.y += -event.relative.x * mouse_sensitivity
