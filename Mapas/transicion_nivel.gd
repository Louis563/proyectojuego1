@tool
class_name TransicionNivel extends Area2D

func _on_body_entered(body:Node2D) -> void:
	if body.is_in_group("PlayerT"):
		set_deferred("monitoring", false)
		LevelManager.go_to_next_level()
