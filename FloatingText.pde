class FloatingText {
  String message;
  float x, y;
  color textColor;
  float alpha;
  float vSpeed;
  float hSpeed = 0; // Velocidad horizontal
  int lifetime;
  int maxLifetime;
  int textStyle = 0; // 0 = normal, 1 = educativo
  boolean isEcoMessage = false;
  float textSizeMultiplier = 1.0; // Multiplicador de tamaño de texto
  
  // Referencia al gestor de accesibilidad
  AccessibilityManager accessManager;
  
  FloatingText(String message, float x, float y, color textColor) {
    this.message = message;
    this.x = x;
    this.y = y;
    this.textColor = textColor;
    this.alpha = 255;
    this.vSpeed = -1.5; // Movimiento hacia arriba
    this.lifetime = 0;
    this.maxLifetime = 60; // 1 segundo a 60 fps
    
    // Gestor de accesibilidad por defecto
    this.accessManager = new AccessibilityManager();
  }
  
  FloatingText(String message, float x, float y, color textColor, int style) {
    this(message, x, y, textColor);
    this.textStyle = style;
    
    // Ajustes específicos para mensajes educativos
    if (textStyle == 1) {
      this.isEcoMessage = true;
      this.maxLifetime = 120; // Los mensajes educativos duran más (2 segundos)
      this.vSpeed = -0.8; // Movimiento más lento
    }
  }
  
  // Constructor con gestor de accesibilidad
  FloatingText(String message, float x, float y, color textColor, AccessibilityManager accessManager) {
    this(message, x, y, textColor);
    this.accessManager = accessManager;
  }
  
  // Constructor con estilo y gestor de accesibilidad
  FloatingText(String message, float x, float y, color textColor, int style, AccessibilityManager accessManager) {
    this(message, x, y, textColor, style);
    this.accessManager = accessManager;
  }
  
  void update() {
    // Mover según velocidades
    y += vSpeed;
    x += hSpeed;
    
    // Desvanecer
    lifetime++;
    
    // Desvanecer más lentamente al principio para mensajes educativos
    if (isEcoMessage) {
      if (lifetime < maxLifetime * 0.7) {
        alpha = 255; // Mantener opaco por más tiempo
      } else {
        alpha = map(lifetime, maxLifetime * 0.7, maxLifetime, 255, 0);
      }
    } else {
      alpha = map(lifetime, 0, maxLifetime, 255, 0);
    }
  }
  
  void display() {
    pushMatrix();
    pushStyle();
    
    textAlign(CENTER);
    // Usar tamaño de texto ajustado desde el gestor de accesibilidad
    float textSizeValue = isEcoMessage ? 
                           accessManager.getAdjustedTextSize(20) : 
                           accessManager.getAdjustedTextSize(16);
    // Aplicar multiplicador de tamaño
    textSizeValue *= textSizeMultiplier;
    textSize(textSizeValue);
    
    // Aplicar alfa al color del texto
    fill(red(textColor), green(textColor), blue(textColor), alpha);
    
    // Destacar mensajes educativos con fondo
    if (isEcoMessage) {
      // Dibujar fondo semitransparente para mejor legibilidad
      color bgColor = accessManager.highContrastMode ? 
                    color(0, alpha * 0.7) : 
                    color(30, 30, 30, alpha * 0.7);
      float padding = 10;
      rectMode(CENTER);
      noStroke();
      fill(bgColor);
      rect(x, y, textWidth(message) + padding * 2, textSizeValue * 1.5, 8);
      
      // Texto con contorno para mensajes destacados
      fill(red(textColor), green(textColor), blue(textColor), alpha);
    }
    
    // Dibujar sombra para mejor legibilidad en modo de alto contraste
    if (accessManager.highContrastMode) {
      // Dibujar sombra
      fill(0, 0, 0, alpha * 0.7);
      text(message, x + 1, y + 1);
      
      // Dibujar texto principal
      fill(red(textColor), green(textColor), blue(textColor), alpha);
    }
    
    text(message, x, y);
    
    popStyle();
    popMatrix();
  }
  
  boolean isDead() {
    return lifetime >= maxLifetime;
  }
  
  boolean isExpired() {
    // Alias para isDead() para coincidir con la llamada al método en CollectibleManager
    return isDead();
  }
  
  // Configura la velocidad de movimiento del texto
  void setVelocity(float hSpeed, float vSpeed) {
    this.hSpeed = hSpeed;
    this.vSpeed = vSpeed;
  }
  
  // Configura el tamaño del texto mediante un multiplicador
  void setSize(float sizeMultiplier) {
    this.textSizeMultiplier = sizeMultiplier;
  }
  
  // Aumenta la duración del texto en pantalla
  void setDuration(int frames) {
    this.maxLifetime = frames;
  }
} 