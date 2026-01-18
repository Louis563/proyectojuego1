extends Node2D

@onready var label = $Label
@onready var anim = $AnimationPlayer

func mostrar_daño(valor: int):
	label.text = str(valor)
	anim.play("flotar")
