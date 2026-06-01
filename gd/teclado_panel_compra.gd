extends RigidBody3D

signal boton_arriba_pressed()
signal boton_abajo_pressed()
signal boton_izquierda_pressed()
signal boton_derecha_pressed()

@onready var colision_boton_arriba = $collision_boton_arriba 
@onready var modelo_boton_arriba = $panel_botones_compras/boton_arriba

@onready var colision_boton_abajo = $collision_boton_abajo 
@onready var modelo_boton_abajo = $panel_botones_compras/boton_abajo

@onready var colision_boton_izquierda = $collision_boton_izquierda 
@onready var modelo_boton_izquierda = $panel_botones_compras/boton_izquierda

@onready var colision_boton_derecha = $collision_boton_derecha
@onready var modelo_boton_derecha = $panel_botones_compras/boton_derecha
 
@onready var animaciones = $panel_botones_compras/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_click(player):
	var shape = player.get_clicked_shape()
	if shape == null:
		return
	match shape.name:
		"collision_boton_arriba":
			print("collision_boton_arriba")
			animaciones.play("presionar_izquierda")
			await animaciones.animation_finished
			emit_signal("boton_arriba_pressed")
			animaciones.play_backwards("presionar_izquierda")
			
		"collision_boton_abajo":
			print("collision_boton_abajo")
			animaciones.play("presionar_derecha")
			await animaciones.animation_finished
			emit_signal("boton_abajo_pressed")
			animaciones.play_backwards("presionar_derecha")
			
		"collision_boton_izquierda":
			print("collision_boton_izquierda")
			animaciones.play("presionar_abajo")
			await animaciones.animation_finished
			emit_signal("boton_izquierda_pressed")
			animaciones.play_backwards("presionar_abajo")
			
		"collision_boton_derecha":
			print("collision_boton_derecha")
			animaciones.play("presionar_arriba")
			await animaciones.animation_finished
			emit_signal("boton_derecha_pressed")
			animaciones.play_backwards("presionar_arriba")
			
