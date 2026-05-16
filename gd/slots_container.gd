extends CharacterBody3D

const SPEED = 5.0
const MOUSE_SENS = 0.002

var held_folder = null
var held_sheet = null
var holding_folder = false
var holding_sheet = false
var carpeta_actual : Node3D = null

var intentando_agarre := false
var tiempo_agarre := 0.0
var tiempo_requerido := 0.25

var objeto_candidato = null
var dragged_object = null 


var en_ui_carpeta : bool = false
@onready var camera = $Camera3D
@onready var drag_hold_point = $Camera3D/A
@onready var hoja_hold_point = $Camera3D/hoja_hold_point
@onready var carpeta_hold_point = $Camera3D/carpeta_hold_point
@onready var puntero = $Camera3D/Puntero

const ALTURA_NORMAL = 1.6
const ALTURA_AGACHADO = 1.0
const VELOCIDAD_AGACHADO = 2.5
const JUMP_VELOCITY = 4.5
const GRAVITY = 9.8

var agachado := false

var textura_punto = preload("res://datos blender/texturas/puntero_normal.png")
var textura_agarre = preload("res://datos blender/texturas/puntero_agarre.png")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if not puntero:
		crear_puntero()

func crear_puntero():
	var sprite = Sprite2D.new()
	sprite.name = "Puntero"
	sprite.texture = textura_punto
	sprite.position = Vector2(0, 0)  # Centro de la pantalla
	sprite.centered = true
	camera.add_child(sprite)
	puntero = sprite


func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENS)
		$Camera3D.rotate_x(-event.relative.y * MOUSE_SENS)
		$Camera3D.rotation.x = clamp($Camera3D.rotation.x, -1.2, 1.2)
		
		if puntero:
			var viewport = get_viewport()
			var mouse_pos = viewport.get_mouse_position()
			puntero.position = mouse_pos
		
	if held_folder != null:
		if event.is_action_pressed("wheel_up"):
			held_folder.anterior_documento()
		if event.is_action_pressed("wheel_down"):
			held_folder.siguiente_documento()
		if event.is_action_pressed("ui_cancel"):
			held_folder.cerrar_carpeta()
			held_folder = null
			en_ui_carpeta = false

	if event.is_action_pressed("click_izquierdo"):
		var result = raycast_desde_mouse()
		if holding_folder and held_folder != null:
			if result:
				var collider = result.collider
				if collider.is_in_group("cajas"):
					held_folder.release()
					var agregado = collider.agregar_carpeta(held_folder)
					print(agregado)
					if agregado:
						holding_folder = false
						held_folder = null
						return
					
				elif collider.is_in_group("carpetas"):
					if collider.caja_padre != null:
						collider.caja_padre.quitar_carpeta(collider)
					held_folder = collider
					held_folder.estado_fisico = held_folder.EstadoFisico.SOSTENIDO
					held_folder.camera_ref = camera
					holding_folder = true
					
			if held_folder != null and  held_folder.carpeta_abierta:
				var hoja = held_folder.sacar_hoja_actual()
				if hoja != null:
					held_sheet = hoja
					held_sheet.grab(camera)
					holding_sheet = true

		if not holding_sheet:
			if result:
				var collider = result.collider
				if collider.is_in_group("hojas"):
					held_sheet = collider
					held_sheet.grab(camera)
					holding_sheet = true
				elif collider.is_in_group("carpetas"):
					held_folder = collider
					held_folder.grab(camera)
					holding_folder = true
				elif collider.is_in_group("cajas"):
					iniciar_agarre()
	
	if event.is_action_released("click_izquierdo"):
		cancelar_agarre()
	
	if event.is_action_pressed("click_derecho"):
		if holding_folder and held_folder != null:
			held_folder.estado_fisico = held_folder.EstadoFisico.LIBRE
			held_folder.being_held = false
			held_folder.camera_ref = null
			
			held_folder.release()
			held_folder = null
			holding_folder = false
			return
		if holding_sheet and held_sheet != null:
			held_sheet.release()
			held_sheet = null
			holding_sheet = false
			return

	
	if event.is_action_pressed("interactuar") and holding_folder != null:
		
		if held_folder.is_in_group("carpetas") and held_folder.carpeta_abierta:
			print("CERRANDO CARPETA DESDE PLAYER")
			held_folder.cerrar_carpeta()
			return
		held_folder.abrir_carpeta()
		#en_ui_carpeta = true
		#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func iniciar_agarre():
	var result = raycast_desde_mouse()
	if not result:
		return
	var collider = result.collider
	if collider.is_in_group("cajas"):
		intentando_agarre = true
		tiempo_agarre = 0.0
		objeto_candidato = collider

