extends Resource
class_name TipoDocumento

@export var id : String
@export var template_id : String
@export var textura_base : Texture2D
@export var mascara_borde : Texture2D
@export var textos_fijos : Texture2D
@export var detalles_fondo : Texture2D

@export var campos : Array[CampoDocumento]
@export var dibujos : Array[DibujoDocumento]

@export var color_papel : Color
@export var tipo_timbre : String
@export var posiciones_timbres : Array[Vector2]
@export var posiciones_firmas : Array[Vector2]
@export var cantidad_max_timbres := 3
