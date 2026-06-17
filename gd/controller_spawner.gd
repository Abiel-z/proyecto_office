extends Node

var CajaScene = preload("res://tscn/caja.tscn")
var CarpetaScene = preload("res://tscn/carpeta.tscn")
var HojaScene = preload("res://tscn/hoja_en_blanco.tscn")

func _ready():
	await  get_tree().process_frame
	generar_expedientes()
	generar_carpetas_iniciales()

func generar_expedientes():
	var trabajadores = DatabaseTrabajadores.get_trabajadores()

	for trabajador in trabajadores:
		var expediente = GeneradorExpedientes.generar(trabajador)
		DatabaseExpedientes.agregar_expediente(expediente)

func generar_carpetas_iniciales():
	var scene = get_tree().current_scene
	var spawn_container = scene.get_node("controller_spawner")
	var expedientes = DatabaseExpedientes.obtener_todos()
	
	
	for expediente in expedientes:
		var carpeta = CarpetaScene.instantiate()
		var spawn = spawn_container.get_child(0)
		scene.add_child(carpeta)
		carpeta.global_transform = spawn.global_transform
		
		for informe in expediente.informes:
			var hoja_informe = crear_hoja(informe)
			carpeta.agregar_hoja(hoja_informe)
			for documento_id in informe.documentos_requeridos:
				var documento = expediente.get_documento(documento_id)
				if documento == null:
					return
				if documento is DocumentoCompuesto:
					for pagina in documento.paginas:
						var hoja = crear_hoja(pagina)
						carpeta.agregar_hoja(hoja)
						
				else:
					var hoja = crear_hoja(documento)
					carpeta.agregar_hoja(hoja)

		carpeta.abrir_carpeta()
		carpeta.cerrar_carpeta()

		var impulso = Vector3(
			randf_range(-1.5, 1.5),
			randf_range(-0.5, -2.0),
			randf_range(-1.5, 1.5)
		)

		carpeta.apply_impulse(impulso * 3.0)

# helper base
func _add_to_scene(node: Node, parent: Node = null):
	if parent == null:
		parent = get_tree().current_scene
	parent.add_child(node)
	return node

func crear_hoja(recurso):
	var hoja = HojaScene.instantiate()
	hoja.set_documento(recurso)
	return hoja

func crear_carpeta():
	var carpeta = CarpetaScene.instantiate()
	return carpeta

func problar_carpeta_con_documentos( carpeta, documentos : Array ):
	for documento in documentos:
		var hoja = crear_hoja(documento)
		carpeta.agregar_hoja(hoja)
