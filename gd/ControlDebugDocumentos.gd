@tool
extends Control
class_name ControlDebugDocumentos

var textura_base : TextureRect
var detalles_fondo : TextureRect
var textos_fijos : TextureRect
var capa_campos : Control
var capa_dibujos : Control
@export var tiempo_actualizacion := 0.0
@export var intervalo_actualizacion := 5.0
@export var actualizando := false
const bd = preload("res://gd/database_templates_documentos.gd")
const bd_trabajadores = preload("res://gd/database_trabajadores.gd")



var _tipo_documento : TipoDocumento
@export var documento_metadata := {}
@export var tipo_documento : TipoDocumento:
	set(value):
		_tipo_documento = value
		if Engine.is_editor_hint():
			call_deferred("actualizar_visual")
	get:
		return _tipo_documento

func _ready():
	if Engine.is_editor_hint():
		call_deferred("actualizar_visual")

func _process(delta):
	if actualizando :
		if tiempo_actualizacion == null:
			tiempo_actualizacion = 0.0
		tiempo_actualizacion += float(delta)
		if tiempo_actualizacion >= intervalo_actualizacion:
			tiempo_actualizacion = 0.0
			print("actualizando visual")
			actualizar_visual()

func limpiar_campos():
	if capa_campos == null:
		return
	for hijo in capa_campos.get_children():
		hijo.queue_free()

func limpiar_dibujos():
	if capa_dibujos == null:
		return
	for hijo in capa_dibujos.get_children():
		hijo.queue_free()

func actualizar_metadata():
	documento_metadata = {
		# IDENTIFICACION DE LA PERSONA
		"nombre": "Laucha Consarna",
		"rut_id": "7409 - 4",
		"direccion" : "Las Alcantarillas, Ratonia",
		"cargo": "Laucha Jefe",
		"nivel_operativo": "VIII",
		"fecha_ingreso": "28-06-1998",
		"area_trabajo": "Desarrollo",
		# IDENTIFICACION EMPRESA
		"nombre_empresa" : "Valvula",
		"rut_empresa" : "9999 - 9",
		"direccion_empresa" : "Peyehue, Quesington",
		#IDENTIDICACION EVENTO
		"tipo_evento": "AMONESTACION",
		"motivo_evento": "LLEGADA TARDE",
		"resultado_evento": "AMONESTACION",
		"fecha_evento": "XX - XX - XXXX",
		"gravedad_evento": "2"
		}
	
func actualizar_visual():
	textura_base = get_node_or_null("ControlVisualDocumentos/base")
	detalles_fondo = get_node_or_null("ControlVisualDocumentos/detalles_fondo")
	textos_fijos = get_node_or_null("ControlVisualDocumentos/textos_fijos")
	capa_campos = get_node_or_null("ControlVisualDocumentos/textos_dinamicos")
	capa_dibujos = get_node_or_null("ControlVisualDocumentos/dibujos_dinamicos")
	
	actualizar_metadata()
	
	if not textura_base:
		print("NO ENCONTRE BASE")
		return

	if not tipo_documento:
		return
	
	if textura_base == null:
		return

	if detalles_fondo == null:
		return

	if textos_fijos == null:
		return
	
	if capa_campos == null:
		return

	if capa_dibujos == null:
		print("CAPA DIBUJOS NULL")
		return
	
	if tipo_documento == null:
		return
	
	
	
	if not is_node_ready():
		return

	if tipo_documento == null:
		return

	limpiar_campos()
	limpiar_dibujos()
	
	if tipo_documento.imagenes.size() >= 1:
		var empresa_debug : Empresa = DatabaseEmpresas.EMPRESAS.VALVULA
		for imagen in tipo_documento.imagenes:
			var texture_rect := TextureRect.new()
			match imagen.id:
				"logo": texture_rect.texture = empresa_debug.logo_empresa
				"timbre" : texture_rect.texture = empresa_debug.timbre_empresa
				"firma_subject" : texture_rect.texture = empresa_debug.firma
				"firma_owner" :  texture_rect.texture = empresa_debug.firma
			print("CONFIGURANDO ", imagen.id)
			
			#texture_rect.texture = imagen.textura
			texture_rect.position = imagen.posicion
			texture_rect.size = imagen.size
			capa_dibujos.add_child(texture_rect)

	
	if capa_dibujos:
		capa_dibujos.dibujos = tipo_documento.dibujos
		capa_dibujos.call_deferred("actualizar_visual")
	
	# -------------------------
	# TEXTURAS
	# -------------------------
	textura_base.texture = tipo_documento.textura_base
	detalles_fondo.texture = tipo_documento.detalles_fondo
	textos_fijos.texture = tipo_documento.textos_fijos

	# -------------------------
	# CAMPOS
	# -------------------------
	for campo in tipo_documento.campos:

		var valor = _resolver_valor(campo) 
		if campo.id == "tipo_evento":
			print(" --- CAMPO tipo_evento ENCONTRADO")
			print(valor)
		crear_campo(campo,valor)
	

#func  _draw():
	#for dibujo in tipo_documento.dibujos:
		#if dibujo is RectanguloDibujo:
			#dibujar_rectangulo(dibujo)
	
func dibujar_rectangulo(dibujo: RectanguloDibujo):
	print("DIBUJOS EN DOCUMENTO : " , tipo_documento.dibujos)
	capa_dibujos.dibujos = tipo_documento.dibujos
	capa_dibujos.actualizar_visual()
	#draw_rect(Rect2(dibujo.posicion,dibujo.tamaño),dibujo.color_relleno)
	#draw_rect(Rect2(dibujo.posicion,dibujo.tamaño),dibujo.color_borde,false, dibujo.grosor_borde)


func _resolver_valor(campo: CampoDocumento):
	var database_templates = bd.new()
	database_templates.cargar_basedatos()
	
	if campo.fuente == CampoDocumento.FuenteCampo.TEMPLATE:
		if database_templates == null :
			return ""
		if database_templates.templates == null: 
			return ""
		var group_id = tipo_documento.template_id
		var template_group = database_templates.templates.get(group_id)
		var template = template_group.get(campo.template_parrafo, "")
		var style = database_templates.styles.get(campo.color_variable, "{texto}")
		template = DocumentRenderer.render_parrafo(template, documento_metadata, style)
		return template

	return documento_metadata.get(campo.id, campo.texto_default)

func crear_campo(campo: CampoDocumento, valor):
	var control: Control

	if campo.bbcode_activo:
		var richlabel = RichTextLabel.new()
		richlabel.bbcode_enabled = campo.bbcode_activo
		control = richlabel
		control.add_theme_font_size_override("normal_font_size",campo.font_size)
		control.add_theme_font_size_override("Normal_Font_Size",campo.font_size)
		
		control.add_theme_color_override("default_color", campo.color)
		control.text = valor
		#control.text(valor)

	else:
		control = Label.new()
		control.add_theme_font_size_override("font_size",campo.font_size)
		control.add_theme_color_override("font_color", campo.color)
		control.horizontal_alignment = campo.alineacion_horizontal
		control.vertical_alignment = campo.alineacion_vertical
		control.text = str(valor)
	
	
	control.position = campo.posicion
	control.custom_minimum_size = campo.size
	control.size = campo.size
	control.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART


	capa_campos.add_child(control)
	control.reset_size()
