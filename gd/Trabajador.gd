extends Resource
class_name Trabajador

@export var id : int
@export var nombre: String
@export var cargo: String
@export var documentos: Array = []
@export var fecha_ingreso: String
@export var activo: bool = true

static func nuevo(id: int, nombre: String, cargo: String) -> Trabajador:
	var t = Trabajador.new()
	t.id = id
	t.nombre = nombre
	t.cargo = cargo
	t.fecha_ingreso = Time.get_date_string_from_system()
	t.activo = true
	t.asignar_documentos(DatabaseTrabajadores.obtener_documentos_de_cargo(cargo))
	return t

func asignar_documentos(docs: Array):
	documentos = docs.duplicate()

func get_nombre() -> String:
	return nombre
