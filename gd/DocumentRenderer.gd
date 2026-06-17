extends Node
class_name DocumentRenderer

static func render_parrafo(template: String, data: Dictionary, style) -> String:
	var text = template
	for key in data.keys():
		var valor = style.replace("{texto}", str(data[key]))
		text = text.replace("{id:%s}" % key, valor)
	return text
