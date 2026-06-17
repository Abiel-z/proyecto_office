extends Node

var templates = {}
var styles = {}
var var_tam = 15

func _ready():
	cargar_basedatos()

func cargar_basedatos():
	cargar_templates()
	cargar_styles()

func cargar_templates():
	templates = {
	"contrato_base" : {
		"parrafo_1" : """Conste por el presente documento que el trabajador {id:nombre}, identificado mediante RUT {id:rut_id}, con domicilio registrado en {id:direccion}, ha sido incorporado a los registros administrativos de la organización."""
		,
		"parrafo_2" : """La entidad {id:nombre_empresa}, identificada bajo el registro {id:rut_empresa}, con domicilio administrativo en {id:direccion_empresa}, actuará en calidad de empleador para todos los efectos legales y operativos correspondientes. La organización mantendrá la facultad de asignar funciones, recursos y responsabilidades conforme a las necesidades institucionales vigentes."""
		,
		"parrafo_3" : """El trabajador desempeñará funciones asociadas al cargo de {id:cargo}, debiendo ejecutar las tareas, procedimientos y responsabilidades definidas para dicho puesto. El ejercicio de sus funciones deberá ajustarse a las normas internas, protocolos operativos y directrices emitidas por los niveles superiores de la organización."""
		},
	"anexo_conf" : {
		"parrafo_1" : """  El trabajador {id:nombre} declara conocer y aceptar que, durante el desempeño de sus funciones, podrá acceder a información operativa, administrativa, técnica o estratégica perteneciente a la organización. Dicha información deberá ser utilizada exclusivamente para el cumplimiento de las labores asignadas y no podrá ser divulgada, reproducida o compartida con terceros sin autorización expresa."""
		,
		"parrafo_2" : """  Se considerará información reservada toda documentación o antecedente de acceso restringido. El trabajador, en su cargo de{id:cargo}, se compromete a resguardar dicha información y utilizarla exclusivamente para el cumplimiento de sus funciones dentro de la organización."""
		,
		"parrafo_3" : """ El trabajador se compromete a adoptar las medidas razonables para resguardar la información a la que tenga acceso, evitando su pérdida, alteración o divulgación no autorizada. Asimismo, deberá informar oportunamente cualquier incidente que pueda comprometer la seguridad o integridad de dicha información."""
		,
		"parrafo_4" : """ La organización podrá realizar revisiones periódicas de cumplimiento, controles de acceso y auditorías internas destinadas a verificar la correcta aplicación de las medidas de resguardo establecidas. El trabajador declara haber sido informado de dichas facultades y acepta someterse a los procedimientos correspondientes cuando sean requeridos."""
		},
	"hoja_firmas" : {
		"parrafo_1" : """ Por medio de la presente, las partes dejan constancia de haber revisado y aceptado las disposiciones contenidas en este documento, reconociendo que su contenido refleja fielmente los acuerdos, obligaciones y antecedentes que motivan su suscripción."""
		,
		"parrafo_2" : """ Para todos los efectos legales y administrativos que correspondan, suscribe el presente documento {id:nombre}, actuando en calidad de {id:cargo}, dejando constancia de haber tomado conocimiento de su contenido y de aceptar las disposiciones en él establecidas."""
		,
		"parrafo_3" : """ Por su parte, {id:nombre_empresa} manifiesta su conformidad con los acuerdos y antecedentes contenidos en el presente instrumento, quedando igualmente obligada en los términos que de éste emanen."""
		,
		"parrafo_4" : """Las partes declaran haber leído íntegramente el presente {id:tipo_documento}, reconociendo que su contenido refleja fielmente los antecedentes, acuerdos y condiciones que motivan su suscripción, prestando su conformidad mediante la firma estampada al pie del presente instrumento."""
		},
	"informe_incidente" : {
		"parrafo_1" : """Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."""
		,
		"parrafo_2" : """Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."""
		,
		"parrafo_3" : """Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."""
		}
	
	}

func cargar_styles(): 
	styles = {
	"azul":
		"[color=#4FC3F7][font_size=12] {texto} [/font_size][/color]",

	"verde":
		"[color=#66BB6A][font_size=12] {texto} [/font_size][/color]",

	"roja":
		"[color=#950000][font_size=10] {texto} [/font_size][/color]"
	}
