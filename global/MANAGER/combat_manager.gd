extends Node


var players: Array = []
var enemies: Array = []
var turn_order: Array = []
var current_turn: int = 0
var enemy_index: int = 0

# --- Items Manager ---
var items_manager: Node = null

enum CombatState { MENU, SELECT_ENEMY }
var state = CombatState.MENU

@onready var sistema_magia = SistemaMagia.new()

const PLAYER_SCENES = {
	"Pedro": preload("res://Assets/Jugador/Jugadores de combate/Pedro.tscn"),
	"Jose": preload("res://Assets/Jugador/Jugadores de combate/Jose.tscn"),
	"Firulais": preload("res://Assets/Jugador/Jugadores de combate/Firulais.tscn"),
	"Ramon": preload("res://Assets/Jugador/Jugadores de combate/Ramon.tscn")
}

var player_positions = [
	Vector2(100, -50),
	Vector2(10, -25),
	Vector2(0, 80),
	Vector2(100, 120)
]

const ENEMY_SCENES = [
	preload("res://Assets/Jugador/Jugadores de combate/Enemigo.tscn")
]

func _ready():
	setup_player_party()
	spawn_random_enemies()
	build_turn_order()
	$musica_combate.play()
	verificar_derrota()
	add_to_group("combat_manager")

	# Instanciar el gestor de objetos si no existe
	if not items_manager:
		items_manager = preload("res://global/MANAGER/items_manager.gd").new()
		add_child(items_manager)
		# Demo: añadir algunos objetos al inventario
		items_manager.add_item("Poción", 3)
		items_manager.add_item("Éter", 2)
		items_manager.add_item("Antídoto", 1)
		items_manager.add_item("Revivir", 1)

	$IuCombate.connect("atacar_presionado", Callable(self, "on_attack_pressed"))
	$IuCombate.connect("defender_presionado", Callable(self, "on_defend_pressed"))
	$IuCombate.connect("magia_presionada", Callable(self, "on_magic_pressed"))
	$IuCombate.connect("objeto_presionado", Callable(self, "on_item_pressed"))

	$IuCombate.connect("magia_seleccionada", Callable(self, "resolve_magic"))
	$IuCombate.connect("objeto_seleccionado", Callable(self, "resolve_item"))

	start_turn()

# --- OBJETOS ---
func on_item_pressed():
	# Mostrar lista real de objetos con cantidades
	var item_list = items_manager.get_item_list()
	$IuCombate.show_item_menu(item_list)

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
			var sel = c.get_node("Selector")
			sel.visible = false
			# Detener animación del marcador si existe
			var marc = sel.get_node_or_null("marcador")
			if marc and marc is AnimationPlayer:
				if marc.is_playing():
					marc.stop()

	var active = turn_order[current_turn]
	if not active.alive:
		current_turn += 1
		start_turn()
		return

	if active is Player and active.has_node("Selector"):
		var sel = active.get_node("Selector")
		sel.visible = true
		# Reproducir la animación 'flotar' desde el AnimationPlayer llamado 'marcador' dentro de Selector
		var marc = sel.get_node_or_null("marcador")
		if marc and marc is AnimationPlayer:
			if marc.has_animation("flotar"):
				marc.play("flotar")
			
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

	# Guardar el hechizo elegido
	active.set_meta("hechizo_pendiente", spell_name)

	# Activar selección de enemigo
	state = CombatState.SELECT_ENEMY
	enemy_index = 0
	update_enemy_selector()




func resolve_item(item_name: String):
	var active = turn_order[current_turn]
	# Si el nombre viene con cantidad ("Poción x2"), extraer solo el nombre
	var real_name = item_name.split(" x")[0]
	var ok = items_manager.use_item(real_name, active)
	if ok:
		print(active.nombre, " usa ", real_name, ". Efecto aplicado.")
	else:
		print("No se pudo usar el objeto: ", real_name)
	end_turn()

func end_turn():
	current_turn+=1
	state = CombatState.MENU
	start_turn()

# Mostrar pantalla de victoria y desactivar inputs del combate de forma segura
func show_victory():
	if $musica_combate.playing:
		$musica_combate.stop()

	print("¡Victoria! No quedan enemigos.")
	var vict = $IuCombate.get_node_or_null("Llb_Victoria")
	if vict:
		vict.visible = true
		# Reproducir animación si existe un AnimationPlayer hijo
		var anim = vict.get_node_or_null("anim_victoria")
		if anim and anim is AnimationPlayer:
			# La animación en la librería se llama "Entrada" (case-sensitive)
			if anim.has_animation("Entrada"):
				anim.play("Entrada")
			elif anim.has_animation("entrada"):
				anim.play("entrada")

		# Reproducir música de victoria si existe un AudioStreamPlayer2D llamado 'musica_victoria'
		var music = get_node_or_null("musica_victoria")
		if music and (music is AudioStreamPlayer or music is AudioStreamPlayer2D):
			music.play()
	else:
		print("Nodo 'IuCombate/Llb_Victoria' no encontrado. Revisa la jerarquía de IUCombate.tscn")

	var action_menu = $IuCombate.get_node_or_null("ActionMenu")
	if action_menu:
		action_menu.visible = false
		$EnemySelector.visible = false

	# Desactivar inputs del combate para evitar más interacciones
	set_process_input(false)

