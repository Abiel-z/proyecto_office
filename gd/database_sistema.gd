extends Node

const TIPO_DOCUMENTO = {
	"REVISION": preload("res://tres/Tipo_Documento/revision.tres")
}

func crear_revision(
	resultado: Dictionary,
	hojas: Array
) -> Documento:
	
	# VALIDACION
	if hojas.is_empty():
		push_error("No se puede crear revision sin hojas")
		return null

	# DOCUMENTO BASE
	var doc_base : Documento = hojas[0].documento

	# CREAR DOCUMENTO
	var doc = Documento.new()

	# -----------------------------
	# DATOS BASE
	# -----------------------------
	doc.tipo = TIPO_DOCUMENTO.REVISION
	print(doc.tipo)
	doc.nombre = doc_base.nombre
	doc.cargo = doc_base.cargo

	doc.owner_id = doc_base.owner_id
	doc.subject_id = doc_base.subject_id

	doc.contexto = "SISTEMA"

	doc.estado = "activo"

	doc.fecha = (
		Time.get_date_string_from_system()
	)

	doc.titulo = "Resultado de Revision"

	# -----------------------------
	# METADATA
	# -----------------------------
	print("RESULTADO RECIBIDO:")
	print(resultado)
	print(resultado.keys())
	
	doc.metadata = resultado
	
	print("METADATA DOCUMENTO:")
	print(doc.metadata)
	# -----------------------------
	# GENERAR CUERPO VISUAL
	# -----------------------------
	doc.cuerpo = (
		RenderDocumentos
		.generar_bbcode_documento(doc)
	)

	return doc

func generar_documento( tipo: TipoDocumento ) -> Documento:

	var doc = Documento.new()

	doc.tipo = tipo

	doc.owner_id = -1

	doc.contexto = "SISTEMA"

	doc.estado = "activo"

	doc.fecha = (
		Time.get_date_string_from_system()
	)

	return doc
