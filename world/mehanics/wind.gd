extends Area2D
class_name Wind

var wind_velocity: int = 100
var contains_player: bool = false

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_wind_body_entered(body: Node2D) -> void:
	if body is Player:
		body.velocity.x += wind_velocity

func _on_wind_body_exited(body: Node2D) -> void:
	if body is Player:
		body.velocity.x -= wind_velocity
