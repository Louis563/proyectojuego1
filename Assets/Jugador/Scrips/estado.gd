class_name Estado extends Node

## Guarda la referencia del jugador al que este estado pertenece?
static var jugador : Jugador

func _ready() -> void:
	pass

## Que pasa cuando el jugador entra en este estado?
func Enter() -> void:
	pass

## Que pasa cuando el jugador sale de este estado?
func Exit() -> void:
	pass

func Proceso( _delta : float ) -> Estado:
	return null

## Que pasa durante el _physics_process?
func Fisicas( _delta : float ) -> Estado:
	return null

## Que pasa con el input en este estado?
func HandleInput( _event: InputEvent ) -> Estado:
	return null
