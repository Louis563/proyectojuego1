extends Area2D

var is_player_close = false

func _process(delta):
	if is_player_close and Input.is_action_just_pressed("ui_accept"):
		print("iniciar dialogo")

func _on_area_entered(area):
	is_player_close = true

func _on_area_exited(area):
	is_player_close = false