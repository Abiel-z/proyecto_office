extends Node

const INFORMES = {
	"IDENTIFICACION": preload("res://tres/Tipo_Documento/InformeIdentificacion.tres"),
	"MEDICO": preload("res://tres/Tipo_Documento/InformeMedico.tres"),
	"CONDUCTUAL": preload("res://tres/Tipo_Documento/InformeConductual.tres"),
	"CONTINUIDAD": preload("res://tres/Tipo_Documento/InformeContinuidad.tres"),
	}
	
const DOCUMENTOS = {
	"CONTRATO": preload("res://tres/Tipo_Documento/contrato.tres"),
	"SALUD": preload("res://tres/Tipo_Documento/salud.tres"),
	"HORARIO": preload("res://tres/Tipo_Documento/horario.tres"),
	"REVISION": preload("res://tres/Tipo_Documento/revision.tres"),
	"EXAMEN_MEDICO": preload("res://tres/Tipo_Documento/examen_medico.tres"),
	"AMONESTACION" : preload("res://tres/Tipo_Documento/amonestacion.tres"),
	"ASCENSO" : preload("res://tres/Tipo_Documento/ascenso.tres"),
	
	"PORTADA_CONTRATO" : preload("res://tres/Tipo_Documento/TipoPagina/portada_contrato.tres"),
	"ANEXO_CONFIDENCIALIDAD" : preload("res://tres/Tipo_Documento/TipoPagina/anexo_conf.tres"),
	"HOJA_FIRMAS" : preload("res://tres/Tipo_Documento/TipoPagina/hoja_firmas.tres"),
	"PORTADA_INFORME_INCIDENTE" : preload("res://tres/Tipo_Documento/TipoPagina/portada_informe_incidente.tres")
}

const DOCUMENTOS_INFORMES := {
		"IDENTIFICACION" : ["CONTRATO"]
}

const ARCHIVOS_POR_DOCUMENTO = {
	"CONTRATO": [
		"PORTADA_CONTRATO",
		"ANEXO_CONFIDENCIALIDAD",
		"HOJA_FIRMAS"
	]
	,
	"EXAMEN_MEDICO": [
		"PORTADA_EXAMEN",
		"RESULTADOS_EXAMEN",
		"RADIOGRAFIA",
		"ALTA_MEDICA"
	]
	,
	"INFORME_INCIDENTE" : [
		"PORTADA_INFORME_INCIDENTE",
		"HOJA_FIRMAS"
	]
}
