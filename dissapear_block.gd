extends Area2D


@onready var dissapear_block: Sprite2D = $"Dissapear block"

var level = 4
func _on_body_entered(body: Node2D) -> void:
	print("work1")
	if body.name == "Player":
		print("working")
		print(level)
		level = level - 1
		_change_level()


func _change_level():
	if level == 4:
		return
	if level == 3:
		dissapear_block.modulate = Color(1, 1, 1, 0.7)
	if level == 2:
		dissapear_block.modulate = Color(1, 1, 1, 0.3)
	if level == 1:
		queue_free()
