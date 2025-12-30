class_name JugadorMaquinaEstado extends Node

var estados : Array[ Estado ]
var prev_estado : Estado
var actual_estado : Estado

# Llamar cuando el nodo entra en la escena tree por primera vez
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	pass

# Llamar a cada frame
func _process( delta ):
	CambiarEstado( actual_estado.Proceso( delta ) )
	pass

func _physics_process( delta ):
	CambiarEstado( actual_estado.Fisicas( delta ) )
	pass

func _unhandled_input( event ):
	CambiarEstado( actual_estado.HandleInput( event ) )
	pass

func Inicializar( _jugador : Jugador ) -> void:
	estados = []
	
	for c in get_children():
		if c is Estado:
			estados.append(c)
	
	if estados.size() > 0:
		estados[0].jugador = _jugador
		CambiarEstado( estados[0] )
		process_mode = Node.PROCESS_MODE_INHERIT

func CambiarEstado( estado_nuevo : Estado ) -> void:
	if estado_nuevo == null || estado_nuevo == actual_estado:
		return
	if actual_estado:
		actual_estado.Exit()
	
	prev_estado = actual_estado
	actual_estado = estado_nuevo
	actual_estado.Enter()
