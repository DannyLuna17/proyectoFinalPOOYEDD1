class Obstacle {
  float x, y;
  float w, h;
  float speed;
  
  // Propiedades de comportamiento
  int type; // 0 = estándar, 1 = bajo (saltar), 2 = alto (deslizar), 3 = móvil (oscilante)
  float initialY; // Posición Y inicial para obstáculos móviles
  float moveAmplitude = 50; // Rango de movimiento
  float moveSpeed = 0.05; // Velocidad de oscilación
  float moveOffset = 0; // Para patrones variados
  
  // Colisión y seguimiento
  boolean isColliding = false; // Si está colisionando con el jugador
  boolean avoided = false;     // Si el jugador ha evitado este obstáculo
  
  // Propiedades visuales
  color obstacleColor;
  
  // Indicador de advertencia
  boolean hasWarning = false;
  float warningAlpha = 255; // Para efecto de parpadeo
  
  Obstacle(float x, float y, float w, float h, float speed, int type) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.speed = speed;
    this.type = type;
    this.initialY = y;
    
    // Inicializar seguimiento de colisión
    this.isColliding = false;
    this.avoided = false;
    
    // Offset de oscilación aleatorio
    this.moveOffset = random(TWO_PI);
    
    // Asignar color según tipo
    setupVisuals();
  }
  
  // Constructor para pruebas
  Obstacle(float x, float y, float w, float h, int type) {
    this(x, y, w, h, 5.0, type); // Velocidad por defecto 5.0
  }
  
  void setupVisuals() {
    // Asignar colores según tipo
    switch(type) {
      case 0: // Estándar
        obstacleColor = color(0, 0, 255);
        break;
      case 1: // Bajo (saltar)
        obstacleColor = color(255, 0, 0);
        break;
      case 2: // Alto (deslizar)
        obstacleColor = color(0, 255, 0);
        break;
      case 3: // Móvil
        obstacleColor = color(255, 180, 0);
        break;
      default:
        obstacleColor = color(0, 0, 255);
    }
    
    // Advertencia para obstáculos difíciles
    if (type == 3 || speed > 7) {
      hasWarning = true;
    }
  }
  
  void update() {
    // Mover de derecha a izquierda
    x -= speed;
    
    // Movimiento vertical para oscilantes
    if (type == 3) {
      // Oscilación con onda sinusoidal
      y = initialY - sin((millis() * moveSpeed) + moveOffset) * moveAmplitude;
    }
    
    // Actualizar advertencia
    if (hasWarning) {
      // Efecto de parpadeo
      warningAlpha = 127 + 127 * sin(millis() * 0.01);
    }
  }
  
  void display() {
    pushMatrix();
    pushStyle();
    
    // Dibujar advertencia si es necesario
    if (hasWarning && x > width * 0.7) {
      fill(255, 0, 0, warningAlpha);
      triangle(x - w/2 - 20, y - h - 30, 
               x - w/2 + 20, y - h - 30, 
               x - w/2, y - h - 10);
    }
    
    // Dibujar el obstáculo con color adecuado
    fill(obstacleColor);
    
    // Dibujar formas según tipo
    switch(type) {
      case 0: // Estándar - rectángulo
        rect(x - w/2, y - h, w, h);
        break;
      case 1: // Bajo - rectángulo más ancho y corto
        rect(x - w/2, y - h/2, w, h/2);
        break;
      case 2: // Alto - rectángulo más alto y delgado
        rect(x - w/4, y - h*1.5, w/2, h*1.5);
        break;
      case 3: // Móvil - círculo o elipse
        ellipse(x, y - h/2, w, h);
        // Líneas indicadoras de movimiento
        stroke(255);
        line(x - w/4, y - h/2 - 10, x + w/4, y - h/2 - 10);
        line(x - w/4, y - h/2 + 10, x + w/4, y - h/2 + 10);
        break;
    }
    
    popStyle();
    popMatrix();
  }
  
  boolean isOffscreen() {
    return x < -w;
  }
  
  // Obtener parte superior para detección de colisiones
  float getTop() {
    switch(type) {
      case 0: return y - h;
      case 1: return y - h/2;
      case 2: return y - h*1.5;
      case 3: return y - h/2 - h/2;
      default: return y - h;
    }
  }
  
  // Obtener altura real para detección de colisiones
  float getHeight() {
    switch(type) {
      case 0: return h;
      case 1: return h/2;
      case 2: return h*1.5;
      case 3: return h;
      default: return h;
    }
  }
} 