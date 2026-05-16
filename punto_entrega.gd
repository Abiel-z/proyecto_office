extends StaticBody3D

@export var boton : Node
@onready var area_entrega : Area3D = $area_entrega
@onready var puerta = $mango
var carpetas_existentes : Array = []
var carpetas_a_revisar : Array = []

func _ready():
	print(boton)
	boton.boton_presionado.connect(revisar_carpetas)
	add_to_group("punto_entrega")

func _process(delta):
	#print("CUERPOS RAW: ", area_entrega.get_overlapping_bodies())
	pass
	
func revisar_carpetas():
	if puerta.puerta_cerrada:
		carpetas_a_revisar.clear()
		carpetas_existentes.clear()
		var cuerpos = area_entrega.get_overlapping_bodies()
		for cuerpo in cuerpos:
			if cuerpo.is_in_group("carpetas"):
				carpetas_a_revisar.append(cuerpo)
		if carpetas_a_revisar.size() != 0: 
			for carpeta in carpetas_a_revisar:
					carpetas_existentes.append(carpeta)
					revisar_carpeta(carpeta)
		else:
			emitir_error()

	else:
		print("PUERTA ABIERTA")
		emitir_error()

func revisar_carpeta(carpeta):
	var carpeta_correcta = true
	var errores : int = 0
	var correctas : int = 0
	
	for hoja in carpeta.hojas_principales:
		# REVISION ACTUAL
		if hoja.estado_documento != Hoja.EstadoDocumento.TIMBRADO:
			carpeta_correcta = false
			print("hoja sin timbre")
			errores += 1
			emitir_error()
	if errores >= 1:
		carpeta_correcta = false
	
	if carpeta_correcta:
		emitir_aceptado()
		print("CARPETA OK")
	else:
		emitir_rechazo()
		print("CARPETA RECHAZADA")

func emitir_error():
	boton.encender_luz ( 0.5 , Color.YELLOW)
	
func emitir_aceptado():
	boton.encender_luz( 3 , Color.GREEN)
	
func emitir_rechazo():
	boton.encender_luz( 3 , Color.RED)
