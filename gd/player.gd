extends CharacterBody3D

const SPEED = 5.0
const MOUSE_SENS = 0.002

const ALTURA_NORMAL = 1.6
const ALTURA_AGACHADO = 1.0
const VELOCIDAD_AGACHADO = 2.5
const JUMP_VELOCITY = 4.5
const GRAVITY = 9.8

var velocidad_rotacion := 1.0
var held_folder = null
var held_stamp = null
var held_sheets : Array = []
var held_box = null
var mango_agarrado = null

var holding_folder := false
var holding_box := false
var holding_stamp := false

var intentando_agarre := false
var tiempo_agarre := 0.0
var tiempo_requerido := 0.25

var objeto_candidato = null
var dragged_object = null
var rotando_objeto := false

var en_ui_carpeta := false
var agachado := false
var mouse_delta := Vector2.ZERO
var hojas_maximas := 10
var debug_punto : MeshInstance3D

@onready var camera = $Camera3D
@onready var drag_hold_point = $Camera3D/A
@onready var hoja_hold_point = $Camera3D/hoja_hold_point
@onready var carpeta_hold_point = $Camera3D/carpeta_hold_point
@onready var timbre_hold_point = $Camera3D/timbre_hold_point
@onready var linterna = $Camera3D/OmniLight3D
var linterna_encendida = false

var puntero : Sprite2D = null

var textura_punto = preload("res://datos blender/texturas/puntero_normal.png")
var textura_agarre = preload("res://datos blender/texturas/puntero_agarre.png")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	crear_puntero()
	crear_debug_punto()

func crear_puntero():
	if puntero != null:
		return
	puntero = Sprite2D.new()
	puntero.name = "Puntero"
	puntero.texture = textura_punto
	puntero.centered = true
	camera.add_child(puntero)
	var viewport_size = get_viewport().get_visible_rect().size
	puntero.position = viewport_size / 2

func tiene_hojas() -> bool:
	return not held_sheets.is_empty()
	
func hoja_actual():
	if held_sheets.is_empty():
		return null
	return held_sheets[0]

