extends Node

var monedaScene = preload("res://tscn/moneda_10.tscn")
# Called when the node enters the scene tree for the first time.

func spawnear_monedas( valor_total: int ):
	
	var scene = get_tree().current_scene
	var spawn_container = scene.get_node("controller_spawner")
	var spawn = spawn_container.get_child(0)
	var cantidad_monedas = int(valor_total / 10)

	for i in cantidad_monedas:
		var moneda = monedaScene.instantiate()
		scene.add_child(moneda)
		moneda.global_position = spawn.global_position
	# impulso aleatorio
		var impulso = Vector3(
			randf_range(-1.5, 1.5),
			randf_range(-0.5, -2.0),
			randf_range(-1.5, 1.5)
		)
		moneda.apply_impulse(impulso * 3.0)
