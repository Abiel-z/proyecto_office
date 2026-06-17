extends RigidBody3D
class_name Hoja

enum EstadoFisico {
	ESPERANDO,
	CAIDA,
	FLOTANDO,
	GUARDADA,
	ARRASTRANDO,
	EN_MANO
}

enum EstadoDocumento {
	NORMAL,
	TIMBRADO,
	ACEPTADO,
	RECHAZADO
}

const SHADER_HOJA = preload("res://shaders/shader_hoja.gdshader")

var errores := {}
var estado_fisico : EstadoFisico = EstadoFisico.GUARDADA
var estado_documento : EstadoDocumento = EstadoDocumento.NORMAL

var being_held = false
var player_ref = null
var original_gravity = 0.8
var image_texture: ImageTexture

@onready var viewport = $SubViewport
@onready var ui_root = $SubViewport/Control
@onready var label_texto = $SubViewport/Control/MarginContainer/vbox/RichTextLabel
@onready var label_n_pagina = $SubViewport/Control/MarginContainer/vbox/n_pagina
@onready var sello = $SubViewport/sello
@onready var modelo_hoja = $VisualPivot/model
@onready var visual_pivot = $VisualPivot

@onready var textura_base = $SubViewport/Control/textura_base
@onready var textos_fijos = $SubViewport/Control/textura_texto_fijo
@onready var detalles_fondo = $SubViewport/Control/textura_detalles_fondo
@onready var capa_campos = $SubViewport/Control/textos_dinamicos
@onready var capa_dibujos = $SubViewport/Control/dibujos_dinamicos

@onready var punto_A : Marker3D = $punto_A
@onready var punto_B : Marker3D = $punto_B
@onready var mesh_instance = $hoja_blanca
@onready var lab_nombre := $textos/titulo
var trabajador_correspondiente : Trabajador = null

var carpeta_padre: Node3D = null
var posicion_guardada: Vector3 = Vector3.ZERO
var rotacion_guardada: Vector3 = Vector3.ZERO

var documento : Documento
@onready var debug_flecha = $debug_flecha

func _ready():
	
	
	add_to_group("hojas")
	add_to_group("agarrable")
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.size = Vector2(385 , 575)
	viewport.transparent_bg = true
	viewport.disable_3d = true
	viewport.transparent_bg = false
	ui_root.scale = Vector2.ONE
	sello.visible = false
	revisar_guardado()
	_actualizar_estado_fisico()

func _physics_process(delta):
	#actualizar_flecha_debug()
	corregir_altura()

func agregar_error(id_error : String):
	if not errores.has(id_error):
		errores[id_error] = true

func limpiar_errores():
	errores.clear()

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

	var viewport_texture = viewport.get_texture()

	var shader_material = ShaderMaterial.new()

	shader_material.shader = SHADER_HOJA

	shader_material.set_shader_parameter(
		"documento_texture",
		viewport_texture
	)

	shader_material.set_shader_parameter(
		"mascara_borde",
		documento.tipo.mascara_borde
	)

	modelo_hoja.material_override = shader_material

func actualizar_visual():
	if not documento:
		return
	textura_base.texture = documento.tipo.textura_base
	detalles_fondo.texture = documento.tipo.detalles_fondo
	textos_fijos.texture = documento.tipo.textos_fijos
	label_texto.text = documento.cuerpo
	#limpiar_campos()
	
	
	if capa_dibujos:
		capa_dibujos.dibujos = documento.tipo.dibujos
		capa_dibujos.actualizar_visual()
	
	for campo in documento.tipo.campos:
		var valor = _resolver_valor_campo(campo)
		crear_campo(campo,valor)
		
func _resolver_valor_campo(campo: CampoDocumento):
	# TEMPLATE
	if campo.fuente == CampoDocumento.FuenteCampo.TEMPLATE:
		
		var group_id = documento.tipo.template_id
		var template_group = DatabaseTemplatesDocumentos.templates.get(group_id, {})
		var template = template_group.get(campo.template_parrafo, "")
		if template == "":
			push_warning("Template no encontrado: %s -> %s" % [group_id, campo.template_parrafo])
		var style = DatabaseTemplatesDocumentos.styles.get(campo.color_variable, "{texto}")
		return DocumentRenderer.render_parrafo(template, documento.metadata, style)
	
	
	if campo.id == "historial":
		var texto := ""
		
		for item in documento.metadata.get("historial", []):
			texto += "%s - %s\n " % [ item.get("fecha", ""),item.get("motivo", "")]
		return texto
	
	return documento.metadata.get(campo.id, campo.texto_default)
	

	
	
	