func mostrar_derrota():
		var ui = $IuCombate
		if $musica_combate.playing:
			$musica_combate.stop()

		# Mostrar label (soporta nombres antiguos/nuevos)
		var derrota_label = ui.get_node_or_null("Llb_Derrota")
		if derrota_label == null:
			derrota_label = ui.get_node_or_null("lbl_derrota")

		if derrota_label:
			derrota_label.visible = true
			var anim = derrota_label.get_node_or_null("anim_derrota")
			if anim and anim is AnimationPlayer:
				if anim.has_animation("Derrota"):
					anim.play("Derrota")
				elif anim.has_animation("derrota"):
					anim.play("derrota")
		else:
			print("Nodo de derrota no encontrado en IUCombate (buscado 'Llb_Derrota' y 'lbl_derrota').")

		# Música de derrota (si existe)
		var defeat_music = get_node_or_null("musica_derrota")
		if defeat_music and (defeat_music is AudioStreamPlayer or defeat_music is AudioStreamPlayer2D):
			defeat_music.play()

		# Desactivar input
		set_process_input(false)

		# Ocultar menú
		var action_menu = $IuCombate.get_node_or_null("ActionMenu")
		if action_menu:
			action_menu.visible = false
			$EnemySelector.visible = false



func verificar_derrota():
		var todos_muertos := true

		for player in $PlayerParty.get_children():
			if player.is_dead == false:
				todos_muertos = false
				break

		if todos_muertos:
			mostrar_derrota()



# --- BOTÓN ATACAR ---
func on_attack_pressed():
	if enemies.filter(func(e): return e.alive).is_empty():
		print("No quedan enemigos. ¡Victoria!")
		# Usar la función centralizada para manejar la victoria (muestra UI, anima y desactiva inputs)
		show_victory()
		return
	state = CombatState.SELECT_ENEMY
	enemy_index = 0
	update_enemy_selector()

func on_magic_pressed():
	# Solo mostrar menú de magias, sin activar selector todavía
	$IuCombate.show_magic_menu(["Fuego", "Hielo", "Rayo"])


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
			# Si ya no quedan enemigos, mostrar UI de victoria y terminar combate
			if enemies.filter(func(e): return e.alive).is_empty():
				show_victory()
				return

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
			var active = turn_order[current_turn]

			# Si hay un hechizo pendiente, lanzar magia
			if active.has_meta("hechizo_pendiente"):
				var spell_name = active.get_meta("hechizo_pendiente")
				active.remove_meta("hechizo_pendiente")

				if spell_name == "Fuego" and active.mp >= 5:
					print(active.nombre, " lanza ", spell_name, " a ", target_enemy.nombre)
					target_enemy.take_damage(active.attack * 2)
					active.mp -= 5
					# Actualizar lista de enemigos y comprobar victoria
					if not target_enemy.alive:
						enemies = enemies.filter(func(e): return e.alive)
						enemy_index = clamp(enemy_index, 0, max(enemies.size() - 1, 0))
						if enemies.filter(func(e): return e.alive).is_empty():
							show_victory()
							return
				elif spell_name == "Hielo" and active.mp >= 4:
					print(active.nombre, " lanza ", spell_name, " a ", target_enemy.nombre)
					target_enemy.take_damage(active.attack * 1.5)
					active.mp -= 4
					# Actualizar lista de enemigos y comprobar victoria
					if not target_enemy.alive:
						enemies = enemies.filter(func(e): return e.alive)
						enemy_index = clamp(enemy_index, 0, max(enemies.size() - 1, 0))
						if enemies.filter(func(e): return e.alive).is_empty():
							show_victory()
							return
				elif spell_name == "Rayo" and active.mp >= 6:
					print(active.nombre, " lanza ", spell_name, " a ", target_enemy.nombre)
					target_enemy.take_damage(active.attack * 3)
					active.mp -= 6
					# Actualizar lista de enemigos y comprobar victoria
					if not target_enemy.alive:
						enemies = enemies.filter(func(e): return e.alive)
						enemy_index = clamp(enemy_index, 0, max(enemies.size() - 1, 0))
						if enemies.filter(func(e): return e.alive).is_empty():
							show_victory()
							return
				else:
					print(active.nombre, " no tiene suficiente MP para ", spell_name)

				end_turn()
			else:
				# Si no hay hechizo pendiente, es ataque normal
				resolve_action("attack", target_enemy)
