extends Node2D
class_name World

@onready var end_cutscene = $end_cutscene
@onready var camera = $camera

var cutscene_triggered: bool = false
var player: Player

func _physics_process(delta: float) -> void:
	if cutscene_triggered and player:
		player.velocity.x = 0

func _on_cutscene_trigger_body_entered(body) -> void:
	if body is Player:
		camera.position = end_cutscene.position
		cutscene_triggered = true
		player = body
