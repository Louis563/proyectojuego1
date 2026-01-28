extends Node2D
class_name Enemy

# --- Atributos básicos ---
var nombre: String = "Goblin"
var hp: int = 150
var attack: int = 40
var defense: int = 3
var alive: bool = true

# Preload del indicador de daño
const DAMAGE_INDICATOR = preload("res://Assets/Interfaz de usuario/UI PIXEL ART IA/Indicador_de_daño.tscn")

# --- Recibir daño ---
func take_damage(amount: int) -> void:
	# Calcula daño neto considerando defensa
	var damage = max(0, amount - defense)
	hp -= damage
	print(nombre, " recibe ", damage, " de daño. HP restante: ", hp)

	# Mostrar indicador de daño
	_mostrar_indicador(damage)

	if hp <= 0 and alive:
		alive = false
		die()

# --- Mostrar daño flotante ---
func _mostrar_indicador(valor: int) -> void:
		var indicador = DAMAGE_INDICATOR.instantiate()

		# 👇 Ahora el indicador es HIJO del enemigo
		add_child(indicador)

		# Lo colocamos un poco encima del origen del enemigo
		indicador.position = Vector2(0, 0)

		indicador.mostrar_daño(valor)




# --- Morir ---
func die():
	print(nombre, " ha sido derrotado.")
	alive = false
	hide()   # 👈 se oculta visualmente, pero no se borra
