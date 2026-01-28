class_name Jose extends CharacterBody2D

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "jose_start"

var is_player_in_range := false
var dialogue_active := false

const jose_D = preload("res://Assets/NPCs/Dialogo/jose.dialogue")

func _ready():
	if GameState.npc_jose_done:
		queue_free()

func _input(event):
	if event.is_action_pressed("ui_accept") and is_player_in_range and not dialogue_active:
		start_dialogue()

func start_dialogue():
	dialogue_active = true
	print("Iniciando diálogo con José...")

	var balloon = DialogueManager.show_dialogue_balloon(jose_D, "start")

	if balloon:
		balloon.tree_exited.connect(_on_dialogue_finished, CONNECT_ONE_SHOT)
	else:
		print("ERROR: No se pudo crear el balloon")
		dialogue_active = false

func _on_dialogue_finished():
	print("Diálogo terminado")
	GameState.npc_jose_done = true
	GameState.magia_jose = true
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("PlayerT"):
		is_player_in_range = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("PlayerT"):
		is_player_in_range = false
