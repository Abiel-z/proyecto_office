extends RigidBody3D

enum EstadoFisico {
	LIBRE,
	GUARDADO,
	SOSTENIDO
}
enum EstadoRevision {
		PENDIENDE,
		APROVADA,
		RECHAZADA
}
var errores_detectados : Array = []

var estado_fisico : EstadoFisico = EstadoFisico.LIBRE:
	set(value):
		estado_fisico = value
		actualizar_estado_fisico()
		
		
		
var siendo_rotada = false 
var carpeta_abierta: bool = false
var cerrando := false
var esta_guardada : bool = false
var being_held = false
var camera_ref = null
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

@onready var documento_titulo = $titulo_documento
@onready var documento_texto = $modelo/tapa_1/tapa_2/texto_documento

@onready var punto_spawn_A = $modelo/base/PUNTO_A
@onready var punto_secundario_A = $modelo/tapa_1/tapa_2/PUNTO_A

#var hojas_apiladas : Array = []
#var indice_actual: int = 0
var hojas_principales : Array = []
var hojas_secundarias : Array = []

var offset_apilamiento : float = 0.01
var grosor_actual : float  = 0.0
# --- FUNCIONES DE EJECUCION --- 
func _ready():
	add_to_group("carpetas")
	add_to_group("agarrable")
	crear_debug_basis()
	base_rot_tapa_1 = tapa_1.rotation
	base_rot_tapa_2 = tapa_2.rotation
	actualizar_apertura_visual()

func _physics_process(delta):
	grosor_actual = ( hojas_principales.size() + hojas_secundarias.size() ) * 0.01
	punto_guardado.position.x = grosor_actual
	
	if being_held and camera_ref:
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
# --- FUNCIONES DE EJECUCION --- 

# --- FUNCIONES DE ESTADO ---
func actualizar_estado_fisico():
	match estado_fisico:

		EstadoFisico.GUARDADO:
			freeze = true
			gravity_scale = 0
			collision_layer = 1
			collision_mask = 1
			linear_velocity = Vector3.ZERO
			angular_velocity = Vector3.ZERO
			
		EstadoFisico.SOSTENIDO:
			freeze = true
			freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
			gravity_scale = 0
			collision_layer = 0
			collision_mask = 0
			linear_velocity = Vector3.ZERO
			angular_velocity = Vector3.ZERO
			
		EstadoFisico.LIBRE:
			freeze = false
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
	camera_ref = null
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

		hojas_principales.push_front(hoja)

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

# --- FUNCIONES MOSTRADO DOCUMENTOS ---
func actualizar_vista_documento():

	if hojas_principales.is_empty():

		documento_texto.text = "Carpeta vacía"
		documento_titulo.text = "Sin documentos"
		return

	var doc = hojas_principales[0]

	#documento_titulo.text = doc.nombre_documento
	#documento_texto.text = doc.texto_documento

func anterior_documento():

	if hojas_secundarias.is_empty():
		return
	# SACAR DEL FRENTE SECUNDARIO
	var hoja = hojas_secundarias.pop_front()
	# VOLVER AL FRENTE PRINCIPAL
	hojas_principales.push_front(hoja)

	actualizar_vista_documento()
	actualizar_posiciones_hojas()

func siguiente_documento():
	if hojas_principales.is_empty():
		return
	# SACAR DEL FRENTE PRINCIPAL
	var hoja = hojas_principales.pop_front()
	# PONER AL FRENTE SECUNDARIO
	hojas_secundarias.push_front(hoja)

	actualizar_vista_documento()
	actualizar_posiciones_hojas()
# --- FUNCIONES MOSTRADO DOCUMENTOS ---

# --- FUNCIONES CONTROL DOCUMENTOS ---
func posicionar_hoja( hoja, slot: Marker3D, indice: int, direccion_apilado: Vector3):
	var offset = direccion_apilado * ( indice * offset_apilamiento )
	# COPIAR ROTACION
	#hoja.global_rotation = slot.global_rotation
	
	if hoja.get_parent() != slot:
		var old_rotation = hoja.global_rotation
		if hoja.get_parent():
			hoja.get_parent().remove_child(hoja)
		slot.add_child(hoja)
		hoja.global_rotation = old_rotation
		
	hoja.position = offset
	# AHORA POSICION LOCAL
	hoja.rotation = Vector3.ZERO

func reacomodar_hojas_cerradas():
	var dir_principal = -punto_spawn_A.global_basis.x
	var todas = []
	todas.append_array(hojas_secundarias)
	todas.append_array(hojas_principales)
	for i in range(todas.size()):
		var hoja = todas[i]
		posicionar_hoja(
			hoja,
			punto_spawn_A,
			i,
			dir_principal
		)

func actualizar_posiciones_hojas():

	var dir_principal = -punto_spawn_A.global_basis.x
	var dir_secundario = punto_secundario_A.global_basis.x

	# -----------------------------
	# PRINCIPALES
	# -----------------------------
	for i in range(hojas_principales.size()):

		var hoja = hojas_principales[i]

		posicionar_hoja(
			hoja,
			punto_spawn_A,
			i,
			dir_principal
		)

	# -----------------------------
	# SECUNDARIAS
	# -----------------------------
	for i in range(hojas_secundarias.size()):

		var hoja = hojas_secundarias[i]

		posicionar_hoja(
			hoja,
			punto_secundario_A,
			i,
			dir_secundario
		)

func sacar_hoja_actual():
	if hojas_principales.is_empty():
		return null
	var hoja = hojas_principales.pop_front()
	hoja.estado_fisico = hoja.EstadoFisico.EN_MANO
	hoja.carpeta_padre = null
	var old_rotation = hoja.global_rotation
	hoja.reparent(get_tree().current_scene)
	hoja.global_rotation = old_rotation
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
# --- FUNCIONES CONTROL DOCUMENTOS ---

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

