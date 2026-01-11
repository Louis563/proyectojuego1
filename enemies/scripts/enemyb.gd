class_name EnemyB extends CharacterBody2D

signal direction_changed( new_direction : Vector2 )

const DIR_4 = [ Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP ]


var cardinal_direction : Vector2 = Vector2.DOWN
var direction : Vector2 = Vector2.ZERO
var jugador = null
var invulnerable : bool = false

# --- Movimiento ---
var speed : float = 100

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite2D = $Sprite2D
@onready var state_machine : EnemyStateMachine = $EnemyStateMachine

func _ready() -> void:
	state_machine.inicializar( self )
	# Buscar jugador en la escena si no está asignado
	if not jugador:
		var player_node = get_tree().get_root().get_node_or_null("Assets/Jugador/jugador")
		if not player_node:
			player_node = get_tree().get_root().get_node_or_null("Jugador")
		# Búsqueda profunda si no se encontró por ruta
		if not player_node:
			player_node = _find_node_by_type("CharacterBody2D", "Jugador")
		if not player_node and Engine.has_singleton("PlayerManager"):
			player_node = Engine.get_singleton("PlayerManager").jugador
		jugador = player_node

# Busca un nodo por nombre y tipo en todo el árbol
func _find_node_by_type(_unused: String, node_name: String) -> Node:
	var root = get_tree().get_root()
	for child in root.get_children():
		var found = _recursive_find(child, node_name)
		if found:
			return found
	return null

func _recursive_find(node: Node, node_name: String) -> Node:
	if node.name == node_name and node is CharacterBody2D:
		return node
	for child in node.get_children():
		var found = _recursive_find(child, node_name)
		if found:
			return found
	return null

func _physics_process(_delta: float) -> void:
		if jugador != null:
			var to_player = jugador.global_position - global_position
			if to_player.length() < 32: # Distancia de parada (ajusta si lo deseas)
				velocity = Vector2.ZERO
				set_direction(Vector2.ZERO)
			else:
				var dir = to_player.normalized()
				velocity = dir * speed
				set_direction(dir)
			move_and_slide()
		else:
			velocity = Vector2.ZERO
			move_and_slide()

func set_direction( _new_direction : Vector2 ) -> bool:
	direction = _new_direction
	if direction == Vector2.ZERO:
		return false
	
	var direction_id : int = int( round ( 
		(direction + cardinal_direction * 0.1).angle() / TAU * DIR_4.size()
	))
	var new_dir = DIR_4[ direction_id ]

	if new_dir == cardinal_direction:
		return false

	cardinal_direction = new_dir
	direction_changed.emit(new_dir)
	sprite.scale.x = -1 if cardinal_direction == Vector2.LEFT else 1
	return true

func UpdateAnimacion( estado : String ) -> void:
	animation_player.play(estado)

func AimDirection() -> String:
	if cardinal_direction == Vector2.DOWN:
		return "down"
	elif cardinal_direction == Vector2.UP:
		return "up"
	else:
		return "side"