func crear_campo(campo: CampoDocumento, valor):
	var control: Control
	if campo.id == "motivo_evento":
		print("--- VALOR AL ENTRAR A CREAR CAMPO ", valor)
	if campo.bbcode_activo:
		var richlabel = RichTextLabel.new()
		richlabel.bbcode_enabled = true
		control = richlabel
		control.add_theme_font_size_override("normal_font_size",campo.font_size)
		control.add_theme_font_size_override("Normal_Font_Size",campo.font_size)
		control.add_theme_color_override("default_color", campo.color)
		control.text = str(valor)
	else:
		var label = Label.new()
		control = label
		control.text = str(valor)
		if campo.id == "motivo_evento":
			print("TEXTO LABEL CREADO DESDE EL LABEL",control.text)
		control.horizontal_alignment = campo.alineacion_horizontal
		control.vertical_alignment = campo.alineacion_vertical
	
	control.position = campo.posicion
	control.custom_minimum_size = campo.size
	control.size = campo.size
	control.add_theme_font_size_override("font_size",campo.font_size)
	control.add_theme_color_override("font_color", campo.color)

	control.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
	capa_campos.add_child(control)


func obtener_valor_campo( campo : CampoDocumento):
	return documento.metadata.get(campo.id,campo.texto_default)

func reiniciar_pivot():
	visual_pivot.position = Vector3.ZERO
	visual_pivot.rotation = Vector3.ZERO
	visual_pivot.scale = Vector3.ONE

func revisar_guardado():
	if carpeta_padre == null:
		set_estado_fisico(EstadoFisico.GUARDADA)

func set_estado_fisico(nuevo_estado: EstadoFisico):
	estado_fisico = nuevo_estado
	_actualizar_estado_fisico()

func _actualizar_estado_fisico():
	match estado_fisico:
		
		EstadoFisico.ESPERANDO:
			freeze = true
			gravity_scale = 0
			collision_layer = 5
			collision_mask = 5
			linear_velocity = Vector3.ZERO
			angular_velocity = Vector3.ZERO
		
		EstadoFisico.ARRASTRANDO:
			freeze = false
			gravity_scale = original_gravity
			collision_layer = 1
			collision_mask = 1
		
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
			collision_layer = 0
			collision_mask = 0
			linear_velocity = Vector3.ZERO
			angular_velocity = Vector3.ZERO

func esta_en_carpeta() -> bool:
	if estado_fisico == EstadoFisico.GUARDADA:
		return true
	else:
		return false

func get_carpeta_padre() -> Node3D:
	return carpeta_padre

func on_click(player):
	if being_held:
		return
	player.held_sheets.append(self)
	player_ref = player
	set_estado_fisico(EstadoFisico.EN_MANO)

func empezar_arrastre(player):
	player_ref = player
	set_estado_fisico(EstadoFisico.ARRASTRANDO)

func terminar_arrastre(player):
	player_ref = null
	#linear_velocity = Vector3.ZERO
	set_estado_fisico(EstadoFisico.CAIDA)

func grab(camera):
	being_held = true
	player_ref = camera
	set_estado_fisico(EstadoFisico.EN_MANO)

func release():
	being_held = false
	player_ref = null
	gravity_scale = original_gravity
	set_estado_fisico(EstadoFisico.CAIDA)

func arrastrar(target: Vector3):
	var dir = target - global_position
	linear_velocity = dir * 18.0
	angular_velocity *= 0.85

func actualizar_flecha_debug():
	debug_flecha.visible = true
	debug_flecha.position = Vector3.ZERO
	#debug_flecha.scale = Vector3(,0,0.1)
	debug_flecha.position.y = 0.2

func corregir_altura():
	# no corregir mientras cae rápido
	if linear_velocity.length() > 0.1:
		return

	# detectar superficie cercana
	var espacio = get_world_3d().direct_space_state
	#print("DETECADO : " , espacio)

	var origen = global_position
	var destino = global_position + -global_basis.y * 0.05

	var query = PhysicsRayQueryParameters3D.create(
		origen,
		destino
	)

	query.exclude = [self]

	var result = espacio.intersect_ray(query)

	# si toca una superficie
	if result and result.collider.is_in_group("superficies"):

		# NORMAL de la hoja
		var normal_hoja = -global_basis.y.normalized()

		# OFFSET VISUAL
		var offset_visual = normal_hoja * 1

		visual_pivot.position = offset_visual

	else:

		# resetear si no toca nada
		visual_pivot.position = Vector3.ZERO