func cancelar_agarre():
	intentando_agarre = false
	tiempo_agarre = 0.0
	if dragged_object != null:
		dragged_object.stop_drag()
		dragged_object = null
	objeto_candidato = null



func raycast_desde_mouse():
	var space_state = get_world_3d().direct_space_state
	var mouse_pos = get_viewport().get_mouse_position()
	var origin = camera.project_ray_origin(mouse_pos)
	var end = origin + camera.project_ray_normal(mouse_pos) * 3.0
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collision_mask = 1
	return space_state.intersect_ray(query)

func actualizar_puntero():
	if not puntero:
		return
	# Detectar si hay una hoja agarrable delante
	var hay_hoja = detectar_hoja_delante()
	
	if hay_hoja:
		puntero.texture = textura_agarre
	else:
		puntero.texture = textura_punto

func detectar_hoja_delante() -> bool:
	var space_state = get_world_3d().direct_space_state
	var viewport = get_viewport()
	var mouse_pos = viewport.get_mouse_position()
	
	var origin = camera.project_ray_origin(mouse_pos)
	var end = origin + camera.project_ray_normal(mouse_pos) * 3.0
	
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collision_mask = 1
	var result = space_state.intersect_ray(query)
	
	return result and result.collider.is_in_group("hojas")

func _physics_process(delta):
	if intentando_agarre and objeto_candidato != null:
		tiempo_agarre += delta
		# AQUÍ IRÍA TU CÍRCULO UI
		if tiempo_agarre >= tiempo_requerido:
			var result = raycast_desde_mouse()
			if result and result.collider == objeto_candidato:
				dragged_object = objeto_candidato
				dragged_object.start_drag(drag_hold_point)
			intentando_agarre = false
	
	if not en_ui_carpeta:
		var result = raycast_desde_mouse()
		var es_agarrable = result and (
			result.collider.is_in_group("hojas")
			or result.collider.is_in_group("carpetas")
		)

		puntero.texture = (
			textura_agarre
			if es_agarrable
			else textura_punto
		)

	if holding_sheet and held_sheet.is_in_group("hojas"):
		var target_pos = hoja_hold_point.global_transform.origin

		held_sheet.global_transform.origin = (
			held_sheet.global_transform.origin.lerp(
				target_pos,
				0.3
			)
		)

	if holding_folder and held_folder != null:
		held_folder.global_position = (
			held_folder.global_position.lerp(
				carpeta_hold_point.global_position,
				0.3
			)
		)
		held_folder.global_basis = (
			held_folder.global_basis.slerp(
				carpeta_hold_point.global_basis,
				0.3
			)
		)

	agachado = Input.is_action_pressed("agacharse")
	var velocidad_actual = SPEED
	if agachado:
		velocidad_actual = VELOCIDAD_AGACHADO
		camera.position.y = lerp(
			camera.position.y,
			ALTURA_AGACHADO,
			delta * 10.0
		)
	else:
		camera.position.y = lerp(
			camera.position.y,
			ALTURA_NORMAL,
			delta * 10.0
		)
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	if Input.is_action_just_pressed("saltar") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector(
		"left",
		"right",
		"forward",
		"back"
	)

	var direction = (
		transform.basis
		* Vector3(input_dir.x, 0, input_dir.y)
	).normalized()

	if direction:
		velocity.x = direction.x * velocidad_actual
		velocity.z = direction.z * velocidad_actual
	else:
		velocity.x = move_toward(
			velocity.x,
			0,
			velocidad_actual
		)
		velocity.z = move_toward(
			velocity.z,
			0,
			velocidad_actual
		)

	move_and_slide()
