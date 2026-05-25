extends Node

var trabajadores : Array[Trabajador] = []

var documentos_por_cargo = {
	"ASEO" : [
		Documento.TipoDocumento.CONTRATO,
		#Documento.TipoDocumento.CERTIFICADO_QUIMICOS,
		Documento.TipoDocumento.SALUD,
		Documento.TipoDocumento.HORARIO
		],
	"ADMINISTRATIVO" : [
		Documento.TipoDocumento.CONTRATO,
		#Documento.TipoDocumento.CONFIDENCIALIDAD,
		#Documento.TipoDocumento.ACCESO_SISTEMAS,
		#Documento.TipoDocumento.EVALUACION,
		],
	"CONTABLE" : [
		Documento.TipoDocumento.CONTRATO,
		#Documento.TipoDocumento.TITULO,
		#Documento.TipoDocumento.REGISTRO_FISCAL,
		#Documento.TipoDocumento.DECLARACION_BIENES,
		#Documento.TipoDocumento.SEGURO_ERROR
		],
	"ABOGADO" : [
		Documento.TipoDocumento.CONTRATO,
		#Documento.TipoDocumento.TITULO,
		#Documento.TipoDocumento.ANTECEDENTES,
		#Documento.TipoDocumento.AUTORIZACION_REPRESENTACION,
		],
	"LOGISTICA" : [
		Documento.TipoDocumento.CONTRATO,
		#Documento.TipoDocumento.CARNET_CARGAS,
		#Documento.TipoDocumento.LICENCIA_MONTACARGAS,
		#Documento.TipoDocumento.INVENTARIO,
		],
	"TECNICO" : [
		Documento.TipoDocumento.CONTRATO,
		#Documento.TipoDocumento.TITULO,
		#Documento.TipoDocumento.NO_COMPETENCIA,
		#Documento.TipoDocumento.BITACORA
		],
	"CEO": [
		Documento.TipoDocumento.CONTRATO,
		#Documento.TipoDocumento.ACTA_CONSTITUCION,
		#Documento.TipoDocumento.PODERES,
		#Documento.TipoDocumento.DECLARACION_PATRIMONIO,
		#Documento.TipoDocumento.ACCIONES,
		]
	}

# --- FUNCIONES DE EJECUCION ---
func _ready():
	cargar_trabajadores_iniciales()
# --- FUNCIONES DE EJECUCION ---

func cargar_trabajadores_iniciales():
	trabajadores = [
		Trabajador.nuevo(1, "Ana Ramírez", "ASEO"),
		Trabajador.nuevo(2, "Carlos Soto", "CONTABLE"),
		Trabajador.nuevo(3, "Lucía Fernández", "ABOGADO"),
	]

func generar_documento(tipo: Documento.TipoDocumento, trabajador: Trabajador) -> Documento:
	var doc = Documento.new()
	doc.tipo = tipo
	doc.owner_id = 1
	doc.subject_id = trabajador.id
	doc.contexto = "RRHH"
	doc.estado = "activo"
	
	doc.nombre = trabajador.nombre
	doc.cargo = trabajador.cargo
	doc.fecha = Time.get_date_string_from_system()
	doc.cuerpo = RenderDocumentos.generar_bbcode_documento(doc)
	
	return doc

func generar_documentos_para_trabajador(trabajador: Trabajador) -> Array[Documento]:
	var lista : Array[Documento] = []
	var tipos = documentos_por_cargo.get(trabajador.cargo, [])
	
	for tipo in tipos:
		var doc = generar_documento(tipo, trabajador)
		doc.owner_id = 1
		doc.subject_id = trabajador.id
		doc.contexto = "RRHH"
		lista.append(doc)
	return lista

func agregar_trabajador( id:int , nombre: String, cargo: String) -> Trabajador:
	if not documentos_por_cargo.has(cargo):
		push_error("Cargo no reconocido: ", cargo)
		return null
	var docs = documentos_por_cargo[cargo].duplicate()
	var nuevo = Trabajador.nuevo(id, nombre, cargo)
	trabajadores.append(nuevo)
	return nuevo

func get_trabajador(id : int) -> Trabajador:
	if id >= 0 and id < trabajadores.size():
		return trabajadores[id]
	return null
	
	return

func get_trabajadores() -> Array[Trabajador]:
	return trabajadores

func obtener_documentos_de_cargo(cargo: String) -> Array:
	return documentos_por_cargo.get(cargo, [])

