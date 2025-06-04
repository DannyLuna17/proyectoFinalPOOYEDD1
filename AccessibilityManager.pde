// Clase para opciones de accesibilidad
class AccessibilityManager {
  // Ajustes visuales
  boolean highContrastMode = false;
  int textSizeMultiplier = 1; // 1 = normal, 2 = grande, 3 = muy grande
  boolean colorBlindMode = false;
  boolean reduceAnimations = false;
  
  // Ajustes auditivos
  boolean visualCuesForAudio = true;
  
  // Ajustes de control
  boolean alternativeControls = false;
  boolean keyboardOnly = false;
  boolean mouseOnly = false;
  
  // Teclas por defecto
  char jumpKey = ' ';
  char slideKey = 's';
  char pauseKey = 'p';
  
  // Colores para alto contraste
  color highContrastBackground;
  color highContrastForeground;
  color highContrastAccent;
  color highContrastText;
  
  // Colores para UI en alto contraste
  color highContrastTextOnDark;
  color highContrastTextOnLight;
  color highContrastUIElement;
  color highContrastUIBorder;
  
  // Paleta para daltónicos
  color[] colorBlindPalette;
  
  // Colores originales
  color originalBgColor;
  color originalFgColor;
  color originalTextColor;
  
  // Colores para modo daltónico
  color colorBlindBackground;
  color colorBlindForeground;
  color colorBlindText;
  color colorBlindObstacle;
  color colorBlindCollectible;
  
  // Propiedades para señales visuales de sonido
  float soundCueDisplayTime = 2.0;
  Queue<SoundCue> activeSoundCues;
  
  // Variables para optimización del filtro de daltonismo
  PShader deuteranopiaShader;
  PGraphics mainBuffer;
  boolean shaderLoaded = false;
  boolean filterNeedsUpdate = true;
  boolean lastColorBlindState = false;
  
  // Variables para optimización del filtro de alto contraste
  PShader highContrastShader;
  PGraphics contrastBuffer;
  boolean contrastShaderLoaded = false;
  boolean contrastFilterNeedsUpdate = true;
  boolean lastHighContrastState = false;
  
  AccessibilityManager() {
    // Colores alto contraste
    highContrastBackground = color(0);
    highContrastForeground = color(255, 255, 0);
    highContrastAccent = color(255, 0, 0);
    highContrastText = color(0);
    
    highContrastTextOnDark = color(255, 255, 0);
    highContrastTextOnLight = color(0);
    highContrastUIElement = color(255);
    highContrastUIBorder = color(255, 0, 0);
    
    // Paleta para daltónicos
    colorBlindPalette = new color[5];
    colorBlindPalette[0] = color(27, 158, 119);
    colorBlindPalette[1] = color(217, 95, 2);
    colorBlindPalette[2] = color(117, 112, 179);
    colorBlindPalette[3] = color(231, 41, 138);
    colorBlindPalette[4] = color(102, 166, 30);
    
    // Colores originales
    originalBgColor = color(80, 150, 200);
    originalFgColor = color(50, 50, 50);
    originalTextColor = color(0);
    
    // Colores para daltónicos
    colorBlindBackground = color(51, 78, 204);
    colorBlindForeground = color(255, 150, 0);
    colorBlindText = color(0, 0, 153);
    colorBlindObstacle = color(204, 82, 0);
    colorBlindCollectible = color(0, 153, 153);
    
    activeSoundCues = new Queue<SoundCue>();
    
    // Inicializar optimizaciones del filtro
    initializeColorBlindFilter();
    initializeHighContrastFilter();
  }
  
  /**
   * Inicializa las optimizaciones para el filtro de daltonismo
   * Usa shaders si están disponibles, si no usa un método alternativo optimizado
   */
  void initializeColorBlindFilter() {
    try {
      // Intentar cargar shader personalizado para deuteranopia
      deuteranopiaShader = loadShader("deuteranopia.glsl");
      shaderLoaded = true;
      println("✓ Shader de daltonismo cargado - usando aceleración GPU");
    } catch (Exception e) {
      // Si no se puede cargar el shader, usar método alternativo optimizado
      shaderLoaded = false;
      println("⚠ Shader no disponible - usando filtro CPU optimizado");
      // Solo mostrar error detallado si es necesario para debug
      // println("Detalle: " + e.getMessage());
    }
    
    // No crear el buffer inmediatamente para ahorrar memoria
    // Se creará solo cuando sea necesario
    mainBuffer = null;
  }
  
