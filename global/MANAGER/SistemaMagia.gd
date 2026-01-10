extends Node
class_name SistemaMagia

var hechizos = {
	"Fuego": {"costo": 5, "multiplicador": 2},
	"Hielo": {"costo": 4, "multiplicador": 1.5},
	"Rayo": {"costo": 6, "multiplicador": 3}
}

func lanzar_hechizo(nombre_hechizo: String, lanzador, objetivo):
	if not hechizos.has(nombre_hechizo):
		print("Hechizo desconocido: ", nombre_hechizo)
		return false

	var datos = hechizos[nombre_hechizo]
	if lanzador.mp < datos.costo:
		print(lanzador.nombre, " no tiene suficiente MP para lanzar ", nombre_hechizo)
		return false

	lanzador.mp -= datos.costo
	var daño = lanzador.attack * datos.multiplicador
	objetivo.take_damage(daño)

	print(lanzador.nombre, " lanza ", nombre_hechizo, " a ", objetivo.nombre, " causando ", daño, " de daño.")
	return true
