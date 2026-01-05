extends Node

var players = []
var enemies = []
var current_turn = 0

var player_scene = preload("res://Assets/Jugador/Jugadores de combate/Player.tscn")

const ENEMY_SCENES = [
	preload("res://Assets/Jugador/Jugadores de combate/Enemigo.tscn")
]

func setup_player_party():
	# Limpia por si recargas
	for child in $PlayerParty.get_children():
		if child is Node2D and not (child is Marker2D):
			child.queue_free()

	
	var names = ["Warrior", "Mage", "Thief", "Cleric"]

	# Obtén los markers dentro de PlayerParty
	var markers = []
	for child in $PlayerParty.get_children():
		if child is Marker2D:
			markers.append(child)

	# Instancia cada jugador en la posición de su marker
	for i in range(min(names.size(), markers.size())):
		var p = player_scene.instantiate()
		p.name = names[i]
		p.position = markers[i].position
		$PlayerParty.add_child(p)

	players = $PlayerParty.get_children().filter(func(c): return c is Player)



func _ready():
	setup_player_party()
	spawn_random_enemies()
	$IuCombate.connect("action_selected", Callable(self, "resolve_action"))
	start_turn()

func spawn_random_enemies():
	for child in $EnemyGroup.get_children():
		if child is Node2D and not (child is Marker2D):
			child.queue_free()
	enemies.clear()

	var count = randi() % 4 + 1
	var markers = []
	for child in $EnemyGroup.get_children():
		if child is Marker2D:
			markers.append(child)

	for i in range(count):
		var enemy_scene = ENEMY_SCENES[randi() % ENEMY_SCENES.size()]
		var e = enemy_scene.instantiate()
		e.position = markers[i].position
		$EnemyGroup.add_child(e)
		enemies.append(e)

func start_turn():
	if current_turn >= players.size():
		current_turn = 0
	var active = players[current_turn]
	if active.alive:
		$IuCombate.show_menu(active)
	else:
		current_turn += 1
		start_turn()

func resolve_action(action: String, target: Node):
	var active = players[current_turn]
	match action:
		"attack":
			target.take_damage(active.attack)
		"magic":
			if active.mp >= 5:
				target.take_damage(active.attack * 2)
				active.mp -= 5
		"item":
			active.hp += 20
		"defend":
			active.defense += 5
		"run":
			print("Intentando huir...")
	current_turn += 1
	start_turn()
