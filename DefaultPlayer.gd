extends KinematicBody

# Constants
export var max_speed := 10.0
export var jump_speed := 10.0
export var acceleration := 10.0
export var deceleration := 5.0
export var air_acceleration_scale := 0.25
export var gravity_scale := 3.0

export var turn_enabled := false
export var turn_speed := 240.0

var _velocity := Vector3.ZERO
var _gravity: Vector3 = Vector3.ZERO

func _ready() -> void:
	_gravity = ProjectSettings.get_setting("physics/3d/default_gravity_vector")
	_gravity *=  ProjectSettings.get_setting("physics/3d/default_gravity") * gravity_scale
	
func _physics_process(delta: float) -> void:
	var move_input := Vector3.ZERO
	move_input.x = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
	move_input.z = -(Input.get_action_strength("move_forward") - Input.get_action_strength("move_back"))
	
	var on_ground := is_on_floor()
	
	if turn_enabled:
		rotation_degrees.y = wrapf(rotation_degrees.y + turn_speed * delta * move_input.x, 0.0, 360.0)
		move_input = global_transform.basis.z * move_input.z
	else:
		if move_input.length_squared() > 1:
			move_input = move_input.normalized()
	
	if on_ground and Input.is_action_just_pressed("jump"):
		_velocity.y = jump_speed

	_velocity += _gravity * delta
	
	# Using only the horizontal velocity, interpolate towards the input.
	var horizontal_velocity := Vector3(_velocity.x, 0, _velocity.z)
	var target_velocity := move_input * max_speed	
	var accel := acceleration if move_input.dot(horizontal_velocity) > 0 else deceleration
	if !on_ground:
		accel *= air_acceleration_scale
	horizontal_velocity = horizontal_velocity.linear_interpolate(target_velocity, accel * delta)

	# Assign horizontal_velocity's values back to velocity, and then move.
	_velocity.x = horizontal_velocity.x
	_velocity.z = horizontal_velocity.z
	_velocity = move_and_slide(_velocity, Vector3.UP)
