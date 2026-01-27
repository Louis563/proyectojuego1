extends Control

var slot_seleccionado := 0
var mode := "load" # "load" or "save"

func _ready():
	# default update; if opened via `open(mode)` it'll refresh again
	$slot1.text = get_slot_text(1)
	$slot2.text = get_slot_text(2)
	$slot3.text = get_slot_text(3)

	# Connect signals in case the TSCN doesn't have them connected
	var c1 := Callable(self, "_on_slot1_pressed")
	var c2 := Callable(self, "_on_slot2_pressed")
	var c3 := Callable(self, "_on_slot3_pressed")
	if not $slot1.is_connected("pressed", c1):
		$slot1.connect("pressed", c1)
	if not $slot2.is_connected("pressed", c2):
		$slot2.connect("pressed", c2)
	if not $slot3.is_connected("pressed", c3):
		$slot3.connect("pressed", c3)

	# Create a small message label (HUD) for transient messages
	if not has_node("Mensaje"):
		var lbl := Label.new()
		lbl.name = "Mensaje"
		lbl.text = ""
		lbl.visible = false
		add_child(lbl)

	# Timer to hide the message
	if not has_node("MensajeTimer"):
		var t := Timer.new()
		t.name = "MensajeTimer"
		t.one_shot = true
		add_child(t)
		t.connect("timeout", Callable(self, "_on_MensajeTimer_timeout"))

	# Connect Confirmacion 'confirmed' signal to handler if not already
	var c4 := Callable(self, "_on_Confirmacion_confirmed")
	if not $Confirmacion.is_connected("confirmed", c4):
		$Confirmacion.connect("confirmed", c4)


func _show_message(text: String, duration: float = 2.0) -> void:
	# Show a transient HUD message; fallback to Confirmacion if HUD missing
	if has_node("Mensaje"):
		$Mensaje.text = text
		$Mensaje.visible = true
		if has_node("MensajeTimer"):
			$MensajeTimer.start(duration)
	else:
		$Confirmacion.dialog_text = text
		$Confirmacion.popup_centered()

func _on_MensajeTimer_timeout() -> void:
	if has_node("Mensaje"):
		$Mensaje.visible = false

func open(new_mode: String = "load") -> void:
	mode = new_mode
	# refresh labels
	$slot1.text = get_slot_text(1)
	$slot2.text = get_slot_text(2)
	$slot3.text = get_slot_text(3)
	show()

func get_slot_text(slot: int) -> String:
	if not Sistema_guardado.slot_exists(slot):
		return "Slot %d - Vacío" % slot
	var pos: Variant = Sistema_guardado.get_player_position(slot)
	if pos == null:
		return "Slot %d - Guardado" % slot
	return "Slot %d - Pos:(%d,%d)" % [slot, int(pos.x), int(pos.y)]

func _on_slot1_pressed(): seleccionar_slot(1)
func _on_slot2_pressed(): seleccionar_slot(2)
func _on_slot3_pressed(): seleccionar_slot(3)

func seleccionar_slot(slot: int):
	if not Sistema_guardado.slot_exists(slot):
		# If saving to an empty slot, allow it (we'll still select it)
		pass
	slot_seleccionado = slot
	if mode == "save":
		$Confirmacion.dialog_text = "¿Guardar en el Slot %d?" % slot
	else:
		$Confirmacion.dialog_text = "¿Cargar el Slot %d?" % slot
	$Confirmacion.popup_centered()

func _on_Confirmacion_confirmed():
	if mode == "save":
		# Save player position in this slot
		var player := PlayerManager.jugador if typeof(PlayerManager) != TYPE_NIL else null
		if player != null:
			Sistema_guardado.save_player_position(slot_seleccionado, player.global_position)
			_show_message("Guardado en Slot %d." % slot_seleccionado, 2.0)
			# Close the menu after saving
			queue_free()
		else:
			_show_message("No se encontró el jugador para guardar.", 2.0)
		# Note: menu is closed on successful save; if needed, parent will re-open later
		return

	# load mode
	var data := Sistema_guardado.load_slot(slot_seleccionado)
	# Verificar que `load_slot` devolvió un Dictionary válido y no vacío
	if typeof(data) != TYPE_DICTIONARY or data.size() == 0:
		$Confirmacion.dialog_text = "No se pudo cargar el Slot %d." % slot_seleccionado
		$Confirmacion.popup_centered()
		return

	# Delegate applying data to the parent scene (e.g., Paramo)
	if has_method("_apply_loaded_data"):
		call("_apply_loaded_data", data)
	elif get_parent() != null and get_parent().has_method("load_game_data"):
		get_parent().load_game_data(data)
	else:
		# fallback: try PlayerManager
		if typeof(PlayerManager) != TYPE_NIL and data.has("position"):
			var p: Variant = data["position"]
			if typeof(p) == TYPE_DICTIONARY and p.has("x") and p.has("y"):
				var player_node := PlayerManager.jugador
				if player_node != null:
					player_node.global_position = Vector2(p["x"], p["y"])

	# Show confirmation message for successful load and hide the menu
	_show_message("Cargado en Slot %d." % slot_seleccionado, 2.0)
	hide()
	# refresh labels after load
	$slot1.text = get_slot_text(1)
	$slot2.text = get_slot_text(2)
	$slot3.text = get_slot_text(3)
