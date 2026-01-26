extends Node2D
class_name Player


const DAMAGE_INDICATOR = preload("res://Assets/Interfaz de usuario/UI PIXEL ART IA/Indicador_de_daño.tscn")

# --- Stats principales ---
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
var alive: bool = true

# --- Métodos de utilidad para objetos ---
func heal(amount: int):
		var before = hp
		hp = min(hp + amount, max_hp)
		var healed = hp - before

		if healed > 0:
			mostrar_curación(healed)

		print(nombre, " se cura ", healed, " HP. HP actual: ", hp)

func restore_mp(amount: int):
	mp = min(mp + amount, max_mp)
	print(nombre, " recupera ", amount, " MP. MP actual: ", mp)

func cure_status():
	print(nombre, " ha sido curado de estados alterados.")

func revive():
	if not alive:
		alive = true
		hp = floor(max_hp / 2)
		print(nombre, " ha sido revivido con ", hp, " HP.")
		show()

func take_damage(amount: int):
		var damage = max(amount - defense, 0)
		hp -= damage
		mostrar_daño_recibido(damage, Color.YELLOW)
		print(nombre, " recibe ", damage, " de daño. HP restante: ", hp)
		if hp <= 0 and alive:
			alive = false
			die()

func mostrar_daño_recibido(valor: int, color: Color) -> void:
		var indicador = DAMAGE_INDICATOR.instantiate()
		add_child(indicador)
		indicador.position = Vector2(0, 0)
		indicador.mostrar_daño(valor, color)

func mostrar_curación(valor: int) -> void:
		var indicador = DAMAGE_INDICATOR.instantiate()
		add_child(indicador)
		indicador.position = Vector2(0, -20)

		# Verde para curación
		indicador.mostrar_daño(valor, Color(0.3, 1.0, 0.3))
	

var is_dead := false

func die():
		is_dead = true
		hide()
		get_tree().call_group("combat_manager", "verificar_derrota")
