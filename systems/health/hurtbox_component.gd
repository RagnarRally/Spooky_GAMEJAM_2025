class_name HurtboxComponent
extends Area2D

signal hurtbox_entered(entity: Node2D)

@export var attack_info: AttackInfo

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D):

	if area is HitboxComponent:
		area.damage(attack_info)

	hurtbox_entered.emit(area)

func set_enabled(enabled: bool) -> void:
	# Enable or disable the hitbox
	if enabled:
		set_deferred("monitoring", true)
	else:
		set_deferred("monitoring", false)