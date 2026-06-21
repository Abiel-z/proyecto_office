extends Node
class_name DocumentBuilder

static func construir_metadata_trabajador(trabajador: Trabajador) -> Dictionary:
	return {
		"nombre": trabajador.nombre,
		"rut_id": trabajador.rut,
		"direccion" : trabajador.direccion,
		#POSICION EN LA EMPRESA
		"cargo": trabajador.cargo,
		"nivel_operativo": trabajador.nivel_operativo,
		"fecha_ingreso": trabajador.fecha_ingreso,
		"area_trabajo": trabajador.area_trabajo,
		#ASIGNACION EMPRESA
		"nombre_empresa" : trabajador.empresa.nombre,
		"rut_empresa" : trabajador.empresa.rut,
		"direccion_empresa" : trabajador.empresa.direccion
	}

static func construir_paginas_compuestas(documento: DocumentoCompuesto, trabajador : Trabajador ):
	for pagina_id in documento.paginas_requeridas:
		var pagina = PaginaDocumento.new()
		pagina.id = "%s_%s_%s" % [pagina_id, documento.id, trabajador.id]
		pagina.documento_id = documento.id
		pagina.tipo = DatabaseTipoDocumento.DOCUMENTOS[pagina_id]
		pagina.metadata = documento.metadata
		documento.agregar_pagina(pagina)
		
static func construir_documento_evento(evento: Dictionary, trabajador: Trabajador, tipo_doc: String) -> Documento:
	var doc = Documento.new()
	doc.id = "%s_%s" % [tipo_doc, trabajador.id]
	doc.tipo = DatabaseTipoDocumento.DOCUMENTOS[tipo_doc]
	doc.metadata = evento
	return doc
