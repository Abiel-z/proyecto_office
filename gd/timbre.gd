extends RigidBody3D

enum EstadoFisico {
	CAIDA,
	GUARDADA,
	ARRASTRANDO,
	EN_MANO
}


var estado_fisico = EstadoFisico.CAIDA
var being_held = false
var player_ref = null
var original_gravity := 1
@onready var collision = $CollisionShape3D 

func _ready():
	add_to_group("timbres")
	add_to_group("agarrable")
	add_to_group("arrastrable")
	pass

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



func _process(delta):
	pass

func on_click(player):
	if being_held:
		return
	player.held_stamp = self
	
	being_held = true
	player.holding_stamp = true
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
	player_ref.holding_stamp = false
	player_ref.held_stamp = null
	player_ref = null
	gravity_scale = original_gravity
	set_estado_fisico(EstadoFisico.CAIDA)

func arrastrar(target: Vector3):
	var dir = target - global_position
	linear_velocity = dir * 18.0
	angular_velocity *= 0.85
