extends Node2D
class_name Enemigo

# Atributos básicos, mano
var nombre: String = "Goblin"
var hp: int = 100
var attack: int = 40
var defense: int = 3
var vivo: bool = true

# Cargo el indicador de daño
const DAMAGE_INDICATOR = preload("res://Assets/Interfaz de usuario/UI PIXEL ART IA/Indicador_de_daño.tscn")

# Cuando recibe daño, resto defensa y muestro
func recibir_daño(cantidad: float) -> void:
	# calculo daño neto
	var daño = max(0, int(round(cantidad)) - defense)
	hp -= daño
	print(nombre, " recibe ", daño, " de daño. HP restante: ", hp)

	# muestro el numerito flotante
	_mostrar_indicador(daño)

	if hp <= 0 and vivo:
		vivo = false
		morir()

# Muestro daño flotante encima del enemigo
func _mostrar_indicador(valor: int) -> void:
	var indicador = DAMAGE_INDICATOR.instantiate()
	# lo meto como hijo del enemigo
	add_child(indicador)
	indicador.position = Vector2(0, 0)
	indicador.mostrar_daño(valor)

# Cuando se muere lo oculto
func morir():
	print(nombre, " ha sido derrotado.")
	vivo = false
	hide()
	hide()   # 👈 se oculta visualmente, pero no se borra
