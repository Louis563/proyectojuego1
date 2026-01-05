extends CanvasLayer

signal action_selected(action: String, target: Node)

var current_action: String = ""
var current_index: int = 0
var enemies: Array = []
var selecting: bool = false

func show_menu(_player):
	$ActionMenu.visible = true
	selecting = false

func _on_Attack_pressed():
	current_action = "attack"
	start_enemy_selection()

func start_enemy_selection():
	$ActionMenu.visible = false
	enemies = get_parent().enemies   # obtiene la lista de enemigos del CombatManager
	if enemies.is_empty():
		return
	current_index = 0
	$EnemySelector.visible = true
	selecting = true
	update_selector()

func _process(_delta):
	if selecting:
		if Input.is_action_just_pressed("ui_down"):
			current_index = min(current_index + 1, enemies.size() - 1)
			update_selector()
		elif Input.is_action_just_pressed("ui_up"):
			current_index = max(current_index - 1, 0)
			update_selector()
		elif Input.is_action_just_pressed("ui_accept"):
			var target = enemies[current_index]
			selecting = false
			$EnemySelector.visible = false
			emit_signal("action_selected", current_action, target)

func update_selector():
	if enemies.is_empty():
		return
	var enemy: Node2D = enemies[current_index]
	$EnemySelector.position = enemy.position + Vector2(-32, 0) 
	# Ajusta el offset (-32,0) para que la mano quede a la izquierda del enemigo


func _on_attack_pressed() -> void:
	pass # Replace with function body.


func _on_magic_pressed() -> void:
	pass # Replace with function body.


func _on_item_pressed() -> void:
	pass # Replace with function body.


func _on_defend_pressed() -> void:
	pass # Replace with function body.


func _on_run_pressed() -> void:
	pass # Replace with function body.
