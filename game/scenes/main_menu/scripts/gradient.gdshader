shader_type canvas_item;

uniform sampler2D gradient; // is a variable that holds a texture 

void fragment(){ 
	vec4 col = texture(gradient, vec2(0, UV.y));	 // read the colour of the pixel at coords (m, UV.y)
	COLOR = texture(TEXTURE,UV) * COLOR * col; // mix the colours of the original texture (TEXTURE) at uv (coords) witht he colour we got from the gradient 	
}