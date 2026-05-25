extends StaticBody3D

@onready var puerta = $puerta
@onready var marker_up = $"../posicion_up"
@onready var marker_down = $"../posicion_down"
@export var sensibilidad := 0.005
var puerta_cerrada = false
var valor_objetivo := 0.0
@export var valor_actual := 0.0

var velocidad := 0.0
@export var friccion := 8.0
@export var fuerza_arrastre := 0.02

func _ready():
	add_to_group("mango")
	add_to_group("agarrable")
	add_to_group("arrastrable")

func _process(delta):
	
	valor_actual = lerp(valor_actual, valor_objetivo, 0.1)
	if valor_actual >= 0.95:
		puerta_cerrada = true
	else:
		puerta_cerrada = false
	
	global_position.y = lerp(
	marker_up.global_position.y,
	marker_down.global_position.y,
	valor_actual
)
	puerta.global_position.y = lerp(
	marker_up.global_position.y,
	marker_down.global_position.y,
	valor_actual
)

func empezar_arrastre(player):
	pass

func arrastrar(target: Vector3):

	var altura_total = (
		marker_down.global_position.y
		- marker_up.global_position.y
	)

	var altura_actual = (
		target.y
		- marker_up.global_position.y
	)

	valor_objetivo = altura_actual / altura_total
	valor_objetivo = clamp(valor_objetivo, 0.0, 1.0)
