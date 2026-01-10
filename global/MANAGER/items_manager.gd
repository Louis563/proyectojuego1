extends Node

# Gestor simple de objetos reutilizable
# API pública:
# - add_item(name, qty=1)
# - remove_item(name, qty=1) -> bool
# - has_item(name) -> bool
# - get_item_list() -> Array
# - use_item(name, target) -> bool  (aplica efecto y consume si es posible)

signal item_used(nombre_item, target)

var items: Dictionary = {}

func _init():
	items = {}

func add_item(nombre_item: String, qty: int = 1) -> void:
	if qty <= 0:
		return
	items[nombre_item] = items.get(nombre_item, 0) + qty

func remove_item(nombre_item: String, qty: int = 1) -> bool:
	if not items.has(nombre_item) or items[nombre_item] < qty:
		return false
	items[nombre_item] -= qty
	if items[nombre_item] <= 0:
		items.erase(nombre_item)
	return true

func has_item(nombre_item: String) -> bool:
	return items.has(nombre_item) and items[nombre_item] > 0

func get_item_list() -> Array:
	# Mantener orden predecible
	var keys = items.keys()
	keys.sort()
	# Devolver nombres con cantidad para mostrar en UI, p.ej. "Poción x3"
	var out: Array = []
	for k in keys:
		out.append(str(k) + " x" + str(items[k]))
	return out

func get_item_quantity(nombre_item: String) -> int:
	# Devuelve la cantidad actual del item (0 si no existe)
	return int(items.get(nombre_item, 0))

func use_item(nombre_item: String, target) -> bool:
	# Verificar existencia
	if not has_item(nombre_item):
		return false

	var applied = false
	match nombre_item:
		"Poción":
			if target and target.has_method("heal"):
				target.heal(20)
			elif target and target.has("hp"):
				var max_hp = target.max_hp if target.has("max_hp") else target.hp + 20
				target.hp = min(target.hp + 20, max_hp)
			applied = true

		"Éter":
			if target and target.has_method("restore_mp"):
				target.restore_mp(10)
			elif target and target.has("mp"):
				target.mp += 10
			applied = true

		"Antídoto":
			if target and target.has_method("cure_status"):
				target.cure_status()
			applied = true

		"Revivir":
			if target:
				if target.has_method("revive"):
					target.revive()
					applied = true
				else:
					if target.has("alive") and not target.alive:
						target.alive = true
						if target.has("max_hp"):
							target.hp = int(target.max_hp / 2)
						elif target.has("hp"):
							target.hp = 1
						applied = true
					else:
						applied = false
			else:
				applied = false

		_:
			applied = true

	if applied:
		remove_item(nombre_item, 1)
		emit_signal("item_used", nombre_item, target)
		return true

	return false
