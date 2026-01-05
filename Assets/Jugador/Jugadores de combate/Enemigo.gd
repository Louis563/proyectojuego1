extends Node2D
class_name Enemy

var nombre = "Goblin"
var hp = 50
var attack = 10
var defense = 3
var alive = true

func take_damage(amount):
	hp -= max(0, amount - defense)
	if hp <= 0:
		alive = false
		die()

func die():
	queue_free()
