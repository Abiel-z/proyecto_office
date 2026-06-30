extends Node

const TIPOS_EVENTO = {

	"EXAMEN_RUTINARIO": {
		"grupo": "EVENTO_MEDICO",
		"titulo" : "Examen rutinario",
		"documentos": [
			"EXAMEN_MEDICO",
			"INFORME_MEDICO"
		]
	},

	"ACCIDENTE_GRAVE": {
		"grupo": "EVENTO_MEDICO",
		"titulo" : "Accidente grave",
		"documentos": [
			"EXAMEN_MEDICO",
			"INFORME_INCIDENTE",
			"INFORME_MEDICO",
			"ALTA_MEDICA"
		]
	},

	"ACCIDENTE_LEVE": {
		"grupo": "EVENTO_MEDICO",
		"titulo" : "Accidente leve",
		"documentos": [
			"EXAMEN_MEDICO",
			"INFORME_INCIDENTE",
			"ALTA_MEDICA"
		]
	},

	"ACCIDENTE_SIN_RELEVANCIA": {
		"grupo": "EVENTO_MEDICO",
		"titulo" : "Accidente sin relevancia",
		"documentos": [
			"INFORME_INCIDENTE"
		]
	}
}
