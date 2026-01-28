extends Control

var slot_seleccionado := 0
var mode := "load" # "load" or "save"

func _ready():
	# Al iniciar actualizo los textos de los slots; si se abre con abrir(mode) se refrescará otra vez
	$slot1.text = obtener_texto_slot(1)
	$slot2.text = obtener_texto_slot(2)
	$slot3.text = obtener_texto_slot(3)

	# Conectar botones por si la escena no viene con las conexiones
	var c1 := Callable(self, "_on_slot1_pressed")
	var c2 := Callable(self, "_on_slot2_pressed")
	var c3 := Callable(self, "_on_slot3_pressed")
	if not $slot1.is_connected("pressed", c1):
		$slot1.connect("pressed", c1)
	if not $slot2.is_connected("pressed", c2):
		$slot2.connect("pressed", c2)
	if not $slot3.is_connected("pressed", c3):
		$slot3.connect("pressed", c3)

	# Creo un Label pequeño para mensajes transitorios
	if not has_node("Mensaje"):
		var lbl = Label.new()
		lbl.name = "Mensaje"
		lbl.text = ""
		lbl.visible = false
		add_child(lbl)

	# Timer para ocultar el mensaje
	if not has_node("MensajeTimer"):
		var t = Timer.new()
		t.name = "MensajeTimer"
		t.one_shot = true
		add_child(t)
		t.connect("timeout", Callable(self, "_on_MensajeTimer_timeout"))

	# Conectar la señal 'confirmed' del nodo Confirmacion si hace falta
	var c4 := Callable(self, "_on_Confirmacion_confirmed")
	if not $Confirmacion.is_connected("confirmed", c4):
		$Confirmacion.connect("confirmed", c4)


func _mostrar_mensaje(text: String, duration: float = 2.0) -> void:
	# Mensaje HUD transitorio; si no existe, uso el popup de confirmación
	if has_node("Mensaje"):
		$Mensaje.text = text
		$Mensaje.visible = true
		if has_node("MensajeTimer"):
			$MensajeTimer.start(duration)
	else:
		$Confirmacion.dialog_text = text
		$Confirmacion.popup_centered()

# Mantengo la firma antigua por compatibilidad
func _show_message(text: String, duration: float = 2.0) -> void:
	_mostrar_mensaje(text, duration)

func _on_MensajeTimer_timeout() -> void:
	if has_node("Mensaje"):
		$Mensaje.visible = false

func abrir(new_mode: String = "load") -> void:
	mode = new_mode
	$slot1.text = obtener_texto_slot(1)
	$slot2.text = obtener_texto_slot(2)
	$slot3.text = obtener_texto_slot(3)
	show()

# Wrapper para compatibilidad
func open(new_mode: String = "load") -> void:
	abrir(new_mode)

func obtener_texto_slot(slot: int) -> String:
	if not Sistema_guardado.slot_existe(slot):
		return "Slot %d - Vacío" % slot
	var pos: Variant = Sistema_guardado.obtener_posicion_jugador(slot)
	var data: Dictionary = Sistema_guardado.cargar_slot(slot)
	if pos == null:
		return "Slot %d - Guardado" % slot
	var time_str = ""
	if typeof(data) == TYPE_DICTIONARY and data.has("timestamp"):
		time_str = " - %s" % str(data["timestamp"])
	var playtime_str = ""
	if typeof(data) == TYPE_DICTIONARY and data.has("playtime_minutes"):
		var mins = int(data["playtime_minutes"])
		var hrs = int(mins / 60.0)
		var rem = int(mins % 60)
		playtime_str = " - Tiempo: %dh %dm" % [hrs, rem]
	return "Slot %d - Pos:(%d,%d)%s%s" % [slot, int(pos.x), int(pos.y), time_str, playtime_str]

# Mantengo el nombre antiguo por compatibilidad
func get_slot_text(slot: int) -> String:
	return obtener_texto_slot(slot)

func _on_slot1_pressed(): seleccionar_slot(1)
func _on_slot2_pressed(): seleccionar_slot(2)
func _on_slot3_pressed(): seleccionar_slot(3)

func seleccionar_slot(slot: int):
	if not Sistema_guardado.slot_existe(slot):
		# Si guarda en slot vacío, igual lo selecciono
		pass
	slot_seleccionado = slot
	if mode == "save":
		$Confirmacion.dialog_text = "¿Guardar en el Slot %d?" % slot
	else:
		$Confirmacion.dialog_text = "¿Cargar el Slot %d?" % slot
	$Confirmacion.popup_centered()

func _on_Confirmacion_confirmed():
	if mode == "save":
		# Guardar posición del jugador en este slot
		var player := PlayerManager.jugador if typeof(PlayerManager) != TYPE_NIL else null
		if player != null:
			# Intento detectar minutos de la sesión si el jugador lo provee
			var session_minutes = 0
			if player.has_method("get_session_minutes"):
				session_minutes = int(player.get_session_minutes())
			elif player.has("session_minutes"):
				session_minutes = int(player.session_minutes)

			Sistema_guardado.guardar_posicion_jugador(slot_seleccionado, player.global_position, session_minutes)
			# Si se desea guardar timestamp, puede pasarse en los datos; el sistema acepta 'session_minutes' y 'timestamp'
			_mostrar_mensaje("Guardado en Slot %d." % slot_seleccionado, 2.0)
			# Cierro el menú después de guardar
			queue_free()
		else:
			_mostrar_mensaje("No se encontró el jugador para guardar.", 2.0)
		return

	# Modo cargar
	var data := Sistema_guardado.cargar_slot(slot_seleccionado)
	# Verificar que devolvió un Dictionary válido y no vacío
	if typeof(data) != TYPE_DICTIONARY or data.size() == 0:
		$Confirmacion.dialog_text = "No se pudo cargar el Slot %d." % slot_seleccionado
		$Confirmacion.popup_centered()
		return

	# Delego la aplicación de datos a la escena padre por ejemplo Paramo
	if has_method("_apply_loaded_data"):
		call("_apply_loaded_data", data)
	elif get_parent() != null and get_parent().has_method("load_game_data"):
		get_parent().load_game_data(data)
	else:
		# Fallback intento con PlayerManager
		if typeof(PlayerManager) != TYPE_NIL and data.has("position"):
			var p: Variant = data["position"]
			if typeof(p) == TYPE_DICTIONARY and p.has("x") and p.has("y"):
				var player_node := PlayerManager.jugador
				if player_node != null:
					player_node.global_position = Vector2(p["x"], p["y"])
					# Si viene playtime lo aplico al nodo jugador si tiene la propiedad
					if data.has("playtime_minutes") and player_node.has("playtime_minutes"):
						player_node.playtime_minutes = int(data["playtime_minutes"])

	_mostrar_mensaje("Cargado en Slot %d." % slot_seleccionado, 2.0)
	hide()
	# Refrescar etiquetas después de cargar
	$slot1.text = obtener_texto_slot(1)
	$slot2.text = obtener_texto_slot(2)
	$slot3.text = obtener_texto_slot(3)
