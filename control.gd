extends Control

func _ready():
	cerrar_menu()

func abrir_menu():
	visible = true

func cerrar_menu():
	visible = false

func _on_bt_atacar_button_down() -> void:
	cerrar_menu()
	print("ATACO")
	abrir_menu()


func _on_bt_defender_button_down() -> void:
	cerrar_menu()
	print("DEFENDIO")
	abrir_menu()


func _on_bt_objetos_button_down() -> void:
	cerrar_menu()
	print("ABRIO OBJETOS")
	abrir_menu()
