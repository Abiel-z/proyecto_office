extends Resource
class_name ExpedienteLaboral

@export var id : int
@export var trabajador_id : int
@export var documentos : Array[Documento] = []
@export var informes : Array[Informe] = []


func get_documento(id_documento:String):

	for documento in documentos:
		if documento.id == id_documento:
			return documento

	return null
