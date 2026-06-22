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

func agregar_trabajador(trabajador: Trabajador):
	if trabajador in trabajadores:
		return
		
	trabajadores.append(trabajador)
	trabajador.empresa = self
