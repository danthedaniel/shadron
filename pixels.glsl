#include <perlin>
#include <math_constants>
#include <multisample>

parameter float timeScale = 0.2 : range(0.03, 0.5);

// Generates a rotation matrix
glsl mat2 rotMat(float t) {
    return mat2(
        cos(t), -sin(t),
        sin(t), cos(t));
}

// Converts colors in HSV space to RBG space
glsl vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * normalize(mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y));
}

glsl vec4 drawPixels(vec2 pos) {
    // Transform coordinate space
    float coordMult = 1000.0;
    vec2 scale = vec2(1.0) * coordMult;
    vec2 origin = scale / 2;
    pos = pos * scale;

    float scaledTime = shadron_Time * timeScale * PI;

    // Rotate coordinate around origin
    float t = -scaledTime; // Rotation angle, theta
    pos = rotMat(t) * (pos - origin);

    float zoom = sin(scaledTime) * 25 + 45;
    float stepPos = sin(scaledTime) * 0.752 - 0.0325;
    float upperSample = step(stepPos, perlinNoise(floor(pos / zoom)));

    // Add drop shadow
    vec2 lowerOffset = rotMat(t + PI / 4) * vec2(-0.15, 0.15) * zoom;
    float lowerSample = 0.4 * step(stepPos, perlinNoise(floor((pos + lowerOffset) / zoom)));
    float thisSample = clamp(upperSample + lowerSample, 0.0, 1.0);

    // Add color
    float hue = mod((pos.x + coordMult * scaledTime / 10) / (coordMult * 4), 1.0);
    vec3 thisColor = hsv2rgb(vec3(hue, 0.8, thisSample));

    return vec4(thisColor, 1.0);
}

animation pixels = glsl(multisample<drawPixels, 4>, 1600, 900);
