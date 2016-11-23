#include <perlin>
#include <math_constants>
#include <multisample>

parameter float timeScale = 1.0 : range(0.1, 3.0);

glsl mat2 rotMat(float t) {
    return mat2(
        cos(t), -sin(t),
        sin(t), cos(t));
}

glsl vec4 drawPixels(vec2 pos) {
    // Transform coordinate space
    vec2 scale = (shadron_Dimensions / shadron_Dimensions.y) * 1000.0;
    vec2 origin = scale / 2;
    pos = pos * scale;

    // Rotate coordinate around origin
    float t = -shadron_Time * timeScale; // Rotation angle, theta
    pos = rotMat(t) * (pos - origin);

    float blockSize = sin(shadron_Time * timeScale) * 25 + 30;
    float stepPos = sin(shadron_Time * timeScale) * 0.752 - 0.0325;
    float thisSample = step(stepPos, perlinNoise(floor(pos / blockSize)));

    // Add drop shadow
    vec2 lowerOffset = rotMat(t + PI / 4) * vec2(-0.15, 0.15) * blockSize;
    float lowerSample = 0.4 * step(stepPos, perlinNoise(floor((pos + lowerOffset)/ blockSize)));
    thisSample = clamp(thisSample + lowerSample, 0.0, 1.0);

    return vec4(vec3(thisSample), 1.0);
}

animation pixels = glsl(multisample<drawPixels, 4>, 1600, 900);
