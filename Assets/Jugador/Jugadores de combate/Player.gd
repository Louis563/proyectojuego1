extends Node2D
class_name Player

# --- Atributos básicos ---
var nombre: String = "Pedro"
var hp: int = 100
var mp: int = 20
var attack: int = 15
var defense: int = 5
var alive: bool = true

# --- Recibir daño ---
func take_damage(amount: int) -> void:
	var damage = max(0, amount - defense)
	hp -= damage
	print(nombre, " recibe ", damage, " de daño. HP restante: ", hp)

	if hp <= 0 and alive:
		alive = false
		die()

# --- Morir ---
func die() -> void:
	print(nombre, " ha sido derrotado.")
	queue_free()
