class_name Jugador extends CharacterBody2D

var direccion : Vector2 = Vector2.ZERO
var direcciones : Vector2 = Vector2.DOWN
#var estado : String = "idle"
#var move_speed : float = 100.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var maquina_estado: JugadorMaquinaEstado = $MaquinaEstado

func _ready() -> void:
	maquina_estado.Inicializar( self )
	pass

func _process(_delta: float) -> void:
	
	direccion.x = Input.get_action_strength("Derecha") - Input.get_action_strength("Izquierda")
	direccion.y = Input.get_action_strength("Abajo") - Input.get_action_strength("Arriba")
	
	#velocity = direccion * move_speed
	
	#if SetEstado() == true || SetDireccion() == true:
		#UpdateAnimacion()
	
	pass

func _physics_process(_delta: float) -> void:
	move_and_slide()

func SetDireccion() -> bool:
	var new_dir : Vector2 = direcciones
	if direccion == Vector2.ZERO:
		return false
	
	if abs(direccion.x) > abs(direccion.y):
		new_dir = Vector2.LEFT if direccion.x < 0 else Vector2.RIGHT
	else:
		new_dir = Vector2.UP if direccion.y < 0 else Vector2.DOWN
	
	if new_dir == direcciones:
		return false
	
	direcciones = new_dir
	sprite.scale.x = -1 if direcciones == Vector2.LEFT else 1
	return true

#func SetEstado() -> bool:
	#var new_estado : String = "idle" if direccion == Vector2.ZERO else "walk"
	#if new_estado == estado:
		#return false
	#estado = new_estado
	#return true

func UpdateAnimacion( estado : String ) -> void:
	animation_player.play( estado + "_" + AimDirection() )
	pass

func AimDirection() -> String:
	if direcciones == Vector2.DOWN:
		return "down"
	elif direcciones == Vector2.UP:
		return "up"
	else:
		return "side"