func _input(event):
	# --- DIRECCION MOUSE ---
	if event is InputEventMouseMotion:
		mouse_delta = event.relative
		if mango_agarrado != null:
			mango_agarrado.arrastrar(event.relative.y)
			
		if not rotando_objeto:
			rotate_y(-event.relative.x * MOUSE_SENS)
			camera.rotate_x(-event.relative.y * MOUSE_SENS)
			camera.rotation.x = clamp(
				camera.rotation.x,
				-1.2,
				1.2
			)
	
	if event.is_action_pressed("encender_linterna"):
		print("activando linterna")
		if linterna_encendida:
			linterna.light_energy = 0.0
			linterna_encendida = false
		else:
			linterna.light_energy = 1.0
			linterna_encendida = true
	
	# --- SCROLL DOCUMENTOS WHILE HOLD_FOLDER ---
	if event.is_action_pressed("wheel_up"):
		if tiene_hojas():
			held_sheets.push_back(
			held_sheets.pop_front()
			)
			return
		
		held_folder.anterior_documento()

	if event.is_action_pressed("wheel_down"):
		if tiene_hojas():
			held_sheets.push_front(
			held_sheets.pop_back()
			)
			return
		held_folder.siguiente_documento()

	# --- CLICK IZQUIERDO ---
	if event.is_action_pressed("click_izquierdo"):
		# --- AGARRAR HOJA DESDE CARPETA ---
		if held_folder == null and tiene_hojas():
			colocar_hoja_en_superficie()
			return
			
		if held_folder != null and  held_folder.carpeta_abierta:
			var hoja = held_folder.sacar_hoja_actual()
			if hoja != null:
				held_sheets.append(hoja)
				hoja.grab(camera)
		
		var result = raycast_desde_mouse()
		if result:
			var collider = result.collider
			if collider.is_in_group("botones"):
				print("boton_detectado")
				collider.interactuar()
			if collider.is_in_group("mango"):
				mango_agarrado = collider
				return
				
			# --- AGARRAR HOJA DESDE SUELO ---
			if collider.is_in_group("timbres") and not holding_stamp:
				held_stamp = collider
				holding_stamp = true
				held_stamp.grab(camera)
				return
			if collider.is_in_group("hojas") and held_sheets.size() < hojas_maximas:
				held_sheets.append(collider)
				collider.grab(camera)
				return

			# --- AGARRAR CARPETA ---
			if collider.is_in_group("carpetas") and not holding_folder:
				if collider.caja_padre != null:
					collider.caja_padre.quitar_carpeta(collider)
				held_folder = collider
				holding_folder = true
				held_folder.estado_fisico = held_folder.EstadoFisico.SOSTENIDO
				held_folder.being_held = true
				held_folder.camera_ref = camera
				return
			
			if collider.is_in_group("cajas") and holding_folder:
				var agregado = await collider.agregar_carpeta(held_folder)
				if agregado:
					holding_folder = false
					held_folder = null
				return

			# --- AGARRAR CAJA ---
			if collider.is_in_group("cajas"):
				iniciar_agarre()

	# --- SOLTAR CLICK ---
	if event.is_action_released("click_izquierdo"):
		cancelar_agarre()
		mango_agarrado = null

	if event.is_action_pressed("click_derecho"):
		if holding_folder and tiene_hojas():
					var hoja = held_sheets.pop_front()
					held_folder.agregar_hoja(hoja)
					hoja.set_estado_fisico(hoja.EstadoFisico.GUARDADA)
					hoja.being_held = false
					hoja = null
					return

	# --- SOLTAR OBJETOS ("Q") ---
	if event.is_action_pressed("soltar"):
		if holding_folder and held_folder != null:
			held_folder.estado_fisico = held_folder.EstadoFisico.LIBRE
			held_folder.being_held = false
			held_folder.camera_ref = null
			holding_folder = false
			held_folder = null
			return

		if tiene_hojas():
			var hoja = hoja_actual()
			hoja.release()
			held_sheets.erase(hoja)
			return
		
		if holding_stamp and held_stamp != null:
			held_stamp.release()
			holding_stamp = false
			held_stamp = null
			return
 
	# --- ABRIR CARPETA ---
	if event.is_action_pressed("interactuar"):
		if held_folder != null:
			if held_folder.carpeta_abierta:
				held_folder.cerrar_carpeta()
			else:
				held_folder.abrir_carpeta()
	
	# --- ROTAR OBJETO ---
	if event.is_action_pressed("rotar"):
		print("boton rotar presionado")
		rotando_objeto = true
		print("ROTANDO :", rotando_objeto)

	if event.is_action_released("rotar"):
		print("boton rotar liberado")
		rotando_objeto = false
		print("ROTANDO :", rotando_objeto)
		# --- ROTAR OBJETO ---
	
		# --- TIMBRAR HOJAS ---
	if event.is_action_pressed("timbrar"):
		if holding_stamp and tiene_hojas():
			var hoja = hoja_actual()
			hoja.timbrar()
			#held_stamp.animar_timbrado()
		# --- TIMBRAR HOJAS ---

func iniciar_agarre():
	var result = raycast_desde_mouse()
	if not result:
		return
	var collider = result.collider
	if collider.is_in_group("cajas"):
		objeto_candidato = collider
		held_box = collider
		intentando_agarre = true
		tiempo_agarre = 0.0

func cancelar_agarre():
	intentando_agarre = false
	tiempo_agarre = 0.0
	if dragged_object != null:
		held_box.stop_drag()
		dragged_object = null
	objeto_candidato = null

func alinear_con_normal(normal: Vector3) -> Basis:
	var forward = -camera.global_transform.basis.z
	# evitar vector degenerado
	if abs(forward.dot(normal)) > 0.95:
		forward = Vector3.RIGHT
	var right = normal.cross(forward).normalized()
	var corrected_forward = right.cross(normal).normalized()
	return Basis(right, normal, corrected_forward)

