extends Node2D
class_name Player

var nombre = "Pedro"
var hp = 100
var mp = 20
var attack = 15
var defense = 5
var alive = true

func take_damage(amount):
	hp -= max(0, amount - defense)
	if hp <= 0:
		alive = false
		die()

func die():
	queue_free()
