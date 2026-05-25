extends StaticBody3D

@onready var cajon = $modelo_cajon
@onready var colision_cajon = $colision_cajon
@onready var mango = $modelo_mango
@onready var colision_mango = $colision_mango

var abierto := false

@onready var posicion_cerrada = $punto_interior
@onready var posicion_abierta = $punto_exterior

var direccion_movimiento := Vector3.FORWARD
var puerta_cerrada = false
var valor_objetivo := 0.0
var valor_actual := 0.0


@export var sensibilidad := 0.005
@export var distancia_apertura := 0.5
@export var velocidad := 8.0

func _ready():
	add_to_group("mango")
	add_to_group("agarrable")

func _process(delta):
	valor_actual = lerp(valor_actual, valor_objetivo, 0.1)
	if valor_actual >= 0.95:
		puerta_cerrada = true
	else:
		puerta_cerrada = false
	
	mover_cajon()

func mover_cajon():
	
	mango.global_position.z = lerp(
	posicion_cerrada.global_position.z,
	posicion_abierta.global_position.z,
	valor_actual
)

	colision_mango.global_position.z = lerp(
	posicion_cerrada.global_position.z,
	posicion_abierta.global_position.z,
	valor_actual
)

	cajon.global_position.z = lerp(
	posicion_cerrada.global_position.z,
	posicion_abierta.global_position.z,
	valor_actual
)

	colision_cajon.global_position.z = lerp(
	posicion_cerrada.global_position.z,
	posicion_abierta.global_position.z,
	valor_actual
)

func interpretar_arrastre(delta_input: Vector2) -> float:
	return (
		delta_input.x * abs(direccion_movimiento.x) +
		delta_input.y * abs(direccion_movimiento.y)
	)

func arrastrar(delta_input):
	valor_objetivo += delta_input.x * sensibilidad
	valor_objetivo = clamp( valor_objetivo , 0.0 , 1.0 )
	
