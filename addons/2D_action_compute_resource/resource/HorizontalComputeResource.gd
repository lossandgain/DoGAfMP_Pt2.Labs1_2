class_name HorizontalComputeResource
extends Resource

signal unit_size_changed
signal acceleration_type_changed
signal deceleration_type_changed
signal handle_max_speed_changed
signal max_speed_distance_changed
signal max_speed_time_changed
signal stopping_distance_changed
signal stopping_time_changed

#enum AccelerationMode{ MAXSPEED_AND_DISTANCE, DISTANCE_AND_TIME}
enum DecelerationMode{ DISTANCE, TIME}

@export_range( 1, 1024) var unit_size: int = 16:
	set( new_value):
		unit_size = new_value
		_update_horizontal_move_parameter()
		unit_size_changed.emit()
	get:
		return unit_size


@export_category( "Acceleration")
@export_range( 1, 30, .1) var max_speed: float = 4.0:
	set( new_value):
		max_speed = new_value
		_update_horizontal_move_parameter()
		handle_max_speed_changed.emit( max_speed)
	get:
		return max_speed * unit_size
@export_range( 0, 10, .1) var max_speed_distance: float = .4:
	set( new_value):
		max_speed_distance = new_value
		_update_horizontal_move_parameter()
		max_speed_distance_changed.emit( max_speed_distance)
	get:
		return max_speed_distance * unit_size
@export_category( "Deceleration")
@export var deceleration_mode: DecelerationMode:
	set( new_value):
		deceleration_mode = new_value
		_update_horizontal_move_parameter()
		deceleration_type_changed.emit()

@export_range( 0, 10, .1) var stopping_distance: float = .2:
	set( new_value):
		stopping_distance = new_value 
		stopping_distance_changed.emit( stopping_distance)
		_update_horizontal_move_parameter()
	get:
		return stopping_distance * unit_size
@export_range( 0, 10, .1) var stopping_time: float = .2:
	set( new_value):
		stopping_time = new_value
		_update_horizontal_move_parameter()
		stopping_time_changed.emit( stopping_time)

var _max_speed: float
var _acceleration: float
var _deceleration: float

func get_unit_size() -> int: return unit_size
func get_max_speed() -> float: return _max_speed
func get_acceleration() -> float: return _acceleration
func get_deceleration() -> float: return _deceleration

func set_unit_size( new_unit_size: int) -> void: unit_size = new_unit_size
func set_speed( new_speed: float) -> void: _max_speed = new_speed
func set_acceleration( new_acceleration: float) -> void: _acceleration = new_acceleration
func set_deceleration( new_deceleration: float) -> void: _deceleration = new_deceleration


func get_compute_acceleration_velocity( current_speed: float, direction: float, delta: float, multiplier: float = 1.0) -> float:
	return move_toward( current_speed , direction * _max_speed, _acceleration * delta / multiplier)


func get_compute_stiopping_velocity( current_speed: float, direction: float, delta: float, acceleration_multiplier: float = 1.0, deceleration_multiplier: float = 1.0) -> float:
	var stopping_velocity: float
	stopping_velocity = get_compute_deceleration_velocity( current_speed, delta, deceleration_multiplier)
	stopping_velocity = get_compute_acceleration_velocity( stopping_velocity, direction, delta, acceleration_multiplier)
	return stopping_velocity


func get_compute_deceleration_velocity( current_speed: float, delta: float, multiplier: float = 1.0) -> float:
	return move_toward( current_speed, 0, _deceleration * delta / multiplier)


func get_applied_horizontal_velocity( current_speed: float, direction: float, delta: float) -> float:
	if direction: # input on
		if sign( direction) == sign( current_speed) or current_speed == 0:
			return get_compute_acceleration_velocity( current_speed, direction, delta)
		else:
			return get_compute_stiopping_velocity( current_speed, direction, delta)
	else: # input off
		return get_compute_deceleration_velocity( current_speed, delta)


func _update_horizontal_move_parameter() -> void:
	_update_acceleration_parameter()
	_update_deceleration_parameter()


func _update_acceleration_parameter( multiplier: float = 1) -> void:
	_max_speed = max_speed
	_acceleration = pow( max_speed, 2) / ( 2 * max_speed_distance) # * multiplier


func _update_deceleration_parameter( multiplier: float = 1) -> void:
	match deceleration_mode:
		DecelerationMode.DISTANCE: # 距離から求める減速度　a = v0^2 / (d * 2)
			_deceleration = pow( _max_speed, 2) / ( stopping_distance * 2) # / multiplier
		DecelerationMode.TIME: ## 時間から求める減速度 = (最終速度 - 初速度) / 時間
			_deceleration = -( 0 - _max_speed) / stopping_time # * multiplier
