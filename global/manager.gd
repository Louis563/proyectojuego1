extends Node
signal jugador_selecciona_enemigo()

var turno_jugador : bool = true 
var puede_abrir_menu: bool = true

func empezar_ataque():
	puede_abrir_menu = false
	emit_signal("jugador_selecciona_enemigo")

func cambiar_turno():
	turno_jugador != turno_jugador
	
