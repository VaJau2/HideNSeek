shader_type canvas_item;

const float intensity = 1.12;
const float rot = -15.0;

void fragment()
{
	vec2 iResolution = 1.0 / SCREEN_PIXEL_SIZE;
	vec2 uv = (FRAGCOORD.xy / iResolution.xy);
	uv.y = uv.y * -1.0; 
	vec3 col = texture(TEXTURE, uv).rrr;
	
	col = vec3(col.r *.98, col.g, col.b *1.04)* 1.5;
	uv.y = uv.y * -1.0; 
	
	float ts=uv.y-.2+sin(uv.x*4.0+7.4*cos(uv.x*10.0))*0.005;
	col = mix(col,vec3(1.5* (.85 + TIME * 0.02)-uv.y),smoothstep(0.45,0.0,ts));
	
	float c=cos(rot*0.01),si=sin(rot*0.01);
	
	uv=(uv-0.5)*mat2(vec2(c,si), vec2(-si,c));
	Sampler2D iChannel1
	
	float s=texture(TEXTURE,uv * 1.01 +vec2(TIME)*vec2(0.02,0.501)).r;
	col=mix(col,vec3(1.0),smoothstep(0.9,1.0, s * .9 * intensity));
	
	s=texture(TEXTURE,uv * 1.07 +vec2(TIME)*vec2(0.02,0.501)).r;
	col=mix(col,vec3(1.0),smoothstep(0.9,1.0, s * 1. * intensity));
	
	COLOR = vec4(col,1.0);
}