  /**
   * Inicializa las optimizaciones para el filtro de alto contraste
   * Usa el mismo patrón que el filtro de daltonismo para máximo rendimiento
   */
  void initializeHighContrastFilter() {
    try {
      // Intentar cargar shader de alto contraste
      highContrastShader = loadShader("high_contrast.glsl");
      contrastShaderLoaded = true;
      println("✓ Shader de alto contraste cargado - usando aceleración GPU");
    } catch (Exception e) {
      // Si no se puede cargar el shader, usar método alternativo optimizado
      contrastShaderLoaded = false;
      println("⚠ Shader de alto contraste no disponible - usando filtro CPU optimizado");
      // Solo mostrar error detallado si es necesario para debug
      // println("Detalle: " + e.getMessage());
    }
    
    // No crear el buffer inmediatamente para ahorrar memoria
    // Se creará solo cuando sea necesario
    contrastBuffer = null;
  }
  
  /**
   * Crea el buffer de forma lazy (solo cuando se necesita)
   * Esto ahorra memoria si el filtro nunca se usa
   */
  void ensureBufferExists() {
    if (mainBuffer == null && !shaderLoaded) {
      try {
        mainBuffer = createGraphics(width, height, P2D);
        println("Buffer de daltonismo inicializado: " + width + "x" + height);
      } catch (Exception e) {
        println("Error creando buffer: " + e.getMessage());
        mainBuffer = null;
      }
    }
  }
  
  /**
   * Crea el buffer de alto contraste de forma lazy
   * Solo se crea cuando realmente se necesita para ahorrar memoria
   */
  void ensureContrastBufferExists() {
    if (contrastBuffer == null && !contrastShaderLoaded) {
      try {
        contrastBuffer = createGraphics(width, height, P2D);
        println("Buffer de alto contraste inicializado: " + width + "x" + height);
      } catch (Exception e) {
        println("Error creando buffer de contraste: " + e.getMessage());
        contrastBuffer = null;
      }
    }
  }
  
  /**
   * Limpia recursos del filtro para liberar memoria
   */
  void cleanupColorBlindFilter() {
    if (mainBuffer != null) {
      // No hay dispose() en Processing, pero podemos liberar la referencia
      mainBuffer = null;
      println("Buffer de daltonismo liberado");
    }
    
    if (contrastBuffer != null) {
      // Liberar también el buffer de alto contraste
      contrastBuffer = null;
      println("Buffer de alto contraste liberado");
    }
  }
  
  float getAdjustedTextSize(float baseSize) {
    return baseSize * textSizeMultiplier;
  }
  
  color getBackgroundColor(color defaultColor) {
    if (highContrastMode) {
      // Con filtros overlay, devolver el color original
      return defaultColor;
    } else if (colorBlindMode) {
      return colorBlindBackground;
    } else {
      return defaultColor;
    }
  }
  
  color getForegroundColor(color defaultColor) {
    if (highContrastMode) {
      // Con filtros overlay, devolver el color original
      return defaultColor;
    } else if (colorBlindMode) {
      return colorBlindForeground;
    } else {
      return defaultColor;
    }
  }
  
  color getTextColor(color defaultColor) {
    // Cuando usamos filtros overlay (shaders o buffer), NO cambiar los colores aquí
    // El filtro se encarga de ajustar la visibilidad de todos los elementos
    if (highContrastMode) {
      // Simplemente devolver el color original
      // El filtro de alto contraste se aplicará después como overlay
      return defaultColor;
    } else if (colorBlindMode) {
      return colorBlindText;
    } else {
      return defaultColor;
    }
  }
  
  color findClosestColorBlindColor(color inputColor) {
    float brightness = (red(inputColor) + green(inputColor) + blue(inputColor)) / 3;
    int index = int(map(brightness, 0, 255, 0, colorBlindPalette.length - 1));
    return colorBlindPalette[index];
  }
  
  void toggleHighContrastMode() {
    highContrastMode = !highContrastMode;
    contrastFilterNeedsUpdate = true;
    println("High contrast mode: " + (highContrastMode ? "ON" : "OFF"));
  }
  
  void toggleColorBlindMode() {
    colorBlindMode = !colorBlindMode;
    filterNeedsUpdate = true;
    println("Color blind mode: " + (colorBlindMode ? "ON" : "OFF"));
  }
  
  void toggleReducedAnimations() {
    reduceAnimations = !reduceAnimations;
    println("Reduced animations: " + (reduceAnimations ? "ON" : "OFF"));
  }
  
