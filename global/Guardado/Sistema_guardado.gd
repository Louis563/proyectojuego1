extends Node

const SAVE_PATH := "user://save_%d.json"

func save(slot: int, data: Dictionary) -> void:
	var path := SAVE_PATH % slot
	print("[Sistema_guardado] Saving slot %d -> %s" % [slot, path])
	print("[Sistema_guardado] Data: %s" % [data])
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	print("[Sistema_guardado] Save complete for slot %d" % slot)

func load_slot(slot: int) -> Dictionary:
	var path := SAVE_PATH % slot
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	# Parse JSON robustly and return only the Dictionary with game data.
	var parsed: Variant = JSON.parse_string(content)

	# If parse returned a Dictionary (common in Godot 3), unwrap if needed
	if typeof(parsed) == TYPE_DICTIONARY:
		if parsed.has("result") and typeof(parsed["result"]) == TYPE_DICTIONARY:
			return parsed["result"]
		return parsed

	# Fallback: parsing failed or returned unexpected type
	return {}

# Helper: guarda solo la posición del jugador (Vector2) en el slot
func save_player_position(slot: int, pos) -> void:
	var data := {"position": {"x": pos.x, "y": pos.y}}
	print("[Sistema_guardado] save_player_position slot=%d pos=%s" % [slot, pos])
	save(slot, data)

# Helper: devuelve la posición guardada en el slot como Vector2, o null si no existe
func get_player_position(slot: int):
	var data := load_slot(slot)
	if typeof(data) != TYPE_DICTIONARY:
		return null
	if not data.has("position"):
		return null
	var p: Variant = data["position"]
	if typeof(p) == TYPE_DICTIONARY and p.has("x") and p.has("y"):
		return Vector2(p["x"], p["y"])
	return null

func slot_exists(slot: int) -> bool:
	return FileAccess.file_exists(SAVE_PATH % slot)
