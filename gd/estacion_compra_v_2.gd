extends StaticBody3D

signal compra_realizada(objeto : String , cantidad : int )
signal compra_rechazada()

const CATEGORIAS = {

	"MOBILIARIO": {
		"icono": preload("res://aseprite/icono_mobiliario.png"),

		"items": [
			{
				"id": "archivador",
				"precio": 40,
				"nombre" : "ARCHIVADOR",
				"descripcion" : "GUARDA LOS DOCUMENTOS PARA NO PERDERLOS",
				"icono": preload("res://aseprite/icono_archivador.png")
			},

			{
				"id": "lampara",
				"precio": 20,
				"nombre" : "LAMPARA",
				"descripcion" : "ILUMINA TU LUGAR DE TRABAJO",
				"icono": preload("res://aseprite/icono_lampara.png")
			},
			
			{
				"id": "mesa",
				"precio": 20,
				"nombre" : "MESA",
				"descripcion" : "SUPERFICIE PARA UBICAR OBJETOS Y CARPETAS",
				"icono": preload("res://aseprite/icono_mesa.png")
			}
		]
	},

	"OBJ_OFICINA": {
		"icono": preload("res://aseprite/icono_oficina.png"),

		"items": [
			{
				"id": "carpeta",
				"precio": 30,
				"nombre" : "CARPETA",
				"descripcion" : "ORGANIZA Y ENTREGA DOCUMENTOS",
				"icono": preload("res://aseprite/imagen_carpeta.png")
			},

			{
				"id": "timbre",
				"precio": 100,
				"nombre" : "TIMBRE",
				"descripcion" : "TIMBRA DOCUMENTOS PARA AUMENTAR SU VALOR",
				"icono": preload("res://aseprite/icono_timbre.png")
			},
			
			{
				"id": "corchetera",
				"precio": 500,
				"nombre" : "CORCHETERA",
				"descripcion" : "UNE DOCUMENTOS PARA EVITAR PERDERLOS",
				"icono": preload("res://aseprite/icono_corchetera.png")
			}
		]
	},

	"INVESTIGACION": {
		"icono": preload("res://aseprite/icono_investigacion.png"),

		"items": [
			{
				"id": "timbrador_auto",
				"precio": 120,
				"nombre" : "TIMBRADOR AUTOMATICO",
				"descripcion" : "TIMBRA AUTOMATICAMENTE LAS HOJAS INGRESADAS",
				"icono": preload("res://aseprite/icono_timbre.png")
			},
			{
				"id": "organizador_carpetas",
				"precio": 120,
				"nombre" : "ORGANIZADOR DE CARPETAS",
				"descripcion" : "TIMBRA AUTOMATICAMENTE LAS HOJAS INGRESADAS",
				"icono": preload("res://aseprite/imagen_carpeta.png")
			},
			{
				"id": "corchetera_auto",
				"precio": 120,
				"nombre" : "CORCHETERA AUTOMATICA",
				"descripcion" : "TIMBRA AUTOMATICAMENTE LAS HOJAS INGRESADAS",
				"icono": preload("res://aseprite/icono_corchetera.png")
			}
		]
	}
}

var categoria_index := 0
var item_index := 0
var nombres_categorias := CATEGORIAS.keys()

@onready var pantalla2 = $modelo/pantalla2
@onready var pantalla = $modelo/pantalla
@onready var viewport = $SubViewport
@onready var area_deteccion = $area_deteccion

@onready var teclado = $teclado_panel_compra
@onready var boton_rojo = $boton_aceptar

@onready var collision_boton_arriba = $collision_boton_arriba
@onready var collision_boton_abajo = $collision_boton_abajo
@onready var collision_boton_izquierda = $collision_boton_izquierda
@onready var collision_boton_derecha = $collision_boton_derecha

@onready var slot_categoria_central = $SubViewport/Control/container_categorias/vcontainer/slot_central
@onready var slot_categoria_superior = $SubViewport/Control/container_categorias/vcontainer/slot_superior
@onready var slot_categoria_inferior = $SubViewport/Control/container_categorias/vcontainer/slot_inferior

@onready var slot_item_central = $SubViewport/Control/container_categorias/container_items/items_activos/item_central
@onready var slot_item_izquierda = $SubViewport/Control/container_categorias/container_items/items_activos/item_izquierda
@onready var slot_item_derecha = $SubViewport/Control/container_categorias/container_items/items_activos/item_derecha

