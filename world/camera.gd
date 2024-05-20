extends Camera2D
class_name Camera

@onready var v_height: int = ProjectSettings.get("display/window/size/viewport_height")

func _ready():
	print(v_height)

func _on_top_area_body_entered(body):
	if body is Player:
		self.position.y -= v_height

func _on_bottom_area_body_entered(body):
	if body is Player:
		self.position.y += v_height
