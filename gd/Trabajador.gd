extends Resource
class_name Trabajador

@export var id : int
@export var nombre: String
@export var empresa : Empresa
@export var cargo: String
@export var documentos: Array = []
@export var activo: bool = true

var eventos = {
	"EVENTO_CONDUCTUAL": [],
	"EVENTO_MEDICO": [],
	"EVENTO_CONTINUIDAD": []
}

# identificación
var rut : String
var fecha_nacimiento : String
var nivel_operativo : String
var fecha_ingreso: String
var area_trabajo : String
var direccion : String
var nacionalidad : String

# médico
var grupo_sanguineo : String
var apto_medicamente : bool

# conductual
var amonestaciones : int

# continuidad
var antiguedad : int
var evaluacion : int




static func nuevo(
	id: int, nombre: String, cargo: String, empresa: Empresa, rut : String,
	fecha_ingreso : String, area_trabajo : String, nivel_operativo: String,
	direccion : String
	) -> Trabajador:
	
	var t = Trabajador.new()
	t.id = id
	t.rut = rut
	t.nombre = nombre
	t.empresa = empresa
	t.fecha_ingreso = fecha_ingreso
	t.area_trabajo = area_trabajo
	t.nivel_operativo = nivel_operativo
	t.direccion = direccion
	t.cargo = cargo
	t.fecha_ingreso = Time.get_date_string_from_system()
	t.activo = true
	#t.asignar_documentos(DatabaseTrabajadores.obtener_documentos_de_cargo(cargo))
	return t

func asignar_documentos(docs: Array):
	documentos = docs.duplicate()

func get_nombre() -> String:
	return nombre
