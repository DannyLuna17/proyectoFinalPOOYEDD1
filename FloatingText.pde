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
    
    float baseTextSize = isEcoMessage ? 32 : 26; 
    
    float textSizeValue = accessManager.getAdjustedTextSize(baseTextSize);
    
    textSizeValue *= textSizeMultiplier;
    textSize(textSizeValue);
    
    fill(red(textColor), green(textColor), blue(textColor), alpha);
    
    if (isEcoMessage) {
      color bgColor = accessManager.highContrastMode ? 
                    color(0, alpha * 0.8) : 
                    color(30, 30, 30, alpha * 0.8);
      float padding = 20; 
      rectMode(CENTER);
      noStroke();
      fill(bgColor);
      rect(x, y, textWidth(message) + padding * 2, textSizeValue * 1.6, 12); 
      
      fill(red(textColor), green(textColor), blue(textColor), alpha);
    } else {
      float textWidth = textWidth(message);
      float padding = 12; 
      
      boolean isNumeric = message.matches("^[\\+\\-]?\\d+.*");
      if (isNumeric) {
        rectMode(CENTER);
        noStroke();
        fill(0, 0, 0, alpha * 0.6); 
        rect(x, y, textWidth + padding * 2, textSizeValue * 1.3, 10); 
      }
    }
    
    if (accessManager.highContrastMode) {
      fill(0, 0, 0, alpha * 0.9);
      text(message, x + 3, y + 3); 
      
      fill(red(textColor), green(textColor), blue(textColor), alpha);
    } else {
      pushStyle();
      fill(0, 0, 0, alpha * 0.6); 
      text(message, x + 2, y + 2); 
      popStyle();
      
      fill(red(textColor), green(textColor), blue(textColor), alpha);
    }
    
    text(message, x, y+5);
    
    popStyle();
    popMatrix();
  }
  
  boolean isDead() {
    return lifetime >= maxLifetime;
  }
  
  boolean isExpired() {
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