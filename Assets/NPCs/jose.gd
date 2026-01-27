extends CharacterBody2D

func _ready():
	if GameState.npc_jose_done:
		queue_free()

func on_dialog_finished():
	GameState.npc_jose_done = true
	GameState.magia_jose = true
	queue_free()