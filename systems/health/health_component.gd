class_name HealthComponent
extends Node

signal health_changed(new_health: int, attack: AttackInfo)
signal health_zero(attack: AttackInfo)

signal invincibility_started
signal invincibility_ended

@export var max_health: int = 1
@export var starting_health: int = 1

@export var enable_invincibility: bool = false
@export var invincibility_time: float = 0

var _current_health: int
var _invincibility_active: bool = false
var _invincibility_remaining: float = 0.0
var _health_reached_zero: bool = false

var _external_invincibility: bool = false

#region Public functions
func damage(attack: AttackInfo):

	if _invincibility_active or _external_invincibility:
		return

	_current_health -= attack.damage

	if _current_health > 0:
		health_changed.emit(_current_health, attack)
		if enable_invincibility:
			_invincibility_remaining = invincibility_time
			_invincibility_active = true
			invincibility_started.emit()
	else:
		_current_health = 0
		_health_reached_zero = true
		health_zero.emit(attack)


func is_alive():
	return not _health_reached_zero


func setup(_max_health: int, _health = null):
	max_health = _max_health
	if _health != null:
		_current_health = _health
	else:
		_current_health = max_health


func set_invincible():
	_external_invincibility = true

func clear_invincible():
	_external_invincibility = false

func heal_to_full():
	_current_health = max_health
	health_changed.emit(_current_health, null)

#endregion

#region Private functions
func _ready() -> void:
	_current_health = starting_health
	_health_reached_zero = false


func _process(delta: float) -> void:

	if not enable_invincibility or not _invincibility_active:
		return

	_invincibility_remaining -= delta

	if _invincibility_remaining <= 0:
		_invincibility_remaining = 0
		_invincibility_active = false
		invincibility_ended.emit()

#endregion
