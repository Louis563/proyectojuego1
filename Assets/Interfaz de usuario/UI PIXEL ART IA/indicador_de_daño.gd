extends Node2D

@onready var label: Label = $Label
@onready var anim: AnimationPlayer = $AnimationPlayer

func mostrar_daño(valor: int, color: Color = Color.RED) -> void:
    label.text = str(valor)

    # Forzar color del texto, ignorando el Theme
    label.add_theme_color_override("font_color", color)

    # Opcional: por si usas modulate en el nodo
    label.self_modulate = Color.WHITE

    anim.play("flotar")