func colocar_hoja_en_superficie():
	print("COLOCANDO HOJA")
	if not tiene_hojas():
		return
	var result = raycast_desde_mouse()
	if not result:
		return
	var hoja = hoja_actual()
	var posicion = result.position
	var normal = result.normal
	
	var offset = normal * 0.01
	held_sheets.erase(hoja)
	hoja.release()
	hoja.global_position = posicion + offset
	print("posicion : " , posicion)
	#hoja.global_basis = alinear_con_normal(normal)
	hoja.rotation = Vector3.ZERO
	hoja.linear_velocity = Vector3.ZERO
	hoja.angular_velocity = Vector3.ZERO
	held_sheets.erase(hoja)
	hoja.set_estado_fisico(Hoja.EstadoFisico.CAIDA)

func crear_debug_punto():
	debug_punto = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.1
	sphere.height = 0.1
	debug_punto.mesh = sphere
	add_child(debug_punto)

func raycast_desde_mouse():
	var space_state = get_world_3d().direct_space_state
	var mouse_pos = get_viewport().get_mouse_position()
	var origin = camera.project_ray_origin(mouse_pos)
	var end = origin + camera.project_ray_normal(mouse_pos) * 3.0
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collision_mask = 1
	var result = space_state.intersect_ray(query)
	if result:
		debug_punto.visible = true
		debug_punto.global_position = result.position
		debug_punto.look_at(
		result.position + result.normal,
		Vector3.UP
		)
	else:
		debug_punto.visible = false
	return result

func actualizar_puntero():
	if puntero == null:
		return
	var result = raycast_desde_mouse()
	var agarrable := false
	if result:
		var collider = result.collider
		agarrable = (
			collider.is_in_group("agarrable")
		)
	puntero.texture = (
		textura_agarre
		if agarrable
		else textura_punto
	)

func _physics_process(delta):
	actualizar_puntero()
	# AGARRE CAJA
	if intentando_agarre and objeto_candidato != null:
		tiempo_agarre += delta
		if tiempo_agarre >= tiempo_requerido:
			var result = raycast_desde_mouse()
			if result and result.collider == objeto_candidato:
				if rotando_objeto:
					held_box.rotate_object_local(
						Vector3.UP,
						-mouse_delta.y * 0.001
					)
					held_box.rotate_object_local(
						Vector3.RIGHT,
						-mouse_delta.x * 0.001
					)
				dragged_object = objeto_candidato
				holding_box = true
				dragged_object.start_drag(drag_hold_point)
			intentando_agarre = false
	
	# MOVER HOJA
	for i in range(held_sheets.size()):
		var hoja = held_sheets[i]
		var offset = Vector3(0, i * 0.01 , 0)
		var target_pos = (
			hoja_hold_point.global_position
			+ hoja_hold_point.global_basis * offset )
		hoja.global_position = hoja.global_position.lerp(
			target_pos,
			0.3 )
		if rotando_objeto:
			hoja.rotate_object_local(
				Vector3.UP,
				-mouse_delta.x * 0.01 )
			hoja.rotate_object_local(
				Vector3.RIGHT,
				-mouse_delta.y * 0.01 )
		else:
			hoja.global_basis = hoja.global_basis.slerp(
				hoja_hold_point.global_basis, 0.3 )

	# --- MOVER CARPETA ---
	if holding_folder and held_folder != null:

		held_folder.global_position = held_folder.global_position.lerp(
			carpeta_hold_point.global_position,
			0.3
		)
		if rotando_objeto:
			held_folder.rotate_object_local(Vector3.UP, -mouse_delta.x * 0.001)
			held_folder.rotate_object_local(Vector3.RIGHT, -mouse_delta.y * 0.001)
		else:
			held_folder.global_basis = held_folder.global_basis.slerp(
			carpeta_hold_point.global_basis,
			0.3
		)

	# --- MOVER TIMBRE ---
	if holding_stamp and held_stamp != null:
		held_stamp.global_position = held_stamp.global_position.lerp(
			timbre_hold_point.global_position,
			0.99
		)
	
	
	# --- AGACHARSE ---
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

	# --- GRAVEDAD ---
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
		
	# --- SALTO ---

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
