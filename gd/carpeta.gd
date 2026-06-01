extends RigidBody3D

enum EstadoFisico {
	CAIDA,
	EN_MANO,
	ARRASTRANDO,
	GUARDADO
}
enum EstadoRevision {
		PENDIENTE,
		APROVADA,
		RECHAZADA
}
var errores_detectados : Array = []

var estado_fisico : EstadoFisico = EstadoFisico.CAIDA:
	set(value):
		estado_fisico = value
		_actualizar_estado_fisico()
		
		
		
var siendo_rotada = false 
var carpeta_abierta: bool = false
var cerrando := false
var esta_guardada : bool = false
var being_held = false
var player_ref = null
var original_gravity := 1
var caja_padre = null
var slot_actual = null
var hojas_reacomodadas := false

@onready var modelo = $modelo
@onready var tapa_1 = $modelo/tapa_1
@onready var tapa_2 = $modelo/tapa_1/tapa_2
@onready var punto_guardado = $posicion_giro
var base_rot_tapa_1 : Vector3
var base_rot_tapa_2 : Vector3

@onready var debug_slot := $DEBUG_SLOT 



var rotacion_cerrada : Vector3
var rotacion_abierta : Vector3
var velocidad_apertura : float = 5.0

var angulo_total := 0.0
var angulo_tapa1 := 0.0
var angulo_tapa2 := 0.0
var angulo_max := deg_to_rad(170)
var apertura : float = 0.0
var apertura_objetivo : float = 0.0

@onready var collision = $CollisionShape3D
@onready var anim_player = $modelo/AnimationPlayer
@onready var ui_panel = $ui_textos

@onready var documento_texto = $titulo_documento
@onready var documento_titulo = $modelo/tapa_1/tapa_2/texto_documento

@onready var punto_spawn_A = $PUNTO_A
@onready var punto_secundario_A = $modelo/tapa_1/tapa_2/PUNTO_A

#var hojas_apiladas : Array = []
#var indice_actual: int = 0
var hojas_principales : Array = []
var hojas_secundarias : Array = []

var offset_apilamiento : float = 0.01
var grosor_actual : float  = 0.0
# --- FUNCIONES DE EJECUCION --- 
func _ready():
	linear_damp = 2.0
	angular_damp = 4.0
	
	add_to_group("carpetas")
	add_to_group("agarrable")
	add_to_group("arrastrable")
	#crear_debug_basis()
	base_rot_tapa_1 = tapa_1.rotation
	base_rot_tapa_2 = tapa_2.rotation
	actualizar_apertura_visual()

func _physics_process(delta):
	grosor_actual = ( hojas_principales.size() + hojas_secundarias.size() ) * 0.01
	punto_guardado.position.x = grosor_actual
	
	if being_held and player_ref:
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
	
	apertura = lerp(apertura, apertura_objetivo, delta * 6.0)
	actualizar_apertura_visual()
	if cerrando:
			if apertura >= 0.02 and not hojas_reacomodadas:
				reacomodar_hojas_cerradas()
				hojas_reacomodadas = true
	else:
		hojas_reacomodadas = false
	actualizar_etiqueta()
# --- FUNCIONES DE EJECUCION --- 

func actualizar_etiqueta():
	var estadisticas = ControllerRevision.revisar_hojas(hojas_principales)
	var mayor = ControllerRevision.consultar_mayor_coincidencia(estadisticas)
	if mayor.is_empty():
		documento_titulo.text = "carpeta vacía"
		return
	match mayor.categoria:
		"nombre":
			documento_titulo.text = "Archivo de " + str(mayor.valor)
		"tipo":
			documento_titulo.text = "Archivo " + str(mayor.valor)
		"fecha":
			documento_titulo.text = "Documentos " + str(mayor.valor)
		"cargo":
			documento_titulo.text = "Departamento " + str(mayor.valor)




# --- FUNCIONES DE ESTADO ---
func set_estado_fisico(nuevo_estado: EstadoFisico):
	estado_fisico = nuevo_estado
	_actualizar_estado_fisico()

func _actualizar_estado_fisico():
	match estado_fisico:

		EstadoFisico.GUARDADO:
			freeze = true
			gravity_scale = 0
			collision_layer = 1
			collision_mask = 1
			linear_velocity = Vector3.ZERO
			angular_velocity = Vector3.ZERO
			
		EstadoFisico.EN_MANO:
			freeze = true
			gravity_scale = 0
			collision.disabled = true
			linear_velocity = Vector3.ZERO
			angular_velocity = Vector3.ZERO
			freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
			collision_layer = 0
			collision_mask = 0
			
		EstadoFisico.CAIDA:
			gravity_scale = original_gravity
			collision.disabled = false
			freeze = false
			freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
			collision_layer = 1
			collision_mask = 1

		EstadoFisico.ARRASTRANDO:
			freeze = false
			freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
			gravity_scale = original_gravity
			collision_layer = 1
			collision_mask = 1

