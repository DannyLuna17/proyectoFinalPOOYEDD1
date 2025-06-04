#ifdef GL_ES
precision mediump float;
#endif

// Shader para simular deuteranopia (un tipo de daltonismo)
// Este filtro se ejecuta en la GPU para máximo rendimiento

uniform sampler2D texture;
varying vec4 vertTexCoord;

void main() {
    // Obtener el color original del píxel
    vec4 original = texture2D(texture, vertTexCoord.st);
    
    // Aplicar matriz de transformación para deuteranopia
    // Esta matriz simula cómo ve los colores alguien con este tipo de daltonismo
    float r = original.r * 0.625 + original.g * 0.375;
    float g = original.r * 0.7 + original.g * 0.3;
    float b = original.g * 0.3 + original.b * 0.7;
    
    // Mantener el canal alpha original
    gl_FragColor = vec4(r, g, b, original.a);
} 