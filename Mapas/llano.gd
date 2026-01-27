class_name Llanos extends Node2D

@onready var MenuScene := preload("res://global/Guardado/Menu_guardado.tscn")
var menu_instance: Node = null

func _process(_delta: float) -> void:
	# Open save menu with action 'menu_guardado_save' (map it to U)
	if Input.is_action_just_pressed("menu_guardado_save"):
		_open_menu("save")
	# Open load menu with action 'menu_guardado_load' (map it to I)
	if Input.is_action_just_pressed("menu_guardado_load"):
		_open_menu("load")

	# If menu is open, update its position to follow the camera/player
	if menu_instance != null and is_instance_valid(menu_instance):
		_position_menu(menu_instance)
func _open_menu(new_mode: String) -> void:
	# Toggle: if open, close; otherwise instantiate and open in requested mode
	if menu_instance != null and is_instance_valid(menu_instance):
		menu_instance.queue_free()
		menu_instance = null
		return
	elif menu_instance != null:
		# menu_instance existed but is not a valid instance (was freed); clear reference
		menu_instance = null
		# continue to instantiate

	menu_instance = MenuScene.instantiate()
	add_child(menu_instance)
	if menu_instance.has_method("open"):
		menu_instance.call("open", new_mode)
	# Position menu after opening
	_position_menu(menu_instance)


func _position_menu(menu_node: Node) -> void:
	# Place the menu near the left edge of the camera view, slightly down from top
	var cam := get_viewport().get_camera_2d()
	var vp_size := Vector2(800, 600)
	if cam != null:
		vp_size = get_viewport().get_visible_rect().size
		var top_left := cam.global_position - Vector2(vp_size.x / 2.0, vp_size.y / 2.0)
		var target := top_left + Vector2(16, vp_size.y * 0.1)
		if menu_node is CanvasItem:
			menu_node.position = target
		else:
			menu_node.global_position = target
		return

	# Fallback: position relative to player
	if typeof(PlayerManager) != TYPE_NIL and PlayerManager.jugador != null:
		var player_pos := PlayerManager.jugador.global_position
		var target2 := player_pos + Vector2(-200, -100)
		if menu_node is CanvasItem:
			menu_node.position = target2
		else:
			menu_node.global_position = target2


func load_game_data(data: Dictionary) -> void:
	# Apply loaded data: move player to saved position if present
	if data == null:
		return
	if data.has("position"):
		var p: Variant = data["position"]
		if typeof(p) == TYPE_DICTIONARY and p.has("x") and p.has("y"):
			if typeof(PlayerManager) != TYPE_NIL and PlayerManager.jugador != null:
				PlayerManager.jugador.global_position = Vector2(p["x"], p["y"])