func esta_abierta() -> bool:
	if carpeta_abierta:
		return true
	else:
		return false

func sacar_carpeta():
	esta_guardada = false
	caja_padre = null

func guardar_carpeta():
	esta_guardada = true
	being_held = false
	player_ref = null
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	freeze = true

# --- FUNCIONES CONTROL CARPETA ---
func abrir_carpeta():
	if carpeta_abierta:
		return
	carpeta_abierta = true
	ejecutar_apertura()
	actualizar_vista_documento()

func cerrar_carpeta():

	if not carpeta_abierta:
		return

	carpeta_abierta = false

	# DEVOLVER TODO
	while not hojas_secundarias.is_empty():

		var hoja = hojas_secundarias.pop_back()

		hojas_principales.push_back(hoja)

	actualizar_posiciones_hojas()

	ejecutar_cierre()
	actualizar_vista_documento()

func ejecutar_apertura():
	cerrando = false
	apertura_objetivo = 1.0

func ejecutar_cierre():
	cerrando = true
	apertura_objetivo = 0.0

func calcular_doblez():
	var altura_hojas := 0.0
	var largo_tapa := 1.0
	altura_hojas = grosor_actual
	var distancia_horizontal = 0.15
	var largo_doblez = sqrt(
		pow(altura_hojas, 2) + pow(distancia_horizontal,2)
	)
	return largo_doblez

func calcular_angulo_limite():
	var altura = grosor_actual
	var largo_tapa = 1.0
	var coseno = clamp(
		altura / largo_tapa,
		-1.0,
		1.0
	)
	var angulo = acos(coseno)
	return angulo

func actualizar_apertura_visual():
	if not punto_spawn_A:
		return
	var grosor = grosor_actual

	var angulo_bloqueado = lerp(
		angulo_max,
		deg_to_rad(110),
		grosor
	)
	angulo_total = apertura * angulo_max
	_aplicar_tapa_segmentada()


func _aplicar_tapa_segmentada():
	angulo_total = apertura * angulo_max
	# -----------------------------
	# ABRIENDO
	# -----------------------------
	if not cerrando:
		tapa_1.rotation = (
			base_rot_tapa_1
			+ Vector3(0, -angulo_total, 0)
		)
		tapa_2.rotation = base_rot_tapa_2
		return

	# -----------------------------
	# CERRANDO
	# -----------------------------

	var grosor = clamp( grosor_actual , 0.0 , 1.0 )
	var inicio_doblez = calcular_angulo_doblez()
	if angulo_total >= inicio_doblez:
		tapa_1.rotation = ( base_rot_tapa_1 + Vector3(0, -angulo_total, 0) )
		tapa_2.rotation = base_rot_tapa_2
	else:
		tapa_1.rotation = ( base_rot_tapa_1 + Vector3(0, -inicio_doblez, 0) )
		tapa_2.rotation = ( base_rot_tapa_2 + Vector3(0, inicio_doblez, 0) )
	
func calcular_angulo_doblez():
	if grosor_actual <= 0.0:
		return 0.0
	var altura = grosor_actual
	# distancia horizontal desde pivot
	var largo_segmento = 0.05
	var angulo = atan2( altura , largo_segmento )
	return angulo
# --- FUNCIONES CONTROL CARPETA ---


# --- FUNCIONES GESTION LOGICA HOJAS ---
func posicionar_hoja( hoja , indice: int ):
	var offset = Vector3.DOWN * ( indice * offset_apilamiento )
	hoja.transform = Transform3D.IDENTITY
	hoja.position = offset

func mover_hoja_a_slot(hoja, slot):
	if hoja.get_parent() == slot:
		return
	var global = hoja.global_transform
	if hoja.get_parent():
		hoja.get_parent().remove_child(hoja)
	slot.add_child(hoja)
	hoja.global_transform = global

func reacomodar_hojas_cerradas():
	#var dir_principal = -punto_spawn_A.global_basis.x
	var dir_principal = Vector3.DOWN
	var dir_secundario = Vector3.RIGHT
	var todas = []
	todas.append_array(hojas_secundarias)
	todas.append_array(hojas_principales)
	for i in range(todas.size()):
		var hoja = todas[i]
		posicionar_hoja( hoja, i )

