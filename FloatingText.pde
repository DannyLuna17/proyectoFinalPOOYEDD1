class FloatingText {
  String message;
  float x, y;
  color textColor;
  float alpha;
  float vSpeed;
  int lifetime;
  int maxLifetime;
  
  FloatingText(String message, float x, float y, color textColor) {
    this.message = message;
    this.x = x;
    this.y = y;
    this.textColor = textColor;
    this.alpha = 255;
    this.vSpeed = -1.5; // Movimiento hacia arriba
    this.lifetime = 0;
    this.maxLifetime = 60; // 1 segundo a 60 fps
  }
  
  void update() {
    // Mover hacia arriba
    y += vSpeed;
    
    // Desvanecer
    lifetime++;
    alpha = map(lifetime, 0, maxLifetime, 255, 0);
  }
  
  void display() {
    pushMatrix();
    pushStyle();
    
    textAlign(CENTER);
    // Usar tamaño ajustado del manager de accesibilidad
    float textSizeValue = accessManager.getAdjustedTextSize(16);
    textSize(textSizeValue);
    
    // Aplicar alpha al color del texto
    fill(red(textColor), green(textColor), blue(textColor), alpha);
    
    // Dibujar texto con sombra para mejorar legibilidad en modo de alto contraste
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
} 