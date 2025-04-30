class Platform {
  float x, y;
  float width, height;
  float speed;
  boolean isMoving;
  float moveAmplitude = 40;
  float moveSpeed = 0.03;
  float moveOffset;
  float initialY;
  color platformColor;
  boolean hasPowerUp = false;
  boolean hasCollectible = false;
  
  // Tipo de plataforma
  // 0 = estándar, 1 = rebote, 2 = móvil vertical, 3 = móvil horizontal
  int type;
  
  // Referencia de accesibilidad
  AccessibilityManager accessManager;
  
  Platform(float x, float y, float w, float h, float speed, int type, AccessibilityManager accessManager) {
    this.x = x;
    this.y = y;
    this.width = w;
    this.height = h;
    this.speed = speed;
    this.type = type;
    this.initialY = y;
    this.moveOffset = random(TWO_PI);
    this.isMoving = (type == 2 || type == 3);
    this.accessManager = accessManager;
    
    // Asignar color según tipo
    setupVisuals();
    
    // Probabilidad de tener un coleccionable
    this.hasCollectible = random(1) < 0.4;
    
    // Probabilidad de tener un power-up (menor)
    // Solo permitir powerup si la plataforma es lo suficientemente grande
    // o si no hay coleccionable para evitar superposiciones
    if (this.width >= 80 || !this.hasCollectible) {
      this.hasPowerUp = random(1) < 0.15;
    } else {
      this.hasPowerUp = false;
    }
  }
  
  // Constructor simplificado con valores predeterminados
  Platform(float x, float y, float w) {
    this(x, y, w, 15, 5.0, 0, new AccessibilityManager());
  }
  
  // Constructor usado en PlatformManager
  Platform(float x, float y, float w, AccessibilityManager accessManager) {
    this(x, y, w, 15, 5.0, 0, accessManager);
  }
  
  // Otro constructor con altura
  Platform(float x, float y, float w, float h) {
    this(x, y, w, h, 5.0, 0, new AccessibilityManager());
  }
  
  void setupVisuals() {
    // Colores según tipo de plataforma - usando tonos de jungla/tierra
    switch(type) {
      case 0: // Estándar
        platformColor = color(110, 85, 47); // Tono marrón tierra
        break;
      case 1: // Rebote
        platformColor = color(76, 153, 0); // Verde brillante
        break;
      case 2: // Móvil vertical
        platformColor = color(147, 196, 125); // Verde claro
        break;
      case 3: // Móvil horizontal
        platformColor = color(175, 139, 78); // Marrón claro/tostado
        break;
      default:
        platformColor = color(110, 85, 47); // Marrón por defecto
    }
  }
  
  void update() {
    // Desplazamiento horizontal
    x -= speed;
    
    // Movimiento según tipo
    if (type == 2) {
      // Movimiento vertical
      y = initialY + sin((millis() * moveSpeed) + moveOffset) * moveAmplitude;
    } else if (type == 3) {
      // Movimiento horizontal (oscilación adicional)
      x += sin((millis() * moveSpeed * 1.5) + moveOffset) * 2;
    }
  }
  
  // Método update sobrecargado que acepta un parámetro de velocidad
  void update(float newSpeed) {
    // Actualizar la velocidad
    this.speed = newSpeed;
    
    // Llamar al método update estándar
    update();
  }
  
  void display() {
    pushStyle();
    
    // Dibujar plataforma
    rectMode(CORNER);
    
    // Color ajustado para accesibilidad
    color displayColor = accessManager.getForegroundColor(platformColor);
    fill(displayColor);
    
    // Forma base de la plataforma
    rect(x, y, width, height, 4); // Esquinas ligeramente redondeadas
    
    // Añadir hierba/musgo en la parte superior de plataformas estándar
    if (type == 0) {
      // Borde superior más oscuro
      fill(accessManager.getForegroundColor(color(80, 65, 27)));
      rect(x, y-2, width, 3, 2);
      
      // Mechones de hierba en la parte superior
      fill(accessManager.getForegroundColor(color(76, 153, 0))); // Verde
      for (float i = x + 5; i < x + width - 5; i += random(5, 10)) {
        rect(i, y-4, 3, 3, 1);
      }
    }
    
    // Agregar efectos visuales según tipo
    if (type == 1) {
      // Plataforma de rebote con indicador visual
      rect(x, y, width, height, 4);
      
      // Flechas de rebote
      fill(accessManager.getForegroundColor(color(255, 255, 100)));
      triangle(x + width/4, y - 10, x + width/2, y - 20, x + 3*width/4, y - 10);
    } else if (isMoving) {
      // Plataformas móviles con patrón
      rect(x, y, width, height, 4);
      
      // Patrón de movimiento
      float patternOffset = (millis() * 0.01) % width;
      stroke(accessManager.getForegroundColor(color(255, 255, 255, 150)));
      strokeWeight(2);
      
      if (type == 2) {
        // Líneas verticales para movimiento vertical
        for (float i = patternOffset; i < width; i += 10) {
          line(x + i, y, x + i, y + height);
        }
      } else if (type == 3) {
        // Líneas horizontales para movimiento horizontal
        for (float i = patternOffset; i < height; i += 6) {
          line(x, y + i, x + width, y + i);
        }
      }
    }
    
    // Indicador de coleccionable o power-up
    if (hasCollectible || hasPowerUp) {
      float indicatorSize = 8;
      
      if (hasCollectible && hasPowerUp) {
        // Si hay ambos, mostrar coleccionable a la izquierda
        fill(accessManager.getForegroundColor(color(255, 215, 0))); // Dorado
        ellipse(x + width/4, y - indicatorSize, indicatorSize*2, indicatorSize*2);
        
        // Y power-up a la derecha
        fill(accessManager.getForegroundColor(color(50, 255, 50))); // Verde
        star(x + 3*width/4, y - indicatorSize*2, indicatorSize, indicatorSize*2, 5);
      } else if (hasCollectible) {
        // Solo coleccionable
        fill(accessManager.getForegroundColor(color(255, 215, 0))); // Dorado
        ellipse(x + width/2, y - indicatorSize, indicatorSize*2, indicatorSize*2);
      } else if (hasPowerUp) {
        // Solo power-up
        fill(accessManager.getForegroundColor(color(50, 255, 50))); // Verde
        star(x + width/2, y - indicatorSize*2, indicatorSize, indicatorSize*2, 5);
      }
    }
    
    popStyle();
  }
  
  // Función para dibujar estrellas (indicador de power-up)
  void star(float x, float y, float radius1, float radius2, int npoints) {
    float angle = TWO_PI / npoints;
    float halfAngle = angle/2.0;
    beginShape();
    for (float a = 0; a < TWO_PI; a += angle) {
      float sx = x + cos(a) * radius2;
      float sy = y + sin(a) * radius2;
      vertex(sx, sy);
      sx = x + cos(a+halfAngle) * radius1;
      sy = y + sin(a+halfAngle) * radius1;
      vertex(sx, sy);
    }
    endShape(CLOSE);
  }
  
  boolean isOnScreen() {
    return x + width > 0;
  }
  
  // Comprobar si un punto está encima de la plataforma
  boolean isPointAbove(float px, float py) {
    return (px >= x && px <= x + width && 
            abs(py - y) < 5); // Pequeño margen para detección
  }
  
  // Comprobar si el jugador está sobre la plataforma
  boolean isPlayerOn(Player player) {
    float playerBottom = player.y;
    float playerX = player.x;
    
    // El jugador está sobre la plataforma si:
    // 1. La base del jugador está cerca del tope de la plataforma
    // 2. El jugador está horizontalmente dentro de la plataforma
    // 3. El jugador está cayendo (velocidad vertical positiva)
    
    // Ampliamos el rango de detección vertical para mejorar la colisión
    // y aseguramos que detecte plataformas con movimiento rápido
    boolean verticalMatch = (playerBottom >= y - 10 && playerBottom <= y + 10);
    boolean horizontalMatch = (playerX >= x && playerX <= x + width);
    boolean isFalling = (player.vSpeed >= 0);
    
    // Para plataformas móviles verticales, aumentamos aún más el rango de detección
    if (type == 2 && isMoving) {
        // Incrementamos la tolerancia vertical para plataformas móviles
        verticalMatch = (playerBottom >= y - 15 && playerBottom <= y + 15);
    }
    
    return verticalMatch && horizontalMatch && isFalling;
  }
  
  // Comprobar si esta plataforma se superpone con otra
  boolean overlapsWith(Platform other) {
    // Comprobar superposición horizontal
    boolean xOverlap = (this.x + this.width > other.x) && (this.x < other.x + other.width);
    
    // Comprobar superposición vertical (con un pequeño margen de variación)
    float yBuffer = 40; // Permitir que las plataformas estén al menos a esta distancia verticalmente
    boolean yOverlap = (this.y + this.height + yBuffer > other.y) && (this.y < other.y + other.height + yBuffer);
    
    return xOverlap && yOverlap;
  }
} 