func actualizar_posiciones_hojas():
	var dir_principal = Vector3.DOWN
	var dir_secundario = Vector3.LEFT
	
	for i in range(hojas_principales.size()):
		var hoja = hojas_principales[i]
		posicionar_hoja( hoja , i )

	for i in range(hojas_secundarias.size()):
		var hoja = hojas_secundarias[i]
		posicionar_hoja( hoja , i )

func sacar_hoja_actual():
	if hojas_principales.is_empty():
		return null
	var hoja = hojas_principales.pop_back()
	hoja.estado_fisico = hoja.EstadoFisico.EN_MANO
	hoja.carpeta_padre = null
	var old_rotation = hoja.global_transform
	hoja.reparent(get_tree().current_scene)
	hoja.global_transform = old_rotation
	actualizar_posiciones_hojas()
	actualizar_vista_documento()
	return hoja

func agregar_hoja(hoja):
	if hoja.get_parent():
		hoja.get_parent().remove_child(hoja)
	punto_spawn_A.add_child(hoja)
	hoja.carpeta_padre = self
	hoja.estado_fisico = EstadoFisico.GUARDADO
	hojas_principales.append(hoja)
	actualizar_posiciones_hojas()
	actualizar_vista_documento()

func actualizar_grosor():
	pass
# --- FUNCIONES GESTION LOGICA HOJAS ---



# --- FUNCIONES GESTION VISUAL HOJAS ---
func sincronizar_visual():
	# MOVIMIENTO HOJAS PRINCIPALES
	for i in range(hojas_principales.size()):
		var hoja = hojas_principales[i]
		mover_hoja_a_slot( hoja, punto_spawn_A )
		posicionar_hoja( hoja, i )

	# MOVIMIENTO HOJAS SECUNDARIAS
	for i in range(hojas_secundarias.size()):
		var hoja = hojas_secundarias[i]
		mover_hoja_a_slot( hoja, punto_secundario_A )
		posicionar_hoja( hoja, i )
		
	actualizar_vista_documento()
	actualizar_grosor()

func actualizar_vista_documento():
	if hojas_principales.is_empty():
		documento_texto.text = "Carpeta vacía"
		documento_titulo.text = "Sin documentos"
		return
	#var doc = hojas_principales.back()

func anterior_documento():
	if hojas_secundarias.is_empty():
		return
	var hoja = hojas_secundarias.pop_back()
	hojas_principales.push_back(hoja)
	sincronizar_visual()

func siguiente_documento():
	if hojas_principales.is_empty():
		return
	var hoja = hojas_principales.pop_back()
	hojas_secundarias.push_back(hoja)
	sincronizar_visual()
# --- FUNCIONES GESTION VISUAL HOJAS ---

func on_click(player):
	if being_held:
		return
	if player.holding_folder:
		return
	player.held_folder = self
	player.holding_folder = true
	
	being_held = true
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
	if player_ref.held_folder != null:
		return
	being_held = true
	player_ref = camera
	set_estado_fisico(EstadoFisico.EN_MANO)

func release():
	being_held = false
	if player_ref:
		player_ref.held_folder = null
		player_ref.holding_folder = false
	player_ref = null
	gravity_scale = original_gravity
	set_estado_fisico(EstadoFisico.CAIDA)

func arrastrar(target: Vector3):
	var dir = target - global_position
	linear_velocity = dir * 18.0
	angular_velocity *= 0.85

func lanzar(dir: Vector3, fuerza : float):
	release()
	dir.y *= 0.1
	linear_velocity = dir * fuerza

# --- FUNCIONES DEBUGG ---
func crear_debug_basis():
	var x = MeshInstance3D.new()
	var y = MeshInstance3D.new()
	var z = MeshInstance3D.new()
	var mesh = CylinderMesh.new()
	
	mesh.top_radius = 0.01
	mesh.bottom_radius = 0.01
	mesh.height = 0.5
	
	x.mesh = mesh
	y.mesh = mesh
	z.mesh = mesh
	
	add_child(x)
	add_child(y)
	add_child(z)
	x.position = Vector3.RIGHT * 0.5
	y.position = Vector3.UP * 0.5
	z.position = Vector3.BACK * 0.5

	x.rotation_degrees.z = 90
	z.rotation_degrees.x = 90

	var mat_x = StandardMaterial3D.new()
	mat_x.albedo_color = Color.RED
	x.material_override = mat_x

	var mat_y = StandardMaterial3D.new()
	mat_y.albedo_color = Color.GREEN
	y.material_override = mat_y

	var mat_z = StandardMaterial3D.new()
	mat_z.albedo_color = Color.BLUE
	z.material_override = mat_z

