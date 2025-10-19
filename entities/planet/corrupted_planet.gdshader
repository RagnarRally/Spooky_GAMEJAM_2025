shader_type canvas_item;

uniform float amt : hint_range(0.0, 1.0);
uniform vec4 color : source_color;

void fragment() 
{
	float d = distance(UV, vec2(0.5,0.5));
	if (d > amt/2.0) 
	{
		COLOR = vec4(0.0);
	}
	else 
	{
		COLOR = vec4(color.rgb, d);
	}
}