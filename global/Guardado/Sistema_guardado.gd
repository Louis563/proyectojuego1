extends Node

# Ruta de guardado por slot
const SAVE_PATH := "user://save_%d.json"

# Guarda datos en el slot, agrega marca de tiempo HH:MM y acumula minutos de juego
func guardar(slot: int, datos: Dictionary) -> void:
	var path := SAVE_PATH % slot
	print("[Sistema_guardado] Guardando slot %d -> %s" % [slot, path])

	# Timestamp HH:MM. Si 'timestamp' viene en los datos lo uso, en caso contrario queda '00:00'
	var hhmm = str(datos.get("timestamp", "00:00"))

	# Leo datos existentes si los hay para sumar el tiempo de juego acumulado
	var existing: Dictionary = {}
	if FileAccess.file_exists(path):
		var f_read := FileAccess.open(path, FileAccess.READ)
		var content := f_read.get_as_text()
		f_read.close()
		var parsed = JSON.parse_string(content)
		if typeof(parsed) == TYPE_DICTIONARY:
			if parsed.has("result") and typeof(parsed["result"]) == TYPE_DICTIONARY:
				existing = parsed["result"]
			else:
				existing = parsed

	# Si se envían 'session_minutes' los sumo al acumulado
	var session_minutes := 0
	if datos.has("session_minutes"):
		session_minutes = int(datos["session_minutes"])
		datos.erase("session_minutes")

	var acumulado := int(existing.get("playtime_minutes", 0)) + session_minutes
	datos["playtime_minutes"] = acumulado
	datos["timestamp"] = hhmm

	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(datos))
	file.close()
	print("[Sistema_guardado] Guardado completo para slot %d (playtime_minutes=%d)" % [slot, acumulado])


# Carga el slot y devuelve un Dictionary vacío si no existe
func cargar_slot(slot: int) -> Dictionary:
	var path := SAVE_PATH % slot
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(content)

	if typeof(parsed) == TYPE_DICTIONARY:
		if parsed.has("result") and typeof(parsed["result"]) == TYPE_DICTIONARY:
			return parsed["result"]
		return parsed

	return {}


# Guarda solo la posición del jugador; acepta minutos de sesión opcionales
func guardar_posicion_jugador(slot: int, pos, session_minutes: int = 0) -> void:
	var datos := {"position": {"x": pos.x, "y": pos.y}, "session_minutes": session_minutes}
	print("[Sistema_guardado] guardar_posicion_jugador slot=%d pos=%s session_minutes=%d" % [slot, pos, session_minutes])
	guardar(slot, datos)


# Devuelve la posición guardada como Vector2 o null si no existe
func obtener_posicion_jugador(slot: int):
	var data := cargar_slot(slot)
	if typeof(data) != TYPE_DICTIONARY:
		return null
	if not data.has("position"):
		return null
	var p: Variant = data["position"]
	if typeof(p) == TYPE_DICTIONARY and p.has("x") and p.has("y"):
		return Vector2(p["x"], p["y"])
	return null


func slot_existe(slot: int) -> bool:
	return FileAccess.file_exists(SAVE_PATH % slot)
# Wrappers para compatibilidad con nombres antiguos
func save(slot: int, data: Dictionary) -> void:
	guardar(slot, data)

func load_slot(slot: int) -> Dictionary:
	return cargar_slot(slot)

func save_player_position(slot: int, pos) -> void:
	guardar_posicion_jugador(slot, pos, 0)

func get_player_position(slot: int):
	return obtener_posicion_jugador(slot)

func slot_exists(slot: int) -> bool:
	return slot_existe(slot)
