extends Node3D

signal boton_presionado()

@onready var anim : AnimationPlayer = $modelo/AnimationPlayer
@onready var luz : OmniLight3D = $modelo/ampolleta/luz
# Called when the node enters the scene tree for the first time.
func _ready():
	luz.light_energy = 0.0
	add_to_group("botones")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func encender_luz(tiempo: float, color: Color):
	cambiar_color_luz(color)
	luz.light_energy = 1.0
	await get_tree().create_timer(tiempo).timeout
	apagar_luz()

func cambiar_color_luz(color: Color):
	luz.light_color = color

func apagar_luz():
	luz.light_energy = 0.0

func on_click(player):
	anim.play("presionar")
	await anim.animation_finished
	boton_presionado.emit()
	print("señal emitida")
	anim.play_backwards("presionar",2)
	#punto_entrega.revisar()
	
func interactuar():
	anim.play("presionar")
	await anim.animation_finished
	boton_presionado.emit()
	print("señal emitida")
	anim.play_backwards("presionar",2)
	#punto_entrega.revisar()
