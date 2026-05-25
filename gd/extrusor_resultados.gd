extends StaticBody3D

var HojaScene = preload("res://tscn/hoja_en_blanco.tscn")

@export var punto_entrega : Node
@onready var punto_salida = $punto_salida

func _ready():
	punto_entrega.revision_terminada.connect(imprimir_documento)

func imprimir_documento(documento: Documento):

	var hoja = HojaScene.instantiate()

	hoja.set_documento(documento) 

	get_tree().current_scene.add_child(hoja)

	hoja.global_transform = punto_salida.global_transform

	if hoja is RigidBody3D:
		hoja.linear_velocity = Vector3(0,0,1)
		hoja.set_estado_fisico(hoja.EstadoFisico.ESPERANDO)
