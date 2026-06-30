extends Node

static var trabajadores : Array[Trabajador] = []

# --- FUNCIONES DE EJECUCION ---
func _ready():
	cargar_trabajadores_iniciales()
# --- FUNCIONES DE EJECUCION ---
func cargar_trabajadores_iniciales():
	var ana = Trabajador.nuevo(
		0,
		"Ana Ramírez",
		"Electricista",
		DatabaseEmpresas.EMPRESAS.VALVULA,
		"9999-0",
		"12-03-2004",
		"Mantenimiento",
		"II",
		"Los Faisanes, Hualpén"
	)
	
	#"EVENTO_CONDUCTUAL"
	#"EVENTO_MEDICO"
	#"EVENTO_CONTINUIDAD"
	
	ana.eventos["EVENTO_CONDUCTUAL"] = [
		{
			"fecha":"2026-02-15",
			"categoria" : "AMONESTACION",
			"resultado" : "NEGATIVO",
			"motivo":"Llegada tardía",
			"gravedad" : 3
		},
		{
			"fecha":"2025-04-10",
			"categoria" : "AMONESTACION",
			"resultado" : "NEGATIVO",
			"motivo":"Llegada tardía",
			"gravedad" : 5
		}
		
	]
	#
	#ana.eventos["EVENTO_MEDICO"] = [
		#{
			#"fecha":"2026-01-10",
			#"categoria" : "EXAMEN_RUTINARIO",
			#"resultado": "POSITIVO",
			#"doc_extra" : null,
			#"gravedad" : 5
		#},
		#{
			#"fecha":"2026-01-10",
			#"categoria" : "ACCIDENTE_GRAVE",
			#"resultado": "POSITIVO",
			#"doc_extra" : Documento,
			#"gravedad" : 5
		#}
	#]
	trabajadores.append(ana)



#func cargar_trabajadores_iniciales():
	#trabajadores = [
		#Trabajador.nuevo(1, "Ana Ramírez", "Electricista", "9999 - 0", "12 - 03 - 2004" , "Mantenimiento" , "I I" ),
#
#
		#Trabajador.nuevo(2, "Carlos Soto", "CONTABLE", "7777 - 0", "08 - 06 - 2002" , "Administracion" , "I V" ),
#
#
		#Trabajador.nuevo(3, "Lucía Fernández", "ABOGADO", "1298 - 2", "16 - 04 - 2000" , "Administracion" , "V" ),
	#]

static func get_trabajador(id : int) -> Trabajador:
	if id >= 0 and id < trabajadores.size():
		return trabajadores[id]
	return null

func get_trabajadores() -> Array[Trabajador]:
	return trabajadores
