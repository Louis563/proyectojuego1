class_name EnemyStateMachine extends Node

var estados : Array[ EnemyState ]
var prev_estado : EnemyState
var actual_estado : EnemyState

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_DISABLED
    pass

func _process(delta: float) -> void:
    CambiarEstado( actual_estado.Proceso( delta ) )
    pass

func _physics_process(delta: float) -> void:
    CambiarEstado( actual_estado.Fisicas( delta ) )
    pass

func inicializar( _enemy : EnemyB ) -> void:
    estados = []
    
    for c in get_children():
        if c is EnemyState:
            estados.append( c )

    for s in estados:
        s.enemy = _enemy
        s.state_machine = self
        s.init()

    if estados.size() > 0:
        CambiarEstado( estados[0])
        process_mode = Node.PROCESS_MODE_INHERIT
    pass

func CambiarEstado( estado_nuevo : EnemyState ) -> void:
    if estado_nuevo == null || estado_nuevo == actual_estado:
        return
    if actual_estado:
        actual_estado.Exit()
    
    prev_estado = actual_estado
    actual_estado = estado_nuevo
    actual_estado.Enter()
    