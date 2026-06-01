extends Node

func generar_bbcode_documento(doc: Documento) -> String:
	
	if doc.tipo == null:
		return "[color=red]SIN TIPO DOCUMENTO[/color]"
	
	match doc.tipo.id:
		"REVISION":
			return generar_revision(doc)
		"CONTRATO":
			return generar_contrato(doc)
		"HORARIO":
			return generar_horario(doc)
		"SALUD":
			return generar_salud(doc)
			
	return "[color=red]DOCUMENTO INVALIDO[/color]"

func generar_revision(doc: Documento) -> String:

	var data = doc.metadata

	print(data)
	print(data.keys())
	
	var mejor = data["mejor_coincidencia"]

	var txt := ""

	txt += "[font_size=22]"
	txt += "[b][center] INFORME DE CLASIFICACION [/center][/b]\n\n"
	txt += "[font_size=12]"
	txt += "Categoria principal detectada:\n"
	txt += "[color=#cccc66][b]"
	txt += str(mejor.categoria).to_upper()
	txt += "[/b][/color]\n"
	txt += "Valor coincidente: "
	txt += "[color=#66ccff]"
	txt += str(mejor.valor)
	txt += "[/color]\n"
	txt += "Coincidencias detectadas: "
	txt += "[b]"
	txt += str(mejor.cantidad)
	txt += "[/b]\n\n"
	txt += "[b]PUNTAJE BASE:[/b] "
	txt += str(data.puntaje_base)
	txt += "\n"
	txt += "[b]MULTIPLICADOR:[/b] x"
	txt += str(data.multiplicador)
	txt += "\n"
	txt += "[b]TOTAL GENERADO:[/b] "
	txt += "[color=yellow][font_size=18]"
	txt += str(data.puntaje_total)
	txt += " CREDITOS"
	txt += "[/font_size][/color]\n\n"
	if not data.bonos.is_empty():
		txt += "[b]BONIFICACIONES:[/b]\n"
		for bonus in data.bonos:
			txt += (
				"[color=green]+ "
				+ str(bonus)
				+ "[/color]\n"
			)
	txt += "\n\n"
	txt += "[right]"
	txt += "[i]Sistema automatizado de valorizacion[/i]"
	txt += "[/right]"
	return txt

func generar_contrato(doc: Documento) -> String:
	var txt := ""
	txt += "[font_size=20]"
	txt += "[b][center] CONTRATO DE TRABAJO [/center][/b]\n\n"
	txt += "[font_size=12]"
	txt += "En la ciudad de [color=#6666aa]" + doc.cargo + "[/color], "
	txt += "con fecha de contratación [color=#888888]" + doc.fecha + "[/color], "
	txt += "entre la empresa y el/la trabajador/a "

	txt += "[color=#2a2a2a][b]" + doc.nombre + "[/b][/color], "
	txt += "se establece el siguiente acuerdo laboral.\n\n"

	txt += "[font_size=18][b]ANTECEDENTES[/b][/font_size]\n"
	txt += "El/la trabajador/a desempeñará funciones en calidad de "
	txt += "[color=#4444aa][b]" + doc.cargo + "[/b][/color] "
	txt += "bajo supervisión directa de la empresa contratante.\n\n"

	txt += "[font_size=18][b]CONDICIONES[/b][/font_size]\n"
	txt += "Sueldo base establecido en [color=#888888]$[dato clasificado][/color]. "
	txt += "Bonificaciones sujetas a evaluación interna.\n\n\n\n\n\n\n\n"

	txt += "[center] ________________                                    _________________ \n "
	txt += "[i][font_size=10]FIRMA EMPRESA                                      FIRMA TRABAJADOR"
	return txt

func generar_horario(doc : Documento) -> String:
	var txt := ""

	txt += "[center]"
	txt += "[font_size=28]"
	txt += "[b]HORARIO LABORAL[/b]"
	txt += "[/font_size]"
	txt += "[/center]\n\n"

	txt += "[b]TRABAJADOR:[/b] "
	txt += doc.nombre + "\n"

	txt += "[b]CARGO:[/b] "
	txt += doc.cargo + "\n"

	txt += "[b]FECHA:[/b] "
	txt += doc.fecha + "\n\n"

	txt += doc.contenido

	txt += "\n\n[right][i]1/3[/i][/right]"

	return txt

func generar_salud(doc : Documento) -> String:
	var txt := ""

	txt += "[center]"
	txt += "[font_size=28]"
	txt += "[b]CERTIFICADO SALUD[/b]"
	txt += "[/font_size]"
	txt += "[/center]\n\n"

	txt += "[b]TRABAJADOR:[/b] "
	txt += doc.nombre + "\n"

	txt += "[b]CARGO:[/b] "
	txt += doc.cargo + "\n"

	txt += "[b]FECHA:[/b] "
	txt += doc.fecha + "\n\n"

	txt += doc.contenido

	txt += "\n\n[right][i]1/3[/i][/right]"

	return txt

