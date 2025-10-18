class_name AttackInfo
extends Resource

@export var damage: int = 1
@export var source: String = "unknown"

func _init(_damage=1, _source="unknown") -> void:
	damage = _damage
	source = _source
