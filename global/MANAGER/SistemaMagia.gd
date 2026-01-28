extends Node
class_name SistemaMagia

# Lista simple de hechizos y sus datos
var hechizos = {
	"Fuego": {"costo": 5, "multiplicador": 2},
	"Hielo": {"costo": 4, "multiplicador": 1.5},
	"Rayo": {"costo": 6, "multiplicador": 3}
}

func lanzar_hechizo(nombre_hechizo: String, lanzador, objetivo):
	if not hechizos.has(nombre_hechizo):
		print("No conozco ese hechizo: ", nombre_hechizo)
		return false

	var datos = hechizos[nombre_hechizo]
	if lanzador.mp < datos.costo:
		print(lanzador.nombre, " no tiene MP pa' eso, se acabó.")
		return false

	lanzador.mp -= datos.costo
	var daño = lanzador.attack * datos.multiplicador
	# uso la función traducida para aplicar daño
	if objetivo and objetivo.has_method("recibir_daño"):
		objetivo.recibir_daño(daño)
	elif objetivo and objetivo.has("hp"):
		objetivo.hp -= int(round(daño))

	print(lanzador.nombre, " le mete ", nombre_hechizo, " a ", objetivo.nombre, " y le hace ", daño, " de daño.")
	return true