  void toggleVisualCuesForAudio() {
    visualCuesForAudio = !visualCuesForAudio;
    println("Visual cues for audio: " + (visualCuesForAudio ? "ON" : "OFF"));
  }
  
  void toggleAlternativeControls() {
    alternativeControls = !alternativeControls;
    println("Alternative controls: " + (alternativeControls ? "ON" : "OFF"));
  }
  
  void toggleKeyboardOnly() {
    keyboardOnly = !keyboardOnly;
    if (keyboardOnly) mouseOnly = false;
    println("Keyboard only: " + (keyboardOnly ? "ON" : "OFF"));
  }
  
  void toggleMouseOnly() {
    mouseOnly = !mouseOnly;
    if (mouseOnly) keyboardOnly = false;
    println("Mouse only: " + (mouseOnly ? "ON" : "OFF"));
  }
  
  void setTextSizeMultiplier(int multiplier) {
    textSizeMultiplier = constrain(multiplier, 1, 3);
    println("Text size multiplier set to: " + textSizeMultiplier);
  }
  
  void cycleTextSize() {
    textSizeMultiplier = (textSizeMultiplier % 3) + 1;
    println("Text size multiplier set to: " + textSizeMultiplier);
  }
  
  void setJumpKey(char key) {
    jumpKey = key;
    println("Jump key set to: " + jumpKey);
  }
  
  void setSlideKey(char key) {
    slideKey = key;
    println("Slide key set to: " + slideKey);
  }
  
  void setPauseKey(char key) {
    pauseKey = key;
    println("Pause key set to: " + pauseKey);
  }
  
  char getJumpKey() {
    if (alternativeControls) {
      return 'j';
    } else {
      return jumpKey;
    }
  }
  
  char getSlideKey() {
    if (alternativeControls) {
      return 's';
    } else {
      return slideKey;
    }
  }
  
  char getPauseKey() {
    if (alternativeControls) {
      return 'p';
    } else {
      return pauseKey;
    }
  }
  
  boolean shouldUseKeyboard() {
    return !mouseOnly;
  }
  
  boolean shouldUseMouse() {
    return !keyboardOnly;
  }
  
  color getUITextColor(color defaultTextColor, color backgroundColor) {
    if (highContrastMode) {
      // Con filtros overlay, devolver el color original
      return defaultTextColor;
    } else if (colorBlindMode) {
      return colorBlindText;
    } else {
      return defaultTextColor;
    }
  }
  
  color getUIBorderColor(color defaultColor) {
    if (highContrastMode) {
      // Con filtros overlay, devolver el color original
      return defaultColor;
    } else if (colorBlindMode) {
      return colorBlindForeground;
    } else {
      return defaultColor;
    }
  }
  
  color getUIElementColor(color defaultColor) {
    if (highContrastMode) {
      // Con filtros overlay, devolver el color original
      return defaultColor;
    } else if (colorBlindMode) {
      return colorBlindForeground;
    } else {
      return defaultColor;
    }
  }
  
  color adjustButtonColor(color defaultColor) {
    if (highContrastMode) {
      // Con filtros overlay, devolver el color original
      return defaultColor;
    } else if (colorBlindMode) {
      return colorBlindForeground;
    }
    return defaultColor;
  }
  
  color adjustButtonHoverColor(color defaultHoverColor) {
    if (highContrastMode) {
      // Con filtros overlay, devolver el color original
      return defaultHoverColor;
    } else if (colorBlindMode) {
      return color(red(colorBlindForeground) * 0.8, 
                  green(colorBlindForeground) * 0.8, 
                  blue(colorBlindForeground) * 0.8);
    }
    return defaultHoverColor;
  }
  
  color adjustTextColor(color defaultTextColor) {
    if (highContrastMode) {
      // Con filtros overlay, devolver el color original
      return defaultTextColor;
    } else if (colorBlindMode) {
      return colorBlindText;
    } else {
      return defaultTextColor;
    }
  }
  
  void displaySoundCue(String soundType, float x, float y) {
    if (!visualCuesForAudio) return;
    
    SoundCue cue = new SoundCue(soundType, x, y, this);
    activeSoundCues.enqueue(cue);
  }
  
  String getKeyboardNavInstructions() {
    return "Usa las FLECHAS o W/S para navegar, ENTER/ESPACIO para seleccionar, ESC para volver";
  }
  
