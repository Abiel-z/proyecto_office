extends RigidBody3D

@export var altura_seleccion := 0.15
@export var velocidad_animacion := 8.0
@export var offset_posicion := Vector3.ZERO
@export var offset_rotacion := Vector3.ZERO
@onready var debugg_marker_a : Marker3D = $slots_container/slot_1/A
@onready var debugg_marker_b : Marker3D = $slots_container/slot_1/B
@onready var collision = $CollisionShape3D

var slots : Array = []
var slots_maximos : int = 10
var carpetas : Array[Node3D] = []

var dragging := false
var hold_point : Marker3D

var indice_seleccionado := 0

func _ready():
	add_to_group("cajas")
	add_to_group("agarrable")
	crear_debug_basis()
	for slot_node in $slots_container.get_children():
		print("POSICION SLOT :", slot_node.position)
		var slot_data = {
			"nodo": slot_node,
			"ocupado": false,
			"carpeta": null
		}
		slots.append(slot_data)

func _physics_process(delta):
	actualizar_carpetas()
	if dragging and hold_point != null:
		global_position = global_position.lerp(
			hold_point.global_position,
			delta * 8.0
		)

		# opcional:
		rotation.y = lerp_angle(
			rotation.y,
			hold_point.global_rotation.y,
			delta * 8.0
		)


func _input(event):
	if carpetas.is_empty():
		return
	# Scroll abajo
	if event.is_action_pressed("scroll_abajo"):
		indice_seleccionado += 1
		indice_seleccionado = wrapi(indice_seleccionado, 0, carpetas.size())
	# Scroll arriba
	if event.is_action_pressed("scroll_arriba"):
		indice_seleccionado -= 1
		indice_seleccionado = wrapi(indice_seleccionado, 0, carpetas.size())


func actualizar_carpetas():
	for slot in slots:
		var carpeta = slot["carpeta"]
		if carpeta == null:
			continue
		if not is_instance_valid(carpeta):
			slot["carpeta"] = null
			slot["ocupado"] = false
			continue
		if carpeta.estado_fisico != carpeta.EstadoFisico.GUARDADO:
			continue
		carpeta.global_transform = slot["nodo"].global_transform

func agregar_carpeta(carpeta : Node3D) -> bool:

	var slot = obtener_slot_libre()

	if slot == null:
		return false

	var slot_transform = slot["nodo"].global_transform

	var ajuste_basis = Basis.from_euler(
		Vector3(
			deg_to_rad(offset_rotacion.x),
			deg_to_rad(offset_rotacion.y),
			deg_to_rad(offset_rotacion.z)
		)
	)

	var target_basis = slot_transform.basis * ajuste_basis

	var target_position = (
		slot_transform.origin
		+ slot_transform.basis * offset_posicion
	)

	# =========================
	# DESACTIVAR COLISIONES
	# =========================

	carpeta.collision.disabled = true

	# =========================
	# CONFIGURAR SLOT
	# =========================

	slot["ocupado"] = true
	slot["carpeta"] = carpeta

	carpetas.append(carpeta)

	carpeta.caja_padre = self
	carpeta.slot_actual = slot

	carpeta.estado_fisico = carpeta.EstadoFisico.GUARDADO

	# =========================
	# MOVER SUAVEMENTE
	# =========================

	while true:

		carpeta.global_position = carpeta.global_position.lerp(
			target_position,
			0.2
		)

		carpeta.global_basis = carpeta.global_basis.slerp(
			target_basis,
			0.2
		)

		var distancia = carpeta.global_position.distance_to(
			target_position
		)

		if distancia < 0.01:
			break

		await get_tree().physics_frame

	# =========================
	# SNAP FINAL
	# =========================

	carpeta.global_position = target_position
	carpeta.global_basis = target_basis

	# =========================
	# REACTIVAR COLISIONES
# =========================

	carpeta.collision.disabled = false

	return true

func quitar_carpeta(carpeta):
	var slot = carpeta.slot_actual
	if slot != null:
		slot["carpeta"] = null
		slot["ocupado"] = false
	carpeta.slot_actual = null
	carpeta.caja_padre = null
	carpetas.erase(carpeta)
	carpeta.estado_fisico = carpeta.EstadoFisico.SOSTENIDO

func obtener_carpeta_seleccionada() -> Node3D:
	if carpetas.is_empty():
		return null
	return carpetas[indice_seleccionado]

func obtener_slot_libre():
	for slot in slots:
		if not slot["ocupado"]:
			return slot
	return null

# --- INICIO FUNCIONES MOVIMIENTO CAJA ---
func start_drag(point: Marker3D):
	dragging = true
	hold_point = point
	collision.disabled = true
	for carpeta in carpetas:
		carpeta.collision.disabled = true
	self.freeze = true
	self.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC

func stop_drag():
	dragging = false
	hold_point = null
	collision.disabled = false
	for carpeta in carpetas:
		carpeta.collision.disabled = false
	self.freeze = false
# --- FIN FUNCIONES MOVIMIENTO CAJA ---

func crear_debug_basis():

	var x = MeshInstance3D.new()
	var y = MeshInstance3D.new()
	var z = MeshInstance3D.new()

	var mesh = CylinderMesh.new()
	mesh.top_radius = 0.01
	mesh.bottom_radius = 0.01
	mesh.height = 1

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