@onready var textos_nombre_item = $SubViewport/Control/container_categorias/container_items/items_descripcion/control_textos/vcontainer/nombre
@onready var textos_descripcion_item = $SubViewport/Control/container_categorias/container_items/items_descripcion/control_textos/vcontainer/descripcion


# --- FUNCIONES DE EJECUCION ---
func _ready():
	teclado.boton_arriba_pressed.connect(_on_boton_arriba_press)
	teclado.boton_abajo_pressed.connect(_on_boton_abajo_press)
	teclado.boton_izquierda_pressed.connect(_on_boton_izquierda_press)
	teclado.boton_derecha_pressed.connect(_on_boton_derecha_press)
	boton_rojo.boton_presionado.connect(_on_boton_aceptar_press)
	aplicar_textura_pantalla()
	actualizar_ui()

func _on_boton_arriba_press():
	cambiar_categoria(-1)
func _on_boton_abajo_press():
	cambiar_categoria(1)
func _on_boton_izquierda_press():
	cambiar_item(-1)
func _on_boton_derecha_press():
	cambiar_item(1)

func _on_boton_aceptar_press():
	var item = item_actual()
	var precio = item["precio"]
	var dinero_actual = obtener_dinero_area()
	if dinero_actual >= precio:
		compra_realizada.emit(item["id"], 1)
		print("COMPRA REALIZADA")
		compra_realizada.emit(item["id"], 1)
		ControllerSpawnerTienda.spawnear_objeto(item["id"], 1)
	else:
		compra_rechazada.emit()
		print("COMPRA RECHAZADA")

func actualizar_textos():
	var item = item_actual()
	
	textos_nombre_item.text = item["nombre"]
	textos_descripcion_item.text = item["descripcion"]


func obtener_dinero_area():
	var total := 0
	var cuerpos = area_deteccion.get_overlapping_bodies()
	for cuerpo in cuerpos:
		if cuerpo.is_in_group("monedas"):
			total += cuerpo.valor
	print("MONEDAS EN AREA : " , total)
	return total

func _process(delta):
	pass
# --- FUNCIONES DE EJECUCION --- 

func categoria_actual():
	return nombres_categorias[categoria_index]

func items_actuales():
	return CATEGORIAS[categoria_actual()]["items"]

func item_actual():
	return items_actuales()[item_index]

func categoria_visible_data(offset : int):
	var size = nombres_categorias.size()
	var index = posmod(categoria_index + offset,size)
	var nombre = nombres_categorias[index]
	return CATEGORIAS[nombre]

func cambiar_categoria(dir):
	categoria_index = posmod( categoria_index + dir, nombres_categorias.size() )
	item_index = 0
	actualizar_ui()

func cambiar_item(dir):
	item_index = posmod( item_index + dir, items_actuales().size() )
	actualizar_ui()

func item_visible(offset : int):
	var lista = items_actuales()
	var index = posmod( item_index + offset, lista.size() )
	return lista[index]

func actualizar_ui():
	actualizar_iconos()
	actualizar_textos()

func actualizar_iconos():
	slot_categoria_superior.texture = categoria_visible_data(-1)["icono"]
	slot_categoria_central.texture = categoria_visible_data(0)["icono"]
	slot_categoria_inferior.texture = categoria_visible_data(1)["icono"]
	
	slot_item_izquierda.texture = item_visible(-1)["icono"]
	slot_item_central.texture = item_visible(0)["icono"]
	slot_item_derecha.texture = item_visible(1)["icono"]
	
func aplicar_textura_pantalla():
	await get_tree().process_frame
	#await RenderingServer.frame_post_draw
	var texture = viewport.get_texture()
	
	var material = StandardMaterial3D.new()
	
	material.albedo_texture = texture
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.cull_mode = BaseMaterial3D.CULL_FRONT
	
	material.emission_enabled = true
	material.emission_texture = texture
	material.emission = Color(0.8, 1.0, 0.9)
	material.emission_energy_multiplier = 4.0
	
	material.uv1_scale = Vector3(-1, 1, 1)
	
	pantalla.material_override = material
	pantalla2.material_override = material


