
class_name EnemyStateWander extends EnemyState
func init():
	pass
@export var anim_name : String = "walk_down" # Valor por defecto seguro
@export var wander_speed : float = 20.0

@export_category("AI")
@export var state_animation_duration : float = 0.5
@export var state_cycles_min : int = 1
@export var state_cycles_max : int = 3
@export var next_state : EnemyState

var _timer : float = 0.0
var _direction : Vector2

func _ready() -> void:
	pass

## Que pasa cuando el jugador entra en este estado?
func Enter() -> void:
	_timer = randi_range( state_cycles_min, state_cycles_max ) * state_animation_duration
	var rand = randi_range( 0,3 )
	_direction = enemy.DIR_4[ rand ]
	enemy.velocity = _direction * wander_speed
	enemy.set_direction( _direction )
	# Selecciona animación según dirección
	var anim = "walk_down"
	if _direction == Vector2.UP:
		anim = "walk_up"
	elif _direction == Vector2.LEFT or _direction == Vector2.RIGHT:
		anim = "walk_side"
	enemy.UpdateAnimacion( anim )
	pass

## Que pasa cuando el jugador sale de este estado?
func Exit() -> void:
	pass

func Proceso( _delta : float ) -> EnemyState:
	_timer -= _delta
	# Si el jugador está cerca, cambiar a Follow
	if enemy and enemy.jugador:
		var to_player = enemy.jugador.global_position - enemy.global_position
		if to_player.length() < 96:
			if state_machine and state_machine.has_node("Follow"):
				return state_machine.get_node("Follow")
	# Si termina el tiempo, cambiar a next_state
	if _timer <= 0:
		return next_state
	return null

## Que pasa durante el _physics_process?
func Fisicas( _delta : float ) -> EnemyState:
	return null
