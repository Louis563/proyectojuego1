extends Node

# Gestor simple de objetos, hecho pa' usar en combate
# API pública traducida al español
signal objeto_usado(nombre_item, target)

var items: Dictionary = {}

func _init():
	items = {}

func agregar_objeto(nombre_item: String, qty: int = 1) -> void:
	if qty <= 0:
		return
	items[nombre_item] = items.get(nombre_item, 0) + qty

func remover_objeto(nombre_item: String, qty: int = 1) -> bool:
	if not items.has(nombre_item) or items[nombre_item] < qty:
		return false
	items[nombre_item] -= qty
	if items[nombre_item] <= 0:
		items.erase(nombre_item)
	return true

func tiene_objeto(nombre_item: String) -> bool:
	return items.has(nombre_item) and items[nombre_item] > 0

func obtener_lista_objetos() -> Array:
	# Mantener orden para la UI
	var keys = items.keys()
	keys.sort()
	var out: Array = []
	for k in keys:
		out.append(str(k) + " x" + str(items[k]))
	return out

func cantidad_objeto(nombre_item: String) -> int:
	return int(items.get(nombre_item, 0))

func usar_objeto(nombre_item: String, target) -> bool:
	if not tiene_objeto(nombre_item):
		return false

	var aplicado = false
	match nombre_item:
		"Poción":
			if target and target.has_method("curar"):
				target.curar(20)
			elif target and target.has("hp"):
				var max_hp = target.max_hp if target.has("max_hp") else target.hp + 20
				target.hp = min(target.hp + 20, max_hp)
			aplicado = true

		"Éter":
			if target and target.has_method("recuperar_mp"):
				target.recuperar_mp(10)
			elif target and target.has("mp"):
				target.mp += 10
			aplicado = true

		"Antídoto":
			if target and target.has_method("curar_estados"):
				target.curar_estados()
			aplicado = true

		"Revivir":
			if target:
				if target.has_method("revivir"):
					target.revivir()
					aplicado = true
				else:
					if target.has("vivo") and not target.vivo:
						target.vivo = true
						if target.has("max_hp"):
							target.hp = int(target.max_hp / 2)
						elif target.has("hp"):
							target.hp = 1
						aplicado = true
					else:
						aplicado = false
			else:
				aplicado = false

		_:
			aplicado = true

	if aplicado:
		remover_objeto(nombre_item, 1)
		emit_signal("objeto_usado", nombre_item, target)
		return true

	return false
