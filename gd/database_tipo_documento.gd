extends Node

const INFORMES = {
	"IDENTIFICACION": preload("res://tres/Tipo_Documento/Informes/InformeIdentificacion.tres"),
	"MEDICO": preload("res://tres/Tipo_Documento/Informes/InformeMedico.tres"),
	"CONDUCTUAL": preload("res://tres/Tipo_Documento/Informes/InformeConductual.tres"),
	"CONTINUIDAD": preload("res://tres/Tipo_Documento/Informes/InformeContinuidad.tres"),
	}

const DOCUMENTOS = {
	"EXAMEN_MEDICO": {
		"informe": "MEDICO",
		"paginas": [
			"PORTADA_EXAMEN",
			"RESULTADOS_EXAMEN",
			"RADIOGRAFIA",
			"ALTA_MEDICA"
		]
	},
	"CONTRATO": {
		"informe": "IDENTIFICACION",
		"paginas": [
			"PORTADA_CONTRATO",
			"HOJA_ANTECEDENTES",
			"ANEXO_CONFIDENCIALIDAD",
			"HOJA_FIRMAS"
		]
	},
	"ASCENSO": {
		"informe": "CONTINUIDAD",
		"paginas": [
			"PORTADA_ASCENSO",
			"HOJA_ANTECEDENTES",
			"HOJA_JUSTIFICACIONES",
			"HOJA_FIRMAS"
		]
	},
	"AMONESTACION": {
		"informe": "CONDUCTUAL",
		"paginas": [
			"PORTADA_AMONESTACION",
			"HOJA_EVIDENCIAS",
			"HOJA_FIRMAS"
		]
	}
}

const PAGINAS = {

	"PORTADA_CONTRATO" : preload("res://tres/Tipo_Documento/TipoPagina/portada_contrato.tres"),
	"HOJA_ANTECEDENTES" : preload("res://tres/Tipo_Documento/TipoPagina/hoja_antecedentes.tres"),
	"ANEXO_CONFIDENCIALIDAD" : preload("res://tres/Tipo_Documento/TipoPagina/anexo_conf.tres"),
	"HOJA_FIRMAS" : preload("res://tres/Tipo_Documento/TipoPagina/hoja_firmas.tres"),
	"PORTADA_INFORME_INCIDENTE" : preload("res://tres/Tipo_Documento/TipoPagina/portada_informe_incidente.tres"),
	"ANTECEDENTES" : preload("res://tres/Tipo_Documento/TipoPagina/hoja_antecedentes.tres")
}

const DOCUMENTOS_INFORMES := {
		"IDENTIFICACION" : ["CONTRATO"]
}

const ARCHIVOS_POR_DOCUMENTO = {
	
	# ---- DOCUMENTOS IDENTIFICACION ----
	"CONTRATO": [
		"PORTADA_CONTRATO",
		"ANTECEDENTES",
		"ANEXO_CONFIDENCIALIDAD",
		"HOJA_FIRMAS"
	],
	
	# --- DOCUMENTOS CONTINUIDAD ----
	"DESPIDO" : [
		"PORTADA_DESPIDO",
		"HOJA_JUSTIFICACIONES",
		"HOJA_FIRMAS"
	],
	"ASCENSO" : [
		"PORTADA_ASCENSO",
		"HOJA_JUSTIFICACIONES",
		"HOJA_FIRMAS"
	],
	"CAPACITACION" : [
		"PORTADA_CAPACITACION",
		"FINAL_CAPACITACION",
		"HOJA_FIRMAS"
	],
	
	# --- DOCUMENTOS MEDICOS ----

	
	# --- DOCUMENTOS CONDUCTUALES --- 
	"INCIDENTE" : [
		"PORTADA_INFORME_INCIDENTE",
		"HOJA_FIRMAS"
	],
	
	"RECONOCIMIENTO" : [
		"PORTADA_RECONOCIMIENTO",
		"HOJA_EVIDENCIAS",
		"HOJA_FIRMAS"
	],
	
	"AMONESTACION" : [
		"PORTADA_AMONESTACION",
		"HOJA_EVIDENCIAS",
		"HOJA_FIRMAS"
	]
}
