class_name EnemyState extends Node


var enemy : EnemyB
var state_machine : EnemyStateMachine

func _ready() -> void:
	pass

## Que pasa cuando el jugador entra en este estado?
func Enter() -> void:
	pass

## Que pasa cuando el jugador sale de este estado?
func Exit() -> void:
	pass

func Proceso( _delta : float ) -> EnemyState:
	return null

## Que pasa durante el _physics_process?
func Fisicas( _delta : float ) -> EnemyState:
	return null