extends StaticBody3D

signal revision_terminada(documento_revision)

@export var boton : Node

@onready var area_entrega : Area3D = $area_entrega
@onready var puerta = $mango

var carpetas_existentes : Array = []
var carpetas_a_revisar : Array = []

func _ready():
	boton.boton_presionado.connect(revisar_carpetas)
	add_to_group("punto_entrega")

func revisar_carpetas():
	if puerta.puerta_cerrada:
		carpetas_a_revisar.clear()
		carpetas_existentes.clear()
		var cuerpos = area_entrega.get_overlapping_bodies()
		for cuerpo in cuerpos:
			if cuerpo.is_in_group("carpetas"):
				carpetas_a_revisar.append(cuerpo)
		if carpetas_a_revisar.size() > 0:
			for carpeta in carpetas_a_revisar:
				carpetas_existentes.append(carpeta)
				revisar_carpeta(carpeta)
		else:
			emitir_error()
	else:
		print("PUERTA ABIERTA")
		emitir_error()

func revisar_carpeta(carpeta):
	var resultado = ( ControllerRevision.calcular_puntaje(carpeta.hojas_principales) )
	var puntaje = resultado.puntaje_total
	if puntaje > 0:
		ControllerEconomia.spawnear_monedas(resultado.puntaje_total)
		emitir_aceptado()
	else:
		emitir_rechazo()
	var documento_revision = ( DatabaseSistema.crear_revision( resultado, carpeta.hojas_principales ) )
	revision_terminada.emit( documento_revision )

func emitir_error():
	boton.encender_luz(0.5, Color.YELLOW)

func emitir_aceptado():
	boton.encender_luz(3, Color.GREEN)

func emitir_rechazo():
	boton.encender_luz(3, Color.RED)
