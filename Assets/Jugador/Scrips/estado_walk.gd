class_name Estado_Walk extends Estado

@export var vel_mov : float = 100.0

@onready var idle: Estado = $"../Idle"

## Que pasa cuando el jugador entra en este estado?
func Enter() -> void:
	jugador.UpdateAnimacion( "walk" )
	pass

## Que pasa cuando el jugador sale de este estado?
func Exit() -> void:
	pass

func Proceso( _delta : float ) -> Estado:
	if jugador.direccion == Vector2.ZERO:
		return idle
	
	jugador.velocity = jugador.direccion * vel_mov
	
	if jugador.SetDireccion():
		jugador.UpdateAnimacion("walk")
	
	return null

## Que pasa durante el _physics_process update en este estado?
func Fisicas( _delta : float ) -> Estado:
	return null

## Que pasa con el input en este estado?
func HandleInput( _event: InputEvent ) -> Estado:
	return null
