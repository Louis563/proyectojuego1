
class_name EnemyStateIdle extends EnemyState
func init():
	pass
@export var anim_name : String = "idle"

@export_category("AI")
@export var state_duration_min : float = 0.5
@export var state_duration_max : float = 1.5
@export var after_idle_state : EnemyState

var _timer : float = 0.0

func _ready() -> void:
	pass

## Que pasa cuando el jugador entra en este estado?
func Enter() -> void:
	enemy.velocity = Vector2.ZERO
	_timer = randf_range( state_duration_min, state_duration_max )
	enemy.UpdateAnimacion( anim_name )
	pass

## Que pasa cuando el jugador sale de este estado?
func Exit() -> void:
	pass

func Proceso( _delta : float ) -> EnemyState:
	_timer -= _delta
	if _timer <= 0:
		return after_idle_state
	return null

## Que pasa durante el _physics_process?
func Fisicas( _delta : float ) -> EnemyState:
	return null
