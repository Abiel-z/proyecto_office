extends Node

var expedientes : Dictionary = {}



func agregar_expediente(expediente : ExpedienteLaboral):
	expedientes[expediente.id] = expediente

func obtener_expediente(expediente_id : int) -> ExpedienteLaboral:
	return expedientes.get(expediente_id)

func existe_expediente(expediente_id : int) -> bool:
	return expedientes.has(expediente_id)

func eliminar_expediente(expediente_id : int):
	expedientes.erase(expediente_id)

func obtener_todos() -> Array:
	return expedientes.values()

func limpiar():
	expedientes.clear()
