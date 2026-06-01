extends RigidBody3D

enum EstadoFisico {
	CAIDA,
	GUARDADA,
	ARRASTRANDO,
	EN_MANO
}

var estado_fisico = EstadoFisico.CAIDA
var player_ref = null
var multiplicador_por_arrastre := 1.0
var original_gravity = 1.0
var valor := 10

@onready var collision = $CollisionShape3D

var being_held = false

func _ready():
	add_to_group("monedas")
	add_to_group("arrastrable")
	add_to_group("agarrable")
	mass = 0.2
	set_estado_fisico(EstadoFisico.CAIDA)

func _physics_process(delta):
	if being_held and player_ref != null:
		estado_fisico = EstadoFisico.EN_MANO

func set_estado_fisico(nuevo_estado: EstadoFisico):
	if estado_fisico == nuevo_estado:
		return
	estado_fisico = nuevo_estado
	_actualizar_estado_fisico()
  
func _actualizar_estado_fisico():
	match estado_fisico:
		EstadoFisico.GUARDADA:
			freeze = true
			collision.disabled = true
			gravity_scale = 0
			collision_layer = 0
			collision_mask = 0
			linear_velocity = Vector3.ZERO
			angular_velocity = Vector3.ZERO

		EstadoFisico.CAIDA:
			freeze = false
			collision.disabled = false
			being_held = false
			gravity_scale = original_gravity
			collision_layer = 1
			collision_mask = 1
		
		EstadoFisico.ARRASTRANDO:
			freeze = false
			gravity_scale = original_gravity
			collision_layer = 1
			collision_mask = 1

		EstadoFisico.EN_MANO:
			freeze = false
			collision.disabled = true
			gravity_scale = 0
			collision_layer = 0
			collision_mask = 0
			linear_velocity = Vector3.ZERO
			angular_velocity = Vector3.ZERO

func on_click(player):
	if being_held:
		return
	player.held_monedas.append(self)
	
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
	being_held = true
	player_ref = camera
	set_estado_fisico(EstadoFisico.EN_MANO)

func release():
	being_held = false
	player_ref = null
	gravity_scale = original_gravity
	set_estado_fisico(EstadoFisico.CAIDA)

func lanzar(dir: Vector3, fuerza : float):
	release()
	dir.y *= 0.2
	linear_velocity = dir * fuerza
	# spin opcional
	angular_velocity = Vector3(
		randf_range(-4.0, 4.0),
		randf_range(-4.0, 4.0),
		randf_range(-4.0, 4.0)
	)

func arrastrar(target: Vector3):
	var dir = target - global_position
	linear_velocity = dir * 18.0
	angular_velocity = Vector3.ZERO
	if player_ref == null:
		return
	# posición del player/cámara
	var player_pos = player_ref.global_position
	# mirar hacia el player
	var look_dir = (player_pos - global_position).normalized()
	# construimos una base que mire al player
	var basis_objetivo = Basis().looking_at(look_dir, Vector3.RIGHT)
	# si tu moneda está “mal orientada”, ajusta este offset
	#basis_objetivo = basis_objetivo.rotated(Vector3.RIGHT, rad_to_deg(90))
	# suavizado
	global_basis = global_basis.slerp(basis_objetivo, 0.25)
