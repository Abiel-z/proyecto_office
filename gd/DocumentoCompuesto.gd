extends Documento
class_name DocumentoCompuesto

@export var paginas : Array[PaginaDocumento] = []
@export var paginas_requeridas : Array

func agregar_pagina(pagina: PaginaDocumento):
	paginas.append(pagina)

func get_hojas():
	return paginas
