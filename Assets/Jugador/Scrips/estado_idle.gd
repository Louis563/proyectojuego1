class_name Estado_Idle extends Estado

@onready var walk: Estado_Walk = $"../Walk"

## Que pasa cuando el jugador entra en este estado?
func Enter() -> void:
	jugador.UpdateAnimacion( "idle" )
	pass

## Que pasa cuando el jugador sale de este estado?
func Exit() -> void:
	pass

func Proceso( _delta : float ) -> Estado:
	if jugador.direccion != Vector2.ZERO:
		return walk
	jugador.velocity = Vector2.ZERO
	return null

## Que pasa durante el _physics_process update en este estado?
func Fisicas( _delta : float ) -> Estado:
	return null

## Que pasa con el input en este estado?
func HandleInput( _event: InputEvent ) -> Estado:
	return null
