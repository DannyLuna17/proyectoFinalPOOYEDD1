#ifdef GL_ES
precision mediump float;
#endif

// Shader para filtro de alto contraste
// Mejora la visibilidad aumentando el contraste y reduciendo colores intermedios

uniform sampler2D texture;
varying vec4 vertTexCoord;

void main() {
    // Obtener el color original del píxel
    vec4 original = texture2D(texture, vertTexCoord.st);
    
    // Si el píxel es transparente o casi transparente, mantenerlo así
    // Esto preserva los sprites y sus detalles
    if (original.a < 0.1) {
        gl_FragColor = original;
        return;
    }
    
    // Calcular la luminancia (brillo percibido) del color
    float luminance = 0.299 * original.r + 0.587 * original.g + 0.114 * original.b;
    
    // Si la luminancia es muy baja (casi negro), no procesarlo para preservar contornos
    if (luminance < 0.05) {
        gl_FragColor = original;
        return;
    }
    
    // Aplicar curva de contraste más suave para preservar detalles
    // Reducido de 2.5 a 1.8 para ser menos agresivo
    float contrast = 1.8;
    float adjustedLum = ((luminance - 0.5) * contrast) + 0.5;
    adjustedLum = clamp(adjustedLum, 0.0, 1.0);
    
    // Mantener más saturación para preservar información de color
    // Aumentado de 0.3 a 0.6
    float saturation = 0.6;
    vec3 gray = vec3(luminance);
    vec3 desaturated = mix(gray, original.rgb, saturation);
    
    // Para textos y elementos muy brillantes, aplicar menos procesamiento
    if (luminance > 0.85) {
        // Mantener textos blancos y elementos brillantes más legibles
        gl_FragColor = vec4(mix(original.rgb, vec3(1.0), 0.3), original.a);
        return;
    }
    
    // Aplicar el ajuste de contraste a los colores desaturados
    vec3 contrasted = desaturated * (adjustedLum / max(luminance, 0.001));
    contrasted = clamp(contrasted, 0.0, 1.0);
    
    // Mezclar con el original para mantener más detalles
    vec3 finalColor = mix(original.rgb, contrasted, 0.7);
    
    // Resultado final con alpha original preservado
    gl_FragColor = vec4(finalColor, original.a);
} 