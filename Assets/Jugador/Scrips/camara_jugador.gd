class_name CamaraJugador extends Camera2D

func _ready():
	LevelManager.TileMapBoundsChanged.connect( ActualizarLimites )
	ActualizarLimites( LevelManager.current_tilemap_bounds )
	pass

func ActualizarLimites( bounds : Array[ Vector2 ] ) -> void:
	if bounds == []:
		return
	limit_left = int( bounds[0].x )
	limit_right = int( bounds[1].x )
	limit_top = int( bounds[0].y )
	limit_bottom = int( bounds[1].y )
	pass
