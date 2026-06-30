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

static func construir_nombre_historial(evento: Dictionary) -> Dictionary:
	return {
		"fecha": evento.get("fecha", ""),
		"motivo": evento.get("motivo", "")
}

static func construir_metadata_evento(trabajador: Trabajador, evento : Dictionary) -> Dictionary:
	return {
			"nombre": trabajador.nombre,
			"rut_id": trabajador.rut,
			"direccion": trabajador.direccion,
			"cargo": trabajador.cargo,
			"nivel_operativo": trabajador.nivel_operativo,
			"fecha_ingreso": trabajador.fecha_ingreso,
			"area_trabajo": trabajador.area_trabajo,
			"nombre_empresa": trabajador.empresa.nombre,
			"rut_empresa": "9999 - 9",
			"direccion_empresa": "Peyehue, Quesington",
			"tipo_evento": evento.get("tipo", ""),
			"motivo_evento": evento.get("motivo", ""),
			"resultado_evento": evento.get("resultado", ""),
			"fecha_evento": evento.get("fecha", ""),
			"gravedad_evento": evento.get("gravedad", 0)
		}
	


static func construir_paginas_compuestas(documento: DocumentoCompuesto, trabajador : Trabajador ):
	for pagina_id in documento.paginas_requeridas:
		var pagina = PaginaDocumento.new()
		pagina.id = "%s_%s_%s" % [pagina_id, documento.id, trabajador.id]
		pagina.documento_id = documento.id
		pagina.subject_id = trabajador.id
		pagina.subject = trabajador
		pagina.tipo = DatabaseTipoDocumento.PAGINAS[pagina_id]
		pagina.metadata = documento.metadata
		documento.agregar_pagina(pagina)
		
static func construir_documento_evento(evento: Dictionary, trabajador: Trabajador, tipo_doc: String) -> Documento:
	var doc = Documento.new()
	doc.id = "%s_%s" % [tipo_doc, trabajador.id]
	doc.tipo = DatabaseTipoDocumento.DOCUMENTOS[tipo_doc]
	doc.subject = trabajador
	doc.subject.id = trabajador.id
	doc.metadata = evento
	return doc
