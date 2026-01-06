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
	emit_signal("action_selected", "attack", null)


func start_enemy_selection(action: String):
	if enemies.is_empty():
		return
	selecting = true
	current_index = 0
	$EnemySelector.visible = true
	update_selector()


func _process(delta):
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


func update_selector():
	if enemies.is_empty():
		return
	var enemy: Node2D = enemies[current_index]
	$EnemySelector.global_position = enemy.global_position + Vector2(-32, 0)
