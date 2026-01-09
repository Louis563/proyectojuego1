extends Node

var players: Array = []
var enemies: Array = []
var turn_order: Array = []
var current_turn: int = 0
var enemy_index: int = 0

enum CombatState { MENU, SELECT_ENEMY }
var state = CombatState.MENU

const PLAYER_SCENES = {
	"Pedro": preload("res://Assets/Jugador/Jugadores de combate/Pedro.tscn"),
	"Jose": preload("res://Assets/Jugador/Jugadores de combate/Jose.tscn"),
	"Firulais": preload("res://Assets/Jugador/Jugadores de combate/Firulais.tscn"),
	"Ramon": preload("res://Assets/Jugador/Jugadores de combate/Ramon.tscn")
}

var player_positions = [
	Vector2(100, -100),
	Vector2(-40, -40),
	Vector2(-40, 120),
	Vector2(100, 240)
]

const ENEMY_SCENES = [
	preload("res://Assets/Jugador/Jugadores de combate/Enemigo.tscn")
]

func _ready():
	setup_player_party()
	spawn_random_enemies()
	build_turn_order()

	$IuCombate.connect("atacar_presionado", Callable(self, "on_attack_pressed"))
	$IuCombate.connect("defender_presionado", Callable(self, "on_defend_pressed"))
	$IuCombate.connect("magia_presionada", Callable(self, "on_magic_pressed"))
	$IuCombate.connect("objeto_presionado", Callable(self, "on_item_pressed"))

	start_turn()

# --- PARTY ---
func setup_player_party():
	for child in $PlayerParty.get_children():
		if child is Node2D:
			child.queue_free()
	players.clear()

	var names = ["Pedro", "Jose", "Firulais", "Ramon"]

	for i in range(names.size()):
		var p = PLAYER_SCENES[names[i]].instantiate()
		p.position = player_positions[i]
		$PlayerParty.add_child(p)

	players = $PlayerParty.get_children().filter(func(c): return c is Player)

	players = $PlayerParty.get_children().filter(func(c): return c is Player)

# --- ENEMIGOS ---
func spawn_random_enemies():
	for child in $EnemyGroup.get_children():
		if child is Node2D and not (child is Marker2D):
			child.queue_free()
	enemies.clear()

	var markers: Array = []
	for child in $EnemyGroup.get_children():
		if child is Marker2D:
			markers.append(child)

	var count = clamp(randi() % 4 + 1, 1, markers.size())
	for i in range(count):
		var enemy_scene = ENEMY_SCENES[randi() % ENEMY_SCENES.size()]
		var e = enemy_scene.instantiate()
		e.position = markers[i].position
		$EnemyGroup.add_child(e)

	enemies = $EnemyGroup.get_children().filter(func(c): return c.has_method("take_damage"))

# --- ORDEN DE TURNOS ---
func build_turn_order():
	turn_order.clear()
	turn_order.append_array(players.filter(func(p): return p.alive))
	turn_order.append_array(enemies.filter(func(e): return e.alive))
	current_turn = 0

# --- INICIO DE TURNO ---
func start_turn():
	if enemies.filter(func(e): return e.alive).is_empty():
		print("¡Victoria! No quedan enemigos.")
		return
	if players.filter(func(p): return p.alive).is_empty():
		print("Derrota. No quedan jugadores.")
		return

	if current_turn >= turn_order.size():
		build_turn_order()

	for c in turn_order:
		if c.has_node("Selector"):
			c.get_node("Selector").visible = false

	var active = turn_order[current_turn]
	if not active.alive:
		current_turn += 1
		start_turn()
		return

	if active is Player and active.has_node("Selector"):
		active.get_node("Selector").visible = true

	if active is Player:
		$IuCombate.show_menu(active)
		state = CombatState.MENU
	else:
		enemy_action(active)

func on_defend_pressed():
		var active = turn_order[current_turn]
		print(active.nombre, " se defiende.")
		active.defense += 5   # ejemplo: aumenta defensa temporal
		end_turn()

func resolve_magic(spell_name: String):
		var active = turn_order[current_turn]
		if spell_name == "Fuego" and active.mp >= 5:
			var target_enemy = enemies[enemy_index]
			print(active.nombre, " lanza ", spell_name, " a ", target_enemy.nombre)
			target_enemy.take_damage(active.attack * 2)
			active.mp -= 5
		elif spell_name == "Hielo" and active.mp >= 4:
			var target_enemy = enemies[enemy_index]
			print(active.nombre, " lanza ", spell_name, " a ", target_enemy.nombre)
			target_enemy.take_damage(active.attack * 1.5)
			active.mp -= 4
		end_turn()

func resolve_item(item_name: String):
		var active = turn_order[current_turn]
		if item_name == "Poción":
			active.hp += 20
			print(active.nombre, " usa ", item_name, " y recupera 20 HP.")
		elif item_name == "Éter":
			active.mp += 10
			print(active.nombre, " usa ", item_name, " y recupera 10 MP.")
		end_turn()

func end_turn():
		current_turn+=1
		state = CombatState.MENU
		start_turn()

# --- BOTÓN ATACAR ---
func on_attack_pressed():
	if enemies.filter(func(e): return e.alive).is_empty():
		print("No quedan enemigos. ¡Victoria!")
		return
	state = CombatState.SELECT_ENEMY
	enemy_index = 0
	update_enemy_selector()

# --- RESOLVER ACCIÓN ---
func resolve_action(action: String, target: Node):
	var active = turn_order[current_turn]

	if action == "attack":
		if enemies.filter(func(e): return e.alive).is_empty():
			print("No quedan enemigos. ¡Victoria!")
			return
		if target == null or not target.alive:
			print("Objetivo inválido.")
			return

		print(active.nombre, " ataca a ", target.nombre)
		target.take_damage(active.attack)

		if not target.alive:
			enemies = enemies.filter(func(e): return e.alive)
			enemy_index = clamp(enemy_index, 0, max(enemies.size() - 1, 0))

	current_turn += 1
	state = CombatState.MENU
	start_turn()

# --- ACCIÓN DE ENEMIGO ---
func enemy_action(enemy: Enemy):
	var alive_players = players.filter(func(p): return p.alive)
	if alive_players.is_empty():
		print("Derrota. No quedan jugadores.")
		return

	var target = alive_players[randi() % alive_players.size()]
	print(enemy.nombre, " ataca a ", target.nombre)
	target.take_damage(enemy.attack)

	current_turn += 1
	start_turn()

# --- SELECTOR GLOBAL DE ENEMIGOS ---
func update_enemy_selector():
	var alive_enemies = enemies.filter(func(e): return e.alive)
	if alive_enemies.is_empty():
		$EnemySelector.visible = false
		return

	enemy_index = clamp(enemy_index, 0, alive_enemies.size() - 1)
	var target = alive_enemies[enemy_index]
	$EnemySelector.visible = true
	$EnemySelector.global_position = target.global_position + Vector2(-32, 0)

# --- INPUTS ---
func _process(_delta):
	if state == CombatState.SELECT_ENEMY:
		var alive_enemies = enemies.filter(func(e): return e.alive)
		if alive_enemies.is_empty():
			return

		if Input.is_action_just_pressed("arriba combate"):
			enemy_index = (enemy_index + 1) % alive_enemies.size()
			update_enemy_selector()
		elif Input.is_action_just_pressed("abajo combate"):
			enemy_index = (enemy_index - 1 + alive_enemies.size()) % alive_enemies.size()
			update_enemy_selector()
		elif Input.is_action_just_pressed("ui_accept"):
			var target_enemy = alive_enemies[enemy_index]
			resolve_action("attack", target_enemy)
