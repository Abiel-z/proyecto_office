extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func revisar_hojas(hojas:Array):

	var estadisticas = {
		"nombre": {},
		"cargo": {},
		"tipo": {},
		"fecha": {}
	}

	for hoja in hojas:

		var doc = hoja.documento
		sumar_valor( estadisticas["nombre"], doc.nombre )
		sumar_valor( estadisticas["cargo"], doc.cargo )
		sumar_valor( estadisticas["tipo"], doc.tipo.id )
		sumar_valor( estadisticas["fecha"], doc.fecha )
		
	return estadisticas
	
func sumar_valor(dic:Dictionary, valor):
	if not dic.has(valor):
		dic[valor] = 0

	dic[valor] += 1

func consultar_mayor_coincidencia(estadisticas: Dictionary) -> Dictionary:
	var mejor_categoria = ""
	var mejor_valor = null
	var mejor_cantidad = 0
	for categoria in estadisticas.keys():
		var dic = estadisticas[categoria]
		for valor in dic.keys():
			var cantidad = dic[valor]
			if cantidad > mejor_cantidad:
				mejor_cantidad = cantidad
				mejor_categoria = categoria
				mejor_valor = valor
	return {
		"categoria": mejor_categoria,
		"valor": mejor_valor,
		"cantidad": mejor_cantidad
	}

func calcular_puntaje( hojas:Array ) -> Dictionary:
	var estadisticas = revisar_hojas(hojas)
	var mejor = consultar_mayor_coincidencia( estadisticas )
	var puntaje_base = mejor.cantidad * 10
	var multiplicador := 1.0
	var bonos := []
	# BONUS TIMBRADO
	var todas_timbradas := true
	#
	for hoja in hojas:
		if hoja.estado_documento != Hoja.EstadoDocumento.TIMBRADO:
			todas_timbradas = false
			break

	if todas_timbradas:
		multiplicador += 0.5
		bonos.append("TIMBRADO")

	var total = int(
		puntaje_base * multiplicador
	)

	return {
		
		"estadisticas": estadisticas,
		"mejor_coincidencia" : mejor,
		"mejor_categoria": mejor["categoria"],
		"mejor_valor": mejor["valor"],
		"mejor_cantidad": mejor["cantidad"],
		"puntaje_base": puntaje_base,
		"multiplicador": multiplicador,
		"puntaje_total": total,
		"bonos": bonos
	}

