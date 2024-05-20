extends Node2D
class_name World

@onready var end_cutscene = $end_cutscene
@onready var camera = $camera

func _on_cutscene_trigger_body_entered(body):
	if body is Player:
		camera.position = end_cutscene.position
