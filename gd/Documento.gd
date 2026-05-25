extends Resource
class_name Documento

enum TipoDocumento {
	REVISION,
	CONTRATO,
	HORARIO,
	SALUD
}

@export var tipo = TipoDocumento 
@export var nombre : String
@export var cargo : String
@export var fecha : String
@export var id : String 
@export var titulo : String
@export var contenido : String
@export var cuerpo : String

@export var owner_id : int
@export var subject_id : int
@export var contexto : String

@export var estado : String = "activo"
@export var metadata := {}
