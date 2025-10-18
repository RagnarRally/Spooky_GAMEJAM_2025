class_name HitboxComponent
extends Area2D

@export var health_component: HealthComponent

var _last_attack: AttackInfo

func damage(attack: AttackInfo):
	print(owner.name + ' hit')
	_last_attack = attack
	if health_component:
		health_component.damage(attack)

func get_last_attack() -> AttackInfo:
	return _last_attack

func set_enabled(enabled: bool) -> void:
	# Enable or disable the hitbox
	if enabled:
		set_deferred("monitorable", true)
	else:
		set_deferred("monitorable", false)