  void updateSoundCues() {
    if (!visualCuesForAudio) return;
    
    Queue<SoundCue> tempQueue = new Queue<SoundCue>(); 
    
    while (!activeSoundCues.isEmpty()) {
      SoundCue cue = activeSoundCues.dequeue(); // Sacar la señal más antigua
      cue.update();
      cue.display();
      
      if (!cue.isExpired()) {
        tempQueue.enqueue(cue); // Guardar en cola temporal si no ha expirado
      }
      // Si ha expirado, simplemente no la volvemos a añadir
    }
    
    // Restaurar las señales no expiradas a la cola principal
    while (!tempQueue.isEmpty()) {
      activeSoundCues.enqueue(tempQueue.dequeue());
    }
  }
  
  void displayStatus() {
    pushStyle();
    fill(0);
    textSize(12);
    textAlign(LEFT);
    text("Alto Contraste: " + highContrastMode, 10, height - 85);
    text("Daltonismo: " + colorBlindMode, 10, height - 70);
    text("Pistas Visuales: " + visualCuesForAudio, 10, height - 55);
    text("Controles Alt: " + alternativeControls, 10, height - 40);
    text("Solo Teclado: " + keyboardOnly, 10, height - 25);
    text("Atajos: H=Alto contraste, C=Daltonismo", 10, height - 10);
    popStyle();
  }
  
  /**
   * Aplica el filtro de daltonismo (Deuteranopia) optimizado
   * Usa GPU cuando es posible, CPU optimizada como fallback
   */
  void applyColorBlindFilter() {
    // Solo aplicar si el modo daltonismo está activado
    if (!colorBlindMode) return;
    
    // Detectar si cambió el estado del filtro para optimización
    if (lastColorBlindState != colorBlindMode) {
      filterNeedsUpdate = true;
      lastColorBlindState = colorBlindMode;
    }
    
    if (shaderLoaded && deuteranopiaShader != null) {
      // Método GPU super rápido usando shaders
      applyShaderFilter();
    } else {
      // Método CPU optimizado como fallback 
      applyCPUOptimizedFilter();
    }
    
    // Mostrar indicador visual de que el filtro está activo
    mostrarIndicadorFiltro();
  }
  
  /**
   * Aplica el filtro usando shaders GPU (súper eficiente)
   */
  void applyShaderFilter() {
    // Aplicar shader directamente a toda la pantalla
    // Esto es muchísimo más rápido que procesar píxeles individualmente
    filter(deuteranopiaShader);
  }
  
  /**
   * Aplica el filtro usando CPU con optimizaciones máximas
   * Solo se usa si los shaders no están disponibles
   */
  void applyCPUOptimizedFilter() {
    // Asegurar que el buffer existe antes de usarlo
    ensureBufferExists();
    
    if (mainBuffer == null) {
      // Si no hay buffer, usar método directo pero optimizado
      applyDirectOptimizedFilter();
      return;
    }
    
    // Este método es más lento que GPU pero mucho más rápido que el anterior
    // porque evita procesar píxeles directamente en el framebuffer principal
    
    // Solo actualizar el buffer si realmente ha cambiado algo
    if (filterNeedsUpdate) {
      // Capturar la pantalla actual en el buffer
      mainBuffer.beginDraw();
      mainBuffer.clear(); // Limpiar buffer antes de copiar
      mainBuffer.copy(g, 0, 0, width, height, 0, 0, width, height);
      
      // Aplicar transformación de color al buffer usando blend modes
      // Esto es más eficiente que procesar píxel por píxel
      mainBuffer.blendMode(MULTIPLY);
      
      // Aplicar filtros de color usando overlays optimizados
      // Estos valores simulan la deuteranopia de forma aproximada pero eficiente
      mainBuffer.fill(159, 96, 0, 100); // Filtro rojizo-naranja
      mainBuffer.noStroke();
      mainBuffer.rect(0, 0, width, height);
      
      mainBuffer.blendMode(SCREEN);
      mainBuffer.fill(0, 76, 178, 80); // Filtro azulado
      mainBuffer.rect(0, 0, width, height);
      
      mainBuffer.blendMode(NORMAL);
      mainBuffer.endDraw();
      
      filterNeedsUpdate = false;
    }
    
    // Dibujar el buffer filtrado sobre la pantalla con blending optimizado
    pushStyle();
    tint(255, 240); // Mezclar sutilmente con la imagen original
    image(mainBuffer, 0, 0);
    noTint();
    popStyle();
  }
  
