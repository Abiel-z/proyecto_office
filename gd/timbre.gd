extends RigidBody3D

var being_held = false
var camera_ref : Camera3D
var original_gravity := 1
@onready var collision = $CollisionShape3D 

func _ready():
	add_to_group("timbres")
	add_to_group("agarrable")
	pass

func _process(delta):
	pass

func grab(camera):
	being_held = true
	camera_ref = camera
	gravity_scale = 0
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	freeze = true
	collision.disabled = true

func release():
	being_held = false
	camera_ref = null
	gravity_scale = original_gravity
	freeze = false
	collision.disabled = false
