extends Node2D
class_name Portal

@onready var entrance: Area2D = $entrance
@onready var exit: Area2D = $exit

func _on_entrance_body_entered(body: Node2D) -> void:
	if body is Player:
		body.global_position = exit.global_position
