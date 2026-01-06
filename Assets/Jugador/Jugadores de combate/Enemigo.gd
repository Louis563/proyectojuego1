extends Node2D
class_name Enemy

# --- Atributos básicos ---
var nombre: String = "Goblin"
var hp: int = 50
var attack: int = 10
var defense: int = 3
var alive: bool = true

# --- Recibir daño ---
func take_damage(amount: int) -> void:
	# Calcula daño neto considerando defensa
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