  /**
   * Método directo optimizado para cuando no hay buffer disponible
   * Última opción de fallback
   */
  void applyDirectOptimizedFilter() {
    // Usar blend modes para simular el efecto sin procesar píxeles
    pushStyle();
    
    // Aplicar overlay de color que simula deuteranopia
    blendMode(MULTIPLY);
    fill(159, 96, 0, 60); // Reducir saturación de rojos y verdes
    rect(0, 0, width, height);
    
    blendMode(SCREEN);
    fill(0, 76, 178, 40); // Potenciar azules
    rect(0, 0, width, height);
    
    blendMode(NORMAL);
    popStyle();
  }
  
  /**
   * Muestra un pequeño indicador en la esquina para confirmar que el filtro está activo
   * Optimizado para no afectar el rendimiento del filtro
   */
  void mostrarIndicadorFiltro() {
    // Solo dibujar el indicador cada ciertos frames para no afectar performance
    if (frameCount % 3 != 0) return;
    
    pushStyle();
    
    // Fondo semi-transparente para el indicador (optimizado)
    fill(0, 150);
    noStroke();
    rectMode(CORNER);
    rect(width - 180, 10, 170, 30, 5);
    
    // Texto del indicador
    fill(255);
    textAlign(RIGHT, CENTER);
    textSize(14);
    text("Filtro Deuteranopia ON", width - 15, 25);
    
    // Pequeño ícono de ojo (simplificado para mejor rendimiento)
    strokeWeight(2);
    stroke(255);
    noFill();
    ellipse(width - 160, 25, 20, 12);
    fill(255);
    noStroke();
    ellipse(width - 160, 25, 8, 8);
    
    popStyle();
  }
  
  /**
   * Aplica el filtro de alto contraste optimizado
   * Mejora la visibilidad para usuarios que necesitan mayor distinción visual
   */
  void applyHighContrastFilter() {
    // Solo aplicar si el modo alto contraste está activado
    if (!highContrastMode) return;
    
    // Detectar si cambió el estado del filtro para optimización
    if (lastHighContrastState != highContrastMode) {
      contrastFilterNeedsUpdate = true;
      lastHighContrastState = highContrastMode;
    }
    
    if (contrastShaderLoaded && highContrastShader != null) {
      // Método GPU super rápido usando shaders
      applyContrastShaderFilter();
    } else {
      // Método CPU optimizado como fallback 
      applyContrastCPUOptimizedFilter();
    }
    
    // Mostrar indicador visual de que el filtro está activo
    mostrarIndicadorAltoContraste();
  }
  
  /**
   * Aplica el filtro de alto contraste usando shaders GPU (súper eficiente)
   */
  void applyContrastShaderFilter() {
    // Aplicar shader directamente a toda la pantalla
    // Esto es muchísimo más rápido que procesar píxeles individualmente
    filter(highContrastShader);
  }
  
  /**
   * Aplica el filtro de alto contraste usando CPU con optimizaciones máximas
   * Solo se usa si los shaders no están disponibles
   */
  void applyContrastCPUOptimizedFilter() {
    // Asegurar que el buffer existe antes de usarlo
    ensureContrastBufferExists();
    
    if (contrastBuffer == null) {
      // Si no hay buffer, usar método directo pero optimizado
      applyDirectContrastFilter();
      return;
    }
    
    // Solo actualizar el buffer si realmente ha cambiado algo
    if (contrastFilterNeedsUpdate) {
      // Capturar la pantalla actual en el buffer
      contrastBuffer.beginDraw();
      contrastBuffer.clear(); // Limpiar buffer antes de copiar
      contrastBuffer.copy(g, 0, 0, width, height, 0, 0, width, height);
      
      // Aplicar transformaciones de alto contraste más suaves
      contrastBuffer.blendMode(MULTIPLY);
      
      // Oscurecer las zonas medias más sutilmente
      contrastBuffer.fill(160, 160, 160, 80); // Más claro y menos opaco
      contrastBuffer.noStroke();
      contrastBuffer.rect(0, 0, width, height);
      
      contrastBuffer.blendMode(SCREEN);
      
      // Aclarar las zonas brillantes más sutilmente
      contrastBuffer.fill(200, 200, 200, 60); // Menos intenso
      contrastBuffer.rect(0, 0, width, height);
      
      contrastBuffer.blendMode(NORMAL);
      contrastBuffer.endDraw();
      
      contrastFilterNeedsUpdate = false;
    }
    
    // Dibujar el buffer filtrado sobre la pantalla con blending más suave
    pushStyle();
    tint(255, 180); // Mezclar más sutilmente con la imagen original
    image(contrastBuffer, 0, 0);
    noTint();
    popStyle();
  }
  
