extends Node2D
class_name Player

var nombre: String = "Jugador"
var hp: int = 100
var mp: int = 20
var attack: int = 10
var defense: int = 5
var speed: int = 10
var level: int = 1
var exp: int = 0
var alive: bool = true

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
