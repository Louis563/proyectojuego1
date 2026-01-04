extends CharacterBody2D

@export var data : DataPlayer

func _ready():
	$Control.abrir_menu()
	
	if data.jugador == false :
		Manager.connect("jugador_selecciona_enemigo",mostrar_seleccion())

func mostrar_seleccion():
	$seleccionar.visible = true;
