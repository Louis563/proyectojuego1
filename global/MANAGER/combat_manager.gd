extends Node

@onready var interfaz = $InterfazCombate
@onready var sistema_turnos = SistemaTurnos.new()
@onready var sistema_magia = SistemaMagia.new()
@onready var sistema_objetos = SistemaObjetos.new()
@onready var inteligencia_enemiga = InteligenciaEnemiga.new()

var jugadores: Array = []
var enemigos: Array = []

func _ready():
	configurar_jugadores()
	generar_enemigos()
	sistema_turnos.configurar(jugadores, enemigos)

	# Conexiones UI
	interfaz.connect("atacar_presionado", Callable(self, "al_atacar"))
	interfaz.connect("defender_presionado", Callable(self, "al_defender"))
	interfaz.connect("magia_seleccionada", Callable(self, "al_magia"))
	interfaz.connect("objeto_seleccionado", Callable(self, "al_objeto"))

	iniciar_turno()

func configurar_jugadores():
	var nombres = ["Pedro", "Jose", "Firulais", "Ramon"]
	for i in range(nombres.size()):
		var jugador = preload("res://Assets/Jugador/Jugadores de combate/%s.tscn" % nombres[i]).instantiate()
		$GrupoJugadores.add_child(jugador)
		jugadores.append(jugador)

func generar_enemigos():
	enemigos.clear()
	var marcadores = $GrupoEnemigos.get_children().filter(func(c): return c is Marker2D)
	var cantidad = clamp(randi() % 4 + 1, 1, marcadores.size())
	for i in range(cantidad):
		var enemigo = preload("res://Assets/Jugador/Jugadores de combate/Enemigo.tscn").instantiate()
		enemigo.position = marcadores[i].position
		$GrupoEnemigos.add_child(enemigo)
		enemigos.append(enemigo)

func iniciar_turno():
	var activo = sistema_turnos.obtener_activo()
	if activo == null:
		return
	if activo is Jugador:
		interfaz.mostrar_menu(activo)
	else:
		inteligencia_enemiga.ejecutar_turno(activo, jugadores)
		terminar_turno()

func al_atacar():
	interfaz.iniciar_seleccion_enemigo(enemigos)

func al_defender():
	var activo = sistema_turnos.obtener_activo()
	activo.defensa += 5
	print(activo.nombre, " se defiende.")
	terminar_turno()

func al_magia(nombre_hechizo: String):
	var activo = sistema_turnos.obtener_activo()
	var objetivo = interfaz.obtener_enemigo_seleccionado(enemigos)
	sistema_magia.lanzar_hechizo(nombre_hechizo, activo, objetivo)
	terminar_turno()

func al_objeto(nombre_objeto: String):
	var activo = sistema_turnos.obtener_activo()
	sistema_objetos.usar_objeto(nombre_objeto, activo)
	terminar_turno()

func terminar_turno():
	sistema_turnos.siguiente_turno()
	iniciar_turno()
