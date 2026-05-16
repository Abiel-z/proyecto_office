extends RigidBody3D
class_name Hoja

enum EstadoFisico {
	CAIDA,
	FLOTANDO,
	GUARDADA,
	EN_MANO
}

enum EstadoDocumento {
	NORMAL,
	TIMBRADO,
	ACEPTADO,
	RECHAZADO
}

var estado_fisico : EstadoFisico = EstadoFisico.GUARDADA
var estado_documento : EstadoDocumento = EstadoDocumento.NORMAL

var being_held = false
var camera_ref = null
var original_gravity = 0.8
var image_texture: ImageTexture

@onready var viewport = $SubViewport
@onready var ui_root = $SubViewport/Control
@onready var label_texto = $SubViewport/Control/MarginContainer/vbox/RichTextLabel
@onready var label_n_pagina = $SubViewport/Control/MarginContainer/vbox/n_pagina
@onready var sello = $SubViewport/sello
@onready var modelo_hoja = $hoja_blanca/Cube

@onready var punto_A : Marker3D = $punto_A
@onready var punto_B : Marker3D = $punto_B
@onready var mesh_instance = $hoja_blanca
@onready var lab_nombre := $textos/titulo
var trabajador_correspondiente : Trabajador = null

var carpeta_padre: Node3D = null
var posicion_guardada: Vector3 = Vector3.ZERO
var rotacion_guardada: Vector3 = Vector3.ZERO

var documento : Documento

func _ready():
	add_to_group("hojas")
	add_to_group("agarrable")
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.size = Vector2(370 , 512)
	viewport.transparent_bg = false
	viewport.disable_3d = true
	ui_root.scale = Vector2.ONE
	sello.visible = false
	revisar_guardado()
	_actualizar_estado_fisico()

func timbrar():
	estado_documento = EstadoDocumento.TIMBRADO
	sello.visible = true

func set_documento(doc: Documento):
	documento = doc
	
	if not is_inside_tree():
		await ready
	
	actualizar_visual()
	aplicar_textura()

func aplicar_textura():
	await get_tree().process_frame
	#await RenderingServer.frame_post_draw
	var texture = viewport.get_texture()
	
	var material = StandardMaterial3D.new()
	
	material.albedo_texture = texture
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	
	modelo_hoja.material_override = material

func actualizar_visual():
	if not documento:
		return
	label_texto.text = (
		DatabaseTrabajadores.generar_bbcode_documento(documento)
	)

func revisar_guardado():
	if carpeta_padre == null:
		set_estado_fisico(EstadoFisico.GUARDADA)

func set_estado_fisico(nuevo_estado: EstadoFisico):
	estado_fisico = nuevo_estado
	_actualizar_estado_fisico()

func _actualizar_estado_fisico():
	match estado_fisico:

		EstadoFisico.GUARDADA:
			freeze = true
			gravity_scale = 0
			collision_layer = 0
			collision_mask = 0
			linear_velocity = Vector3.ZERO
			angular_velocity = Vector3.ZERO

		EstadoFisico.CAIDA:
			freeze = false
			gravity_scale = original_gravity
			collision_layer = 1
			collision_mask = 1

		EstadoFisico.FLOTANDO:
			freeze = false
			gravity_scale = 0.2
			collision_layer = 1
			collision_mask = 1

		EstadoFisico.EN_MANO:
			freeze = false
			gravity_scale = 0
			collision_layer = 1
			collision_mask = 1
			linear_velocity = Vector3.ZERO
			angular_velocity = Vector3.ZERO

func esta_en_carpeta() -> bool:
	if estado_fisico == EstadoFisico.GUARDADA:
		return true
	else:
		return false

func get_carpeta_padre() -> Node3D:
	return carpeta_padre

func grab(camera):
	
	being_held = true
	camera_ref = camera
	set_estado_fisico(EstadoFisico.EN_MANO)
	gravity_scale = 0
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

func release():
	being_held = false
	camera_ref = null
	gravity_scale = original_gravity
	set_estado_fisico(EstadoFisico.CAIDA)

func _physics_process(delta):

	# SOLO si está libre
	if being_held and camera_ref and estado_fisico != EstadoFisico.GUARDADA:

		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO

		var look_pos = camera_ref.global_transform.origin
		look_pos.y = global_transform.origin.y

		look_at(look_pos, Vector3.UP)
		rotate_y(deg_to_rad(-90))
