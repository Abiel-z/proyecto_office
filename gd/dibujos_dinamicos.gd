@tool
extends Control

var dibujos : Array = []

func _draw():
	for dibujo in dibujos:
		draw_rect(
			Rect2(dibujo.posicion, dibujo.tamaño),
			dibujo.color_relleno
		)

		draw_rect(
			Rect2(dibujo.posicion, dibujo.tamaño),
			dibujo.color_borde,
			false,
			dibujo.grosor_borde
		)
		
func actualizar_visual():
	queue_redraw()
