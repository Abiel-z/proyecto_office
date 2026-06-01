extends Node

const OBJETOS = {
	"archivador": preload("res://tscn/archivador.tscn"),
	"lampara": preload("res://tscn/archivador.tscn"),
	"mesa": preload("res://tscn/escritorio.tscn"),
	"carpeta": preload("res://tscn/carpeta.tscn"),
	"timbre": preload("res://tscn/timbre.tscn")
}


func procesar_compra(id_objeto: String, cantidad : int):
	#if not hay_dinero:
		#return false
	#descontar_dinero()
	spawnear_objeto(id_objeto, cantidad)

#func spawnear_objeto(id_objeto : String, cantidad):
	#if not OBJETOS.has(id_objeto):
		#push_error("Objeto no encontrado: " + id_objeto)
		#return
	#var scene = get_tree().current_scene
	#var spawn_container = scene.get_node("controller_spawner")
	#for i in range(cantidad):
		#var obj = OBJETOS[id_objeto].instantiate()
		#var spawn = spawn_container.get_child(0)
		#scene.add_child(obj)
		#obj.global_position = spawn.global_position
		#
func spawnear_objeto(id_objeto : String, cantidad : int):

	if not OBJETOS.has(id_objeto):
		push_error("Objeto no encontrado: " + id_objeto)
		return

	var scene = get_tree().current_scene
	var spawn_container = scene.get_node("controller_spawner")
	var spawn = spawn_container.get_child(0)

	for i in range(cantidad):

		var obj = OBJETOS[id_objeto].instantiate()

		scene.add_child(obj)

		obj.global_position = spawn.global_position

		print(
			"Spawn:",
			obj.name,
			" -> ",
			obj.global_position
		)
