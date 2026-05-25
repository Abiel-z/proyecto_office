extends RigidBody3D

var peso_arrastre := 20.0
var multiplicador_por_arrastre := 5.0
# Called when the node enters the scene tree for the first time.
func _ready():
	center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
	center_of_mass = Vector3(0,-0.15,0)
	add_to_group("superficie")
	add_to_group("arrastrable")
	angular_damp = 8.0
	linear_damp = 5.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func arrastrar(target: Vector3):

	# Direccion hacia el target
	var dir = (target - global_position).normalized()

	# Fuerza debug simple
	var fuerza_debug := 5.0

	# Aplicar fuerza
	apply_force(dir * fuerza_debug)
