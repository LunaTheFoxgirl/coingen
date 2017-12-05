#version 330
in vec3 vertexPosition;
in vec2 vertexTexCoord;
in vec4 vertexColor;
out vec2 fragTexCoord;
out vec4 fragColor;
out vec2 fragCoord;
uniform mat4 mvp;
void main()
{
    fragTexCoord = vertexTexCoord;
    fragCoord = fragTexCoord;
    fragColor = vertexColor;
    gl_Position = mvp*vec4(vertexPosition, 1.0);
}
