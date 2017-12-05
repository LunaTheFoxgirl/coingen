#version 330

// Input vertex attributes (from vertex shader)
in vec2 fragTexCoord;
in vec4 fragColor;

// Input uniform values
uniform sampler2D texture0;
uniform float state;

// Output fragment color
out vec4 finalColor;

// NOTE: Add here your custom variables

void main()
{
    // Texel color fetching from texture sampler
    vec4 source = texture(texture0, fragTexCoord);
    float v = sin(state);
    if (v < 0.5)
    {
	finalColor = source - vec4(0, 0, 0, 0.1);
    }
    else
    {
	finalColor = source - vec4(0, 0, 0, 0.5);
    }
    // finalColor = source - vec4(0, 0, 0, min_c(max_c(v, 0.5), 0.1));
}

float min_c(float a, float b)
{
	float x = a;
	if (x < b)
	{
		x = b;
	}
	return x;
}

float max_c(float a, float b)
{
	float x = a;
	if (x > b)
	{
		x = b;
	}
	return x;
}
