
class_name EnemyStateFollow extends EnemyState
func init():
	pass
@export var follow_duration : float = 2.0
var _timer : float = 0.0

func Fisicas(_delta):
	if not enemy or not enemy.jugador:
		return self
	var to_player = enemy.jugador.global_position - enemy.global_position
	# Si está cerca, cambiar a la escena de combate inmediatamente
	if to_player.length() < 64:
		enemy.set_direction(Vector2.ZERO)
		enemy.velocity = Vector2.ZERO
		if enemy.has_node("AnimationPlayer"):
			enemy.get_node("AnimationPlayer").stop()
		var combate_scene = preload("res://Mapas/Escenarios de combate/Tutorial de combate.tscn")
		get_tree().change_scene_to_packed(combate_scene)
		return null
	# Si el jugador se aleja demasiado, volver a Wander
	elif to_player.length() > 120:
		if state_machine and state_machine.has_node("Wander"):
			return state_machine.get_node("Wander")
	else:
		enemy.set_direction(to_player.normalized())
		var speed = float(enemy.speed) if "speed" in enemy else 100.0
		enemy.velocity = to_player.normalized() * speed
	return null

func Enter():
	_timer = follow_duration

func Exit():
	enemy.velocity = Vector2.ZERO

func Proceso(_delta):
	_timer -= _delta
	if _timer <= 0:
		# Volver a Wander si existe
		if state_machine and state_machine.has_node("Wander"):
			return state_machine.get_node("Wander")
	return null
