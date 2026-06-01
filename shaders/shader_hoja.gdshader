shader_type spatial;

render_mode unshaded, blend_mix, cull_disabled;

uniform sampler2D documento_texture;
uniform sampler2D mascara_borde;

uniform vec4 color_borde : source_color = vec4(0.0, 0.0, 0.0, 1.0);

uniform float grosor_borde = 0.004;

void fragment() {

	vec2 uv = UV;

	vec4 documento =
		texture(documento_texture, uv);

	float alpha =
		texture(mascara_borde, uv).r;

	// MUESTRAS ALREDEDOR
	float arriba =
		texture(mascara_borde, uv + vec2(0.0, grosor_borde)).r;

	float abajo =
		texture(mascara_borde, uv - vec2(0.0, grosor_borde)).r;

	float izquierda =
		texture(mascara_borde, uv - vec2(grosor_borde, 0.0)).r;

	float derecha =
		texture(mascara_borde, uv + vec2(grosor_borde, 0.0)).r;

	// DETECTAR BORDE
	float borde =
		step(0.5, alpha) *
		(
			step(0.5, 1.0 - arriba) +
			step(0.5, 1.0 - abajo) +
			step(0.5, 1.0 - izquierda) +
			step(0.5, 1.0 - derecha)
		);

	vec3 color_final = documento.rgb;

	if (borde > 0.0) {
		color_final = color_borde.rgb;
	}

	ALBEDO = color_final;

	ALPHA = documento.a * alpha;
}