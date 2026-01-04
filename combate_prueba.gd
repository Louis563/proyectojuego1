extends Node2D




func _on_area_2d_mouse_entered():
	$cursor.visible = true


func _on_area_2d_mouse_exited():
	$cursor.visible = false
