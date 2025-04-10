extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.is_class("CharacterBody2D"):
		body.position = Globals.death_pos
