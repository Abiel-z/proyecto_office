extends Resource
class_name  Empresa

@export var id : String
@export var nombre : String
@export var rut : String
@export var direccion : String
@export var logo_empresa:  Texture2D
@export var timbre_empresa:  Texture2D
@export var firma : Texture2D

var trabajadores : Array[Trabajador] = []

var organigrama := {

	"DIRECCION": {
		"CEO": null
	},

	"GERENCIA": {
		"GENERAL": null,
		"MEDICA": null,
		"OPERACIONES": null,
		"PERSONAS": null
	},

	"OPERACIONES": {
		"SUPERVISORES": [],
		"TECNICOS": [],
		"OPERARIOS": []
	},

	"SEGURIDAD": {
		"GUARDIAS": []
	}
}


func agregar_trabajador(trabajador: Trabajador):
	if trabajador in trabajadores:
		return
		
	trabajadores.append(trabajador)
	trabajador.empresa = self
