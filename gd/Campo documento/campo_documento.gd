extends Resource
class_name CampoDocumento

enum FuenteCampo {
	METADATA,
	TEMPLATE
}

@export var id : String
@export var fuente : FuenteCampo
@export var template_parrafo : String
@export var posicion : Vector2
@export var color : Color
@export var color_variable : String
@export var texto_default : String
@export var size : Vector2 = Vector2(200,10)
@export var capa : String
@export var visible : bool
@export var editable : bool
@export var font_size : float = 15.0
@export var clip_content : bool = false
@export var bbcode_activo : bool = false
@export var multilinea : bool = false
@export var alineacion_horizontal : HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT
@export var alineacion_vertical : VerticalAlignment = VERTICAL_ALIGNMENT_TOP
@export var autowrap : bool = true
