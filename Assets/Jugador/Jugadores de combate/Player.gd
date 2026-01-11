extends Node2D
class_name Player


# --- Stats principales ---
var nombre: String = "Jugador"
var max_hp: int = 100
var hp: int = 100
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
	hp = min(hp + amount, max_hp)
	print(nombre, " se cura ", amount, " HP. HP actual: ", hp)

func restore_mp(amount: int):
	mp = min(mp + amount, max_mp)
	print(nombre, " recupera ", amount, " MP. MP actual: ", mp)

func cure_status():
	print(nombre, " ha sido curado de estados alterados.")

func revive():
	if not alive:
		alive = true
		hp = int(floor(max_hp / 2))
		print(nombre, " ha sido revivido con ", hp, " HP.")
		show()

func take_damage(amount: int):
	var damage = max(amount - defense, 0)
	hp -= damage
	print(nombre, " recibe ", damage, " de daño. HP restante: ", hp)
	if hp <= 0 and alive:
		alive = false
		die()

func die():
	print(nombre, " ha sido derrotado.")
	hide()
