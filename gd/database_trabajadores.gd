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

func generar_bbcode_documento(doc: Documento) -> String:
	match doc.tipo:
		Documento.TipoDocumento.CONTRATO:
			return generar_contrato(doc)
		Documento.TipoDocumento.HORARIO:
			return generar_horario(doc)
		Documento.TipoDocumento.SALUD:
			return generar_salud(doc)
	return "[color=red]DOCUMENTO INVALIDO[/color]"

func generar_contrato(doc: Documento) -> String:
	var txt := ""
	txt += "[font_size=20]"
	txt += "[b][center] CONTRATO DE TRABAJO [/center][/b]\n\n"
	txt += "[font_size=12]"
	txt += "En la ciudad de [color=#6666aa]" + doc.cargo + "[/color], "
	txt += "con fecha de contratación [color=#888888]" + doc.fecha + "[/color], "
	txt += "entre la empresa y el/la trabajador/a "

	txt += "[color=#2a2a2a][b]" + doc.nombre + "[/b][/color], "
	txt += "se establece el siguiente acuerdo laboral.\n\n"

	txt += "[font_size=18][b]ANTECEDENTES[/b][/font_size]\n"
	txt += "El/la trabajador/a desempeñará funciones en calidad de "
	txt += "[color=#4444aa][b]" + doc.cargo + "[/b][/color] "
	txt += "bajo supervisión directa de la empresa contratante.\n\n"

	txt += "[font_size=18][b]CONDICIONES[/b][/font_size]\n"
	txt += "Sueldo base establecido en [color=#888888]$[dato clasificado][/color]. "
	txt += "Bonificaciones sujetas a evaluación interna.\n\n\n\n\n\n\n\n"

	txt += "[center] ________________                                    _________________ \n "
	txt += "[i][font_size=10]FIRMA EMPRESA                                      FIRMA TRABAJADOR"
	return txt

func generar_horario(doc : Documento) -> String:
	var txt := ""

	txt += "[center]"
	txt += "[font_size=28]"
	txt += "[b]HORARIO LABORAL[/b]"
	txt += "[/font_size]"
	txt += "[/center]\n\n"

	txt += "[b]TRABAJADOR:[/b] "
	txt += doc.nombre + "\n"

	txt += "[b]CARGO:[/b] "
	txt += doc.cargo + "\n"

	txt += "[b]FECHA:[/b] "
	txt += doc.fecha + "\n\n"

	txt += doc.contenido

	txt += "\n\n[right][i]1/3[/i][/right]"

	return txt

func generar_salud(doc : Documento) -> String:
	var txt := ""

	txt += "[center]"
	txt += "[font_size=28]"
	txt += "[b]CERTIFICADO SALUD[/b]"
	txt += "[/font_size]"
	txt += "[/center]\n\n"

	txt += "[b]TRABAJADOR:[/b] "
	txt += doc.nombre + "\n"

	txt += "[b]CARGO:[/b] "
	txt += doc.cargo + "\n"

	txt += "[b]FECHA:[/b] "
	txt += doc.fecha + "\n\n"

	txt += doc.contenido

	txt += "\n\n[right][i]1/3[/i][/right]"

	return txt

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
	
	return doc

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
