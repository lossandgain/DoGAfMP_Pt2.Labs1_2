class_name VerticalComputeResource
extends Resource

signal unit_size_changed
signal main_jump_apex_height_changed
signal main_jump_apex_time_changed
signal sub_jump_mode_changed
signal sub_jump_apex_height_changed
signal sub_jump_factor_changed
signal option_jump_factor_changed

enum SubJumpMode{ Height, Factor}

@export_range( 1, 1024) var unit_size: int = 16:
	set( new_value):
		unit_size = new_value
		_update_vertical_move_parameter()
		unit_size_changed.emit()
	get:
		return unit_size

@export_category( "Main Jump")
@export_range( .1, 10.0, .1) var main_jump_apex_height: float = 3.0:
	set( new_value):
		main_jump_apex_height = new_value
		_update_vertical_move_parameter()
		main_jump_apex_height_changed.emit()
	get:
		return main_jump_apex_height * unit_size
@export_range( .1, 5.0, .1) var main_jump_apex_time: float = 0.5:
	set( new_value):
		main_jump_apex_time = new_value
		_update_vertical_move_parameter()
		main_jump_apex_time_changed.emit( main_jump_apex_time)

@export_category( "Sub Jump")
@export var sub_jump_mode: SubJumpMode = SubJumpMode.Height
@export_range( .1, 10.0, .1) var sub_jump_apex_height: float = 1.0:
	set( new_value):
		sub_jump_apex_height = new_value
		_update_vertical_move_parameter()
		sub_jump_apex_height_changed.emit( sub_jump_apex_height)
	get:
		return sub_jump_apex_height * unit_size
@export var sub_jump_factor: float = .5:
	set( new_value):
		sub_jump_factor = new_value
		_update_vertical_move_parameter()
		sub_jump_factor_changed.emit()
@export_category( "Option")
@export var option_jump_apex_height: float = 2:
	set( new_value):
		option_jump_apex_height = new_value
		_update_vertical_move_parameter()
		option_jump_factor_changed.emit()
	get:
		return option_jump_apex_height * unit_size

var _main_jump_velocity: float
var _gravity: float
var _sub_jump_velocity: float
var _option_jump_velocity: float


func get_main_jump_velocity() -> float: return _main_jump_velocity
func get_gravity() -> float: return _gravity
func get_sub_jump_velocity() -> float: return _sub_jump_velocity
func get_option_jump_velocity() -> float: return _option_jump_velocity

func set_main_jump_velocity( new_value: float) -> void: _main_jump_velocity = new_value 
func set_gravity( new_value: float) -> void: _gravity = new_value
func set_sub_jump_velocity( new_value: float) -> void: _sub_jump_velocity = new_value
func set_option_jump_velocity( new_value: float) -> void: _option_jump_velocity = new_value

func get_compute_variable_jump_velocity( target_height: float, use_unit_size: bool = true) -> float:
	return -sqrt(2.0 * _gravity * (target_height if !use_unit_size else target_height * unit_size))


func get_compute_sub_jump_velocity( velocity_y: float, prioritize_main_jump: bool = true) -> float:
	match sub_jump_mode:
		SubJumpMode.Height:
			if prioritize_main_jump:
				if velocity_y < _sub_jump_velocity:
					return _sub_jump_velocity
			else:
				return _sub_jump_velocity
		SubJumpMode.Factor:
			if prioritize_main_jump:
				if velocity_y < velocity_y * sub_jump_factor:
					return velocity_y * sub_jump_factor
			else:
				return velocity_y * sub_jump_factor
	return velocity_y


func _update_vertical_move_parameter() -> void:
	_main_jump_velocity = _update_main_jump_velocity()
	_gravity = _update_gravity()
	_sub_jump_velocity = _update_sub_jump_velocity()
	_option_jump_velocity = _update_option_jump_velocity()

func _update_main_jump_velocity() -> float: return -(2.0 * main_jump_apex_height) / main_jump_apex_time # *  (2 × ジャンプの高さ) / 時間
func _update_sub_jump_velocity() -> float: return -sqrt(2.0 * _gravity * sub_jump_apex_height) # √(2 × ジャンプの高さ × 重力)
func _update_option_jump_velocity() -> float: return -sqrt(2.0 * _gravity * option_jump_apex_height)
func _update_gravity() -> float: return -(-2.0 * main_jump_apex_height) / (main_jump_apex_time * main_jump_apex_time) # (2 × ジャンプの高さ) / (時間 × 時間)
