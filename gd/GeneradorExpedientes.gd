extends Node
class_name GeneradorExpedientes

static func generar(trabajador : Trabajador) -> ExpedienteLaboral:
	
	var expediente = ExpedienteLaboral.new()
	expediente.id = trabajador.id
	expediente.trabajador_id = trabajador.id
	
	# CONSTRUCCION INFORME IDENTIFICACION 
	var informe_identificacion = Informe.new()
	var doc_requeridos : Array = DatabaseTipoDocumento.DOCUMENTOS_INFORMES["IDENTIFICACION"]
	
	informe_identificacion.tipo = DatabaseTipoDocumento.INFORMES["IDENTIFICACION"]
	informe_identificacion.metadata = DocumentBuilder.construir_metadata_trabajador(trabajador)
	informe_identificacion.documentos_requeridos.append_array(doc_requeridos)
	
	for documento_id in informe_identificacion.documentos_requeridos:
		var doc = DocumentoCompuesto.new()
		doc.id = documento_id
		doc.paginas_requeridas = DatabaseTipoDocumento.ARCHIVOS_POR_DOCUMENTO[doc.id].duplicate()
		doc.metadata = DocumentBuilder.construir_metadata_trabajador(trabajador)
		DocumentBuilder.construir_paginas_compuestas(doc,trabajador)
		expediente.documentos.append(doc)
	# FIN CONFIGURACION INFORME IDENTIFICACION



	# CONFIGURACION INFORME MEDICO
	var informe_medico = Informe.new()
	var historial_medico := []
	var contador_medico  := 0
	informe_medico.tipo = DatabaseTipoDocumento.INFORMES["MEDICO"]
	informe_medico.subject = trabajador
	informe_medico.metadata = {
		"nombre" : trabajador.nombre,
		"rut_id" : trabajador.rut
	}

	for evento in trabajador.eventos.get("EVENTO_MEDICO", []):
		contador_medico += 1
		var nuevo_evento =  DocumentBuilder.construir_nombre_historial(evento)
		historial_medico.append(nuevo_evento)
		# CREAR EVENTO
		var documento_evento = DocumentoCompuesto.new()
		documento_evento.id = "%s_%s_%s" % [ evento.categoria, trabajador.id, contador_medico ]
		documento_evento.categoria = evento.categoria
		documento_evento.paginas_requeridas = DatabaseTipoDocumento.DOCUMENTOS[documento_evento.categoria].paginas.duplicate()
		documento_evento.metadata = DocumentBuilder.construir_metadata_evento(trabajador,evento)
		documento_evento.subject = trabajador
		
		for pagina_id in documento_evento.paginas_requeridas:
			var pagina = PaginaDocumento.new()
			pagina.id = "%s_%s_%s" % [
				pagina_id,
				documento_evento.id,
				trabajador.id
			]
			pagina.documento_id = documento_evento.id
			pagina.tipo = DatabaseTipoDocumento.PAGINAS[pagina_id]
			pagina.metadata = documento_evento.metadata
			documento_evento.agregar_pagina(pagina)
		expediente.documentos.append(documento_evento)
		informe_medico.documentos_requeridos.append(documento_evento.id)
	# FIN CONFIGURACION INFORME MEDICO



	# CONFIGURACION INFORME CONDUCTUAL
	var informe_conductual = Informe.new()
	var historial_conductual := []
	var contador_conductual := 0
	informe_conductual.tipo = DatabaseTipoDocumento.INFORMES["CONDUCTUAL"]
	informe_conductual.metadata = DocumentBuilder.construir_metadata_trabajador(trabajador)
	informe_conductual.subject = trabajador
	
	for evento in trabajador.eventos.get("EVENTO_CONDUCTUAL", []):
		contador_conductual += 1
		var nuevo_evento =  DocumentBuilder.construir_nombre_historial(evento)
		historial_conductual.append(nuevo_evento)
		# CREAR INCIDENTE
		var documento_evento = DocumentoCompuesto.new()
		documento_evento.id = "INFORME_INCIDENTE_%s_%s" % [ trabajador.id, contador_conductual ]
		documento_evento.paginas_requeridas = DatabaseTipoDocumento.ARCHIVOS_POR_DOCUMENTO["INCIDENTE"].duplicate()
		documento_evento.metadata = DocumentBuilder.construir_metadata_evento(trabajador,evento)
		documento_evento.subject = trabajador
		
		for pagina_id in documento_evento.paginas_requeridas:
			var pagina = PaginaDocumento.new()
			pagina.id = "%s_%s_%s" % [
				pagina_id,
				documento_evento.id,
				trabajador.id
			]
			pagina.documento_id = documento_evento.id
			pagina.tipo = DatabaseTipoDocumento.PAGINAS[pagina_id]
			pagina.metadata = documento_evento.metadata
			documento_evento.agregar_pagina(pagina)
		expediente.documentos.append(documento_evento)
		informe_conductual.documentos_requeridos.append(documento_evento.id)
		
	var contador_historial := 1
	for item in historial_conductual:
		informe_conductual.metadata[
			"historial_%s" % contador_historial
		] = "%s - %s" % [
			item.get("fecha", ""),
			item.get("motivo", "")
		]
		contador_historial += 1
	# FIN CONFIGURACION INFORME CONDUCTUAL











	# CONFIGURACION INFORME CONTINUIDAD
	var informe_continuidad = Informe.new()
	informe_continuidad.tipo = DatabaseTipoDocumento.INFORMES["CONTINUIDAD"]
	informe_continuidad.subject = trabajador
	informe_continuidad.metadata = {
		"nombre" : trabajador.nombre,
		"rut_id" : trabajador.rut
	}
	var contador_continuidad := 0

	for evento in trabajador.eventos.get("EVENTO_CONTINUIDAD", []):
		print(" EVENTO CONTINUIDAD ENCONTRADO ")
		contador_continuidad += 1
		var doc = Documento.new()
		doc.id = "EVENTO_CONTINUIDAD_%s_%s" % [trabajador.id,contador_continuidad]
		
		
		#ESTO DEBE CAMBIAR POR UN < match tipo: >
		doc.tipo = DatabaseTipoDocumento.DOCUMENTOS["ASCENSO"]
		
		doc.metadata = evento
		doc.subject = trabajador
		expediente.documentos.append(doc)
		informe_continuidad.documentos_requeridos.append(doc.id)
		#informe_continuidad.documentos_requeridos.append("ASCENSO")

	# FIN CONFIGURACION INFORME CONTINUIDAD


	# -------------------------
	# GUARDAR
	# -------------------------

	#expediente.documentos.append(contrato)
	#expediente.documentos.append(examen_medico)
	#expediente.documentos.append(ascenso)

	expediente.informes.append(informe_identificacion)
	expediente.informes.append(informe_medico)
	expediente.informes.append(informe_conductual)
	expediente.informes.append(informe_continuidad)

	return expediente