  /**
   * Método directo optimizado para alto contraste cuando no hay buffer disponible
   * Última opción de fallback
   */
  void applyDirectContrastFilter() {
    // Usar blend modes para simular el efecto sin procesar píxeles
    pushStyle();
    
    // Aplicar overlay más suave que aumenta el contraste
    blendMode(MULTIPLY);
    fill(160, 160, 160, 50); // Oscurecer zonas medias más sutilmente
    rect(0, 0, width, height);
    
    blendMode(SCREEN);
    fill(200, 200, 200, 40); // Aclarar zonas brillantes más sutilmente
    rect(0, 0, width, height);
    
    blendMode(NORMAL);
    popStyle();
  }
  
  /**
   * Muestra indicador visual para el filtro de alto contraste
   * Optimizado para no afectar el rendimiento
   */
  void mostrarIndicadorAltoContraste() {
    // Solo dibujar el indicador cada ciertos frames para no afectar performance
    if (frameCount % 3 != 0) return;
    
    pushStyle();
    
    // Fondo semi-transparente para el indicador (optimizado)
    fill(0, 150);
    noStroke();
    rectMode(CORNER);
    rect(width - 180, 50, 170, 30, 5);
    
    // Texto del indicador
    fill(255);
    textAlign(RIGHT, CENTER);
    textSize(14);
    text("Alto Contraste ON", width - 15, 65);
    
    // Pequeño ícono de contraste (simplificado para mejor rendimiento)
    strokeWeight(2);
    stroke(255);
    noFill();
    rect(width - 170, 58, 15, 15, 2);
    fill(255);
    noStroke();
    rect(width - 170, 58, 7, 15);
    
    popStyle();
  }
}

/**
 * Clase para mostrar indicadores visuales de sonido
 */
class SoundCue {
  String type;
  float x, y;
  float lifespan;
  float maxLifespan = 2000;
  color cueColor;
  float size;
  AccessibilityManager manager;
  
  SoundCue(String type, float x, float y, AccessibilityManager manager) {
    this.type = type;
    this.x = x;
    this.y = y;
    this.lifespan = maxLifespan;
    this.manager = manager;
    
    setCueProperties();
  }
  
  void setCueProperties() {
    switch(type) {
      case "jump":
        cueColor = color(0, 200, 255);
        size = 30;
        break;
      case "slide":
        cueColor = color(255, 100, 0);
        size = 30;
        break;
      case "collect":
        cueColor = color(0, 255, 0);
        size = 25;
        break;
      case "collision":
        cueColor = color(255, 0, 0);
        size = 35;
        break;
      case "hit":
        cueColor = color(255, 50, 50);
        size = 40;
        break;
      case "shield_break":
        cueColor = color(100, 255, 100);
        size = 45;
        break;
      case "powerup":
        cueColor = color(200, 0, 255);
        size = 40;
        break;
      case "game_over":
        cueColor = color(255, 0, 0);
        size = 50;
        break;
      case "button":
        cueColor = color(150, 150, 255);
        size = 20;
        break;
      default:
        cueColor = color(200);
        size = 25;
    }
    
    if (manager.highContrastMode) {
      // Con filtros overlay, mantener colores originales
      // El filtro se encargará de ajustar la visibilidad
      // cueColor ya tiene el color correcto asignado
    } else if (manager.colorBlindMode) {
      cueColor = manager.colorBlindForeground;
    }
  }
  
  void update() {
    lifespan -= 16.67;
  }
  
  void display() {
    float alpha = map(lifespan, 0, maxLifespan, 0, 255);
    float currentSize = map(lifespan, 0, maxLifespan, size * 2, size);
    
    pushStyle();
    noFill();
    stroke(red(cueColor), green(cueColor), blue(cueColor), alpha);
    strokeWeight(3);
    ellipse(x, y, currentSize, currentSize);
    
    for (int i = 0; i < 4; i++) {
      float waveSize = currentSize + (i * 15) * (1 - lifespan/maxLifespan);
      stroke(red(cueColor), green(cueColor), blue(cueColor), alpha * (1 - i * 0.2));
      ellipse(x, y, waveSize, waveSize);
    }
    
    fill(red(cueColor), green(cueColor), blue(cueColor), alpha);
    textAlign(CENTER, CENTER);
    textSize(12);
    text(type.toUpperCase(), x, y + currentSize/2 + 15);
    popStyle();
  }
  
  boolean isExpired() {
    return lifespan <= 0;
  }
} 