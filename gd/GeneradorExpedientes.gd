extends Node
class_name GeneradorExpedientes

#static func generar(trabajador: Trabajador) -> ExpedienteLaboral:
static func generar(trabajador : Trabajador) -> ExpedienteLaboral:
	print("GENERANDO EXPEDIENTE")
	var expediente = ExpedienteLaboral.new()

	expediente.id = trabajador.id
	expediente.trabajador_id = trabajador.id

	var contrato = DocumentoCompuesto.new()
	contrato.id = "CONTRATO"
	contrato.tipo = DatabaseTipoDocumento.DOCUMENTOS["CONTRATO"]
	contrato.paginas_requeridas = DatabaseTipoDocumento.ARCHIVOS_POR_DOCUMENTO["CONTRATO"].duplicate()
	contrato.metadata = {
		#IDENTIFICACION TRABAJADOR
		"nombre": trabajador.nombre,
		"rut_id": trabajador.rut,
		"direccion" : trabajador.direccion,
		#POSICION EN LA EMPRESA
		"cargo": trabajador.cargo,
		"nivel_operativo": trabajador.nivel_operativo,
		"fecha_ingreso": trabajador.fecha_ingreso,
		"area_trabajo": trabajador.area_trabajo,
		#ASIGNACION EMPRESA
		"nombre_empresa" : "Valvula",
		"rut_empresa" : "9999 - 9",
		"direccion_empresa" : "Peyehue, Quesington"
	}
	for pagina_id in contrato.paginas_requeridas:
		
		#CRECION DE PAGINAS
		var pagina = PaginaDocumento.new()
		pagina.id = "%s_%s_%s" % [pagina_id, contrato.id, trabajador.id ]
		pagina.documento_id = contrato.id
		#SE TOMA EL nombre:String TIPOPAGINA Y SE BUSCA EN database_tipo_documento.gd. 
		pagina.tipo = DatabaseTipoDocumento.DOCUMENTOS[pagina_id]
		#TRASPSO METADATA CONTRATO -> PAGINA
		pagina.metadata = contrato.metadata
		contrato.agregar_pagina(pagina)
	
	print("CREANDO INFRME IDENTIFICACION")
	
	var informe_identificacion = Informe.new()
	informe_identificacion.tipo = DatabaseTipoDocumento.INFORMES["IDENTIFICACION"]
	informe_identificacion.metadata = {
	"nombre": trabajador.nombre,
	"cargo": trabajador.cargo,
	"rut": trabajador.rut,
	"nivel_operativo" : trabajador.nivel_operativo,
	"fecha_ingreso" : trabajador.fecha_ingreso,
	"area_trabajo" : trabajador.area_trabajo
	#"fecha_nacimiento": trabajador.fecha_nacimiento
	}
	informe_identificacion.documentos_requeridos.append("CONTRATO")
	# FIN CONFIGURACION INFORME CONTINUIDAD

	# CONFIGURACION INFORME MEDICO
	print("CREANDO INFRME MEDICO")
	var informe_medico = Informe.new()
	informe_medico.tipo = DatabaseTipoDocumento.INFORMES["MEDICO"]
	informe_medico.metadata = {
		"nombre" : trabajador.nombre,
		"rut_id" : trabajador.rut
	}
	var contador_medico := 0
	for evento in trabajador.eventos.get("EVENTO_MEDICO", []):
		contador_medico += 1
		var doc = Documento.new()
		doc.id = "EVENTO_MEDICO_%s_%s" % [trabajador.id,contador_medico]
		doc.tipo = DatabaseTipoDocumento.DOCUMENTOS["EXAMEN_MEDICO"]
		doc.metadata = evento
		expediente.documentos.append(doc)
		informe_medico.documentos_requeridos.append(doc.id)
	#informe_medico.documentos_requeridos.append("EXAMEN_MEDICO")

	
	
	var informe_conductual = Informe.new()
	var historial_conductual := []
	
	informe_conductual.tipo = DatabaseTipoDocumento.INFORMES["CONDUCTUAL"]
	informe_conductual.metadata = {
		"nombre": trabajador.nombre,
		"rut_id": trabajador.rut
	}

	var contador_conductual := 0
	
	for evento in trabajador.eventos.get("EVENTO_CONDUCTUAL", []):
		contador_conductual += 1
		# AGREGAR AL HISTORIAL
		historial_conductual.append({
			"fecha": evento.get("fecha", ""),
			"motivo": evento.get("motivo", "")
			})
		# CREAR INCIDENTE
		var incidente = DocumentoCompuesto.new()
		incidente.id = "INFORME_INCIDENTE_%s_%s" % [
			trabajador.id,
			contador_conductual
		]
		incidente.paginas_requeridas = DatabaseTipoDocumento.ARCHIVOS_POR_DOCUMENTO["INFORME_INCIDENTE"].duplicate()
		incidente.metadata = {
			"nombre": trabajador.nombre,
			"rut_id": trabajador.rut,
			"direccion": trabajador.direccion,
	
			"cargo": trabajador.cargo,
			"nivel_operativo": trabajador.nivel_operativo,
			"fecha_ingreso": trabajador.fecha_ingreso,
			"area_trabajo": trabajador.area_trabajo,
	
			"nombre_empresa": "Valvula",
			"rut_empresa": "9999 - 9",
			"direccion_empresa": "Peyehue, Quesington",
	
			"tipo_evento": evento.get("tipo", ""),
			"motivo_evento": evento.get("motivo", ""),
			"resultado_evento": evento.get("resultado", ""),
			"fecha_evento": evento.get("fecha", ""),
			"gravedad_evento": evento.get("gravedad", 0)
		}
		for pagina_id in incidente.paginas_requeridas:
			var pagina = PaginaDocumento.new()
			pagina.id = "%s_%s_%s" % [
				pagina_id,
				incidente.id,
				trabajador.id
			]
			pagina.documento_id = incidente.id
			pagina.tipo = DatabaseTipoDocumento.DOCUMENTOS[pagina_id]
			pagina.metadata = incidente.metadata
			incidente.agregar_pagina(pagina)
		expediente.documentos.append(incidente)
		informe_conductual.documentos_requeridos.append(incidente.id)

	var contador_historial := 1
	
	for item in historial_conductual:
	
		informe_conductual.metadata[
			"historial_%s" % contador_historial
		] = "%s - %s" % [
			item.get("fecha", ""),
			item.get("motivo", "")
		]
	
		contador_historial += 1


	# CONFIGURACION INFORME CONTINUIDAD
	var informe_continuidad = Informe.new()
	informe_continuidad.tipo = DatabaseTipoDocumento.INFORMES["CONTINUIDAD"]
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
		expediente.documentos.append(doc)
		informe_continuidad.documentos_requeridos.append(doc.id)
		#informe_continuidad.documentos_requeridos.append("ASCENSO")

	# -------------------------
	# GUARDAR
	# -------------------------

	expediente.documentos.append(contrato)
	#expediente.documentos.append(examen_medico)
	#expediente.documentos.append(ascenso)

	expediente.informes.append(informe_identificacion)
	expediente.informes.append(informe_medico)
	expediente.informes.append(informe_conductual)
	expediente.informes.append(informe_continuidad)

	return expediente
