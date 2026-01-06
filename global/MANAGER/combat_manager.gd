extends Node

var players: Array = []
var enemies: Array = []
var current_turn: int = 0

var selecting: bool = false
var current_index: int = 0
var last_selected_index: int = 0


var player_scene = preload("res://Assets/Jugador/Jugadores de combate/Player.tscn")

const ENEMY_SCENES = [
	preload("res://Assets/Jugador/Jugadores de combate/Enemigo.tscn")
]

func _ready():
	setup_player_party()
	spawn_random_enemies()
	$IuCombate.connect("action_selected", Callable(self, "resolve_action"))
	start_turn()

# --- PARTY ---
func setup_player_party():
	for child in $PlayerParty.get_children():
		if child is Node2D and not (child is Marker2D):
			child.queue_free()

	var names = ["Warrior", "Mage", "Thief", "Cleric"]

	var markers: Array = []
	for child in $PlayerParty.get_children():
		if child is Marker2D:
			markers.append(child)

	for i in range(min(names.size(), markers.size())):
		var p = player_scene.instantiate()
		p.name = names[i]
		p.position = markers[i].position
		$PlayerParty.add_child(p)

	players = $PlayerParty.get_children().filter(func(c): return c is Player)

# --- ENEMIGOS ---
func spawn_random_enemies():
	for child in $EnemyGroup.get_children():
		if child is Node2D and not (child is Marker2D):
			child.queue_free()
	enemies.clear()

	var count = randi() % 4 + 1
	var markers: Array = []
	for child in $EnemyGroup.get_children():
		if child is Marker2D:
			markers.append(child)

	for i in range(min(count, markers.size())):
		var enemy_scene = ENEMY_SCENES[randi() % ENEMY_SCENES.size()]
		var e = enemy_scene.instantiate()
		e.position = markers[i].position
		$EnemyGroup.add_child(e)

	# Solo enemigos con lógica de combate
	enemies = $EnemyGroup.get_children().filter(func(c): return c.has_method("take_damage"))

# --- TURNOS ---
func start_turn():
	if current_turn >= players.size():
		current_turn = 0

	# Oculta indicadores de todos los jugadores
	for p in players:
		if p.has_node("Selector"):
			p.get_node("Selector").visible = false

	var active = players[current_turn]
	if active.alive:
		if active.has_node("Selector"):
			active.get_node("Selector").visible = true
		$IuCombate.show_menu(active)
	else:
		current_turn += 1
		start_turn()

# --- ACCIONES ---
func resolve_action(action: String, target: Node):
	var active = players[current_turn]

	# Caso especial: atacar sin objetivo → abrir selector
	if action == "attack" and target == null:
		start_enemy_selection()
		return

	match action:
		"attack":
			if target and target.has_method("take_damage"):
				target.take_damage(active.attack)
		"magic":
			if active.mp >= 5 and target and target.has_method("take_damage"):
				target.take_damage(active.attack * 2)
				active.mp -= 5
		"item":
			active.hp += 20
		"defend":
			active.defense += 5
		"run":
			print("Intentando huir...")

	# Filtra enemigos vivos
	enemies = enemies.filter(func(e): return is_instance_valid(e) and e.alive)

	if enemies.is_empty():
		print("¡Victoria!")
		return

	current_turn += 1
	start_turn()

# --- SELECCIÓN DE ENEMIGOS ---
func start_enemy_selection():
	if enemies.is_empty():
		return
	selecting = true
	# 👇 Usa el índice anterior si sigue siendo válido
	if last_selected_index < enemies.size():
		current_index = last_selected_index
	else:
		current_index = 0
	$EnemySelector.visible = true
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
			last_selected_index = current_index   # 👈 guarda el último enemigo elegido
			selecting = false
			$EnemySelector.visible = false
			resolve_action("attack", target)


func update_selector():
	if enemies.is_empty():
		return
	var enemy: Node2D = enemies[current_index]
	$EnemySelector.global_position = enemy.global_position + Vector2(-32, 0)
