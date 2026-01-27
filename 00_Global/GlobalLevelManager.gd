extends Node

signal level_load_started
signal level_loaded
signal TileMapBoundsChanged( bounds : Array[ Vector2 ] )

var current_tilemap_bounds : Array [ Vector2 ]
var target_transition : String
var position_offset : Vector2

var levels := [
    "res://Mapas/Granja.tscn", 
    "res://Mapas/Llano.tscn", 
    "res://Mapas/Bosque.tscn", 
    "res://Mapas/Paramo.tscn"
]
var current_level_index := 0

func can_go_to_next_level() -> bool:
    match current_level_index:
        0: # Granja -> Llanos
            return GameState.npc_jose_done and GameState.boss_granja_defeated

        1: # Llanos -> Bosque
            return GameState.npc_indio_done and GameState.boss_llanos_defeated

        2: # Bosque -> Paramo (boss final)
            return (
                GameState.npc_huesitos_done
                and GameState.npc_ramon_done
                and GameState.boss_bosque_defeated
            )
		
        3: # Paramo -> fin
            return GameState.boss_final_defeated
	
    return false

func go_to_next_level():
    if not can_go_to_next_level():
        print("Aun no se cumplen las condiciones para avanzar")
        return

    current_level_index += 1
    
    if current_level_index < levels.size():
        var next_level = levels[current_level_index]
        get_tree().call_deferred("change_scene_to_file", next_level)
    else:
        print("¡Ganaste el juego!")
        # Aquí podrías volver al menú principal o reiniciar
        #current_level_index = 0 
        #get_tree().change_scene_to_file("res://Menus/Creditos.tscn")

func ChangeTilemapBounds( bounds : Array[ Vector2 ] ) -> void:
    current_tilemap_bounds = bounds
    TileMapBoundsChanged.emit( bounds )

func load_new_level(
    level_path : String,
    _target_transition : String,
    _position_offset : Vector2    
) -> void:

    get_tree().paused = true
    target_transition = _target_transition
    position_offset = _position_offset

    await get_tree().process_frame

    level_load_started.emit()

    await get_tree().process_frame

    get_tree().change_scene_to_file( level_path )

    await get_tree().process_frame

    get_tree().paused = false

    await get_tree().process_frame

    level_loaded.emit()

    pass