extends CanvasLayer

# --- Señales en español ---
signal atacar_presionado
signal defender_presionado
signal magia_presionada
signal objeto_presionado
signal magia_seleccionada(spell_name)
signal objeto_seleccionado(item_name)

@onready var magic_menu = $MagicMenu
@onready var item_menu = $ItemMenu

func _ready():
	# Conexión de botones principales
	$ActionMenu/VBoxContainer/attack.connect("pressed", Callable(self, "_on_bt_atacar_pressed"))
	$ActionMenu/VBoxContainer/defend.connect("pressed", Callable(self, "_on_bt_defender_pressed"))
	$ActionMenu/VBoxContainer/magic.connect("pressed", Callable(self, "_on_bt_magia_pressed"))
	$ActionMenu/VBoxContainer/item.connect("pressed", Callable(self, "_on_bt_items_pressed"))

	# Conexión de submenús
	magic_menu.connect("id_pressed", Callable(self, "_on_magic_selected"))
	item_menu.connect("id_pressed", Callable(self, "_on_item_selected"))

# --- Botones principales ---
func _on_bt_atacar_pressed():
	emit_signal("atacar_presionado")

func _on_bt_defender_pressed():
	emit_signal("defender_presionado")

func _on_bt_magia_pressed():
	emit_signal("magia_presionada")
	# Ejemplo: mostrar lista de magias
	show_magic_menu(["Fuego", "Hielo", "Rayo"])

func _on_bt_items_pressed():
	emit_signal("objeto_presionado")
	# Ejemplo: mostrar lista de items
	show_item_menu(["Poción", "Éter", "Antídoto"])

# --- Submenús ---

func show_menu(active_player):
		# Aquí puedes personalizar el menú según el jugador activo
		visible = true
		print("Turno de ", active_player.nombre, ". Menú mostrado.")


func show_magic_menu(spells: Array):
	magic_menu.clear()
	for spell in spells:
		magic_menu.add_item(spell)
	magic_menu.popup_centered()

func show_item_menu(items: Array):
	item_menu.clear()
	# items debe ser un array de strings tipo "Poción x3"
	for item in items:
		item_menu.add_item(item)
	item_menu.popup_centered()

func _on_magic_selected(id):
	var spell = magic_menu.get_item_text(id)
	emit_signal("magia_seleccionada", spell)

func _on_item_selected(id):
	var item = item_menu.get_item_text(id)
	emit_signal("objeto_seleccionado", item)
