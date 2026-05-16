extends Node
class_name ControllerSpawners

var CajaScene = preload("res://tscn/caja.tscn")
var CarpetaScene = preload("res://tscn/carpeta.tscn")
var HojaScene = preload("res://tscn/hoja_en_blanco.tscn")

var documentos_totales = {}
var documentos_creados = {}
var hojas_creadas = {}

func _ready():
	await  get_tree().process_frame
	generar_carpetas_iniciales()

func generar_carpetas_iniciales():
	var scene = get_tree().current_scene
	var spawn_container = scene.get_node("SpawnPoints")
	var trabajadores = DatabaseTrabajadores.get_trabajadores()

	for i in range(trabajadores.size()):
		var trabajador = trabajadores[i]

		# CREAR CARPETA
		var carpeta = CarpetaScene.instantiate()
		var spawn = spawn_container.get_child(0)
		scene.add_child(carpeta)

		# POSICION BASE
		carpeta.global_transform = spawn.global_transform
		# OFFSET
		carpeta.global_position += Vector3( i * 0.4, 0 , 0)
		
		# GENERAR DOCUMENTOS
		var documentos = DatabaseTrabajadores.generar_documentos_para_trabajador(trabajador)
		for documento in documentos:
			var hoja = crear_hoja(documento)
			carpeta.agregar_hoja(hoja)
		carpeta.abrir_carpeta()
		carpeta.cerrar_carpeta()

# 🧠 helper base
func _add_to_scene(node: Node, parent: Node = null):
	if parent == null:
		parent = get_tree().current_scene
	parent.add_child(node)
	return node

func crear_hoja(documento_data):
	var hoja = HojaScene.instantiate()
	hoja.set_documento(documento_data)
	return hoja

func crear_carpeta():
	var carpeta = CarpetaScene.instantiate()
	return carpeta

func problar_carpeta_con_documentos( carpeta, documentos : Array ):
	for documento in documentos:
		var hoja = crear_hoja(documento)
		carpeta.agregar_hoja(hoja)

func obtener_hoja(documento):
	var id = documento.id
	if hojas_creadas.has(id):
		var hoja_existente = hojas_creadas[id]
		if is_instance_valid(hoja_existente):
			return hoja_existente
	var hoja = crear_hoja(documento)
	hojas_creadas[id] = hoja
	return hoja

func obtener_documento( documento_id : String, datos : Dictionary ):
	if documentos_totales.has(documento_id):
		return documentos_totales[documento_id]
	var doc = Documento.new()
	doc.id = documento_id
	doc.titulo = datos.titulo
	doc.contenido = datos.contenido
	documentos_totales[documento_id] = doc
	return doc

func crear_carpeta_trabajador(trabajador):
	var carpeta = crear_carpeta()
	var documentos_requeridos = (
		DatabaseTrabajadores
		.obtener_documentos_requeridos(
			trabajador
		)
	)
	for datos_doc in documentos_requeridos:
		var documento = obtener_documento(
			datos_doc.id,
			datos_doc
		)
		var hoja = obtener_hoja(documento)
		carpeta.agregar_hoja(hoja)
	return carpeta
