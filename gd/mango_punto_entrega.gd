extends StaticBody3D

@onready var puerta = $puerta
@onready var marker_up = $"../posicion_up"
@onready var marker_down = $"../posicion_down"
var puerta_cerrada = false
var valor_objetivo := 0.0
var valor_actual := 0.0

# Called when the node enters the scene tree for the first time.
func _ready():

	add_to_group("mango")
	add_to_group("agarrable")


# Called every frame. 'delta' is the elapsed time since the previous frame.
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

func arrastrar(delta_y):
	valor_objetivo += delta_y * 0.005
	valor_objetivo = clamp( valor_objetivo , 0.0 , 1.0 )
