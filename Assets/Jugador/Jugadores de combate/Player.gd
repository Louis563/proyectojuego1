extends Node2D
class_name Player

const DAMAGE_INDICATOR = preload("res://Assets/Interfaz de usuario/UI PIXEL ART IA/Indicador_de_daño.tscn")

# Estadísticas y estado del player
var nombre: String = "Jugador"
var max_hp: float = 100
var hp: float = 100
var max_mp: int = 20
var mp: int = 20
var attack: int = 10
var defense: int = 5
var speed: int = 10
var level: int = 1
var exp_points: int = 0
var vivo: bool = true

# Utilidades que usan los objetos
func curar(cantidad: int):
	var antes = hp
	hp = min(hp + cantidad, max_hp)
	var curado = hp - antes

	if curado > 0:
		mostrar_curación(curado)

	print(nombre, " se cura ", curado, " HP. HP actual: ", hp)

func recuperar_mp(cantidad: int):
	mp = min(mp + cantidad, max_mp)
	print(nombre, " recupera ", cantidad, " MP. MP actual: ", mp)

func curar_estados():
	print(nombre, " quedó limpio de estados, listo pa'l mambo.")

func revivir():
	if not vivo:
		vivo = true
		hp = floor(max_hp / 2)
		print(nombre, " ha vuelto con ", hp, " HP.")
		show()

func recibir_daño(cantidad: float):
	var daño = max(int(round(cantidad)) - defense, 0)
	hp -= daño
	mostrar_daño_recibido(daño, Color.YELLOW)
	print(nombre, " recibe ", daño, " de daño. HP restante: ", hp)
	if hp <= 0 and vivo:
		vivo = false
		morir()

func mostrar_daño_recibido(valor: int, color: Color) -> void:
	var indicador = DAMAGE_INDICATOR.instantiate()
	add_child(indicador)
	indicador.position = Vector2(0, 0)
	indicador.mostrar_daño(valor, color)

func mostrar_curación(valor: int) -> void:
	var indicador = DAMAGE_INDICATOR.instantiate()
	add_child(indicador)
	indicador.position = Vector2(0, -20)
	indicador.mostrar_daño(valor, Color(0.3, 1.0, 0.3))

var esta_muerto := false

func morir():
	esta_muerto = true
	hide()
	get_tree().call_group("combat_manager", "verificar_derrota")
