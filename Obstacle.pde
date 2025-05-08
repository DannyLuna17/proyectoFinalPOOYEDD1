class Obstacle {
  float x, y;
  float w, h;
  float speed;
  
  // Propiedades de comportamiento
  int type; // 0 = estándar, 1 = bajo (saltar), 2 = alto (deslizar), 3 = móvil (oscilante), 4 = nube tóxica
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
  
  // Propiedades para ayuda visual
  boolean showHint = false;
  String hintText = "";
  int hintTimer = 0;
  int hintDuration = 90; // 1.5 segundos
  float hintOpacity = 255;
  
  // Referencia de accesibilidad
  AccessibilityManager accessManager;
  
  // Referencia al gestor de assets
  AssetManager assetManager;
  
  // Propiedades para apariencia tóxica y daño
  boolean isToxic = false;
  float damageMultiplier = 1.0;
  
  Obstacle(float x, float y, float w, float h, float speed, int type, AccessibilityManager accessManager) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.speed = speed;
    this.type = type;
    this.initialY = y;
    this.accessManager = accessManager;
    
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
    this(x, y, w, h, 5.0, type, new AccessibilityManager()); // Velocidad por defecto 5.0, accessibility manager default
  }
  
  // Constructor con AssetManager
  Obstacle(float x, float y, float w, float h, float speed, int type, AccessibilityManager accessManager, AssetManager assetManager) {
    this(x, y, w, h, speed, type, accessManager);
    this.assetManager = assetManager;
  }
  
  void setupVisuals() {
    // Asignar colores según tipo
    switch(type) {
      case 0: // Estándar
        obstacleColor = color(0, 0, 255);
        hintText = "";
        break;
      case 1: // Bajo (saltar) - basura
        obstacleColor = color(100, 50, 0); // Color marrón para la basura
        hintText = "¡SALTA!";
        break;
      case 2: // Alto (deslizar)
        obstacleColor = color(0, 255, 0);
        hintText = "¡DESLIZA!";
        break;
      case 3: // Móvil
        obstacleColor = color(255, 180, 0);
        hintText = "¡CUIDADO!";
        break;
      case 4: // Nube tóxica
        obstacleColor = color(120, 200, 50); // Color verde tóxico
        hintText = "¡TÓXICO!";
        break;
      default:
        obstacleColor = color(0, 0, 255);
        hintText = "";
    }
    
    // Advertencia para obstáculos difíciles
    if (type == 3 || type == 4 || speed > 7) {
      hasWarning = true;
    }
    
    // Mostrar pista visual solo a veces para no saturar
    // Principalmente para nuevos jugadores
    showHint = (random(1) < 0.4);
  }
  
  void update() {
    // Mover de derecha a izquierda
    x -= speed;
    
    // Movimiento vertical para oscilantes
    // Ya no usamos obstáculos móviles verticales, pero dejamos este código comentado por referencia
    /* 
    if (type == 3) {
      // Oscilación con onda sinusoidal
      y = initialY - sin((millis() * moveSpeed) + moveOffset) * moveAmplitude;
    }
    */
    
    // Actualizar advertencia
    if (hasWarning) {
      // Efecto de parpadeo
      warningAlpha = 127 + 127 * sin(millis() * 0.01);
    }
    
    // Actualizar timer de pista visual
    if (showHint && hintTimer < hintDuration) {
      hintTimer++;
      
      // Desvanecer al final
      if (hintTimer > hintDuration * 0.7) {
        hintOpacity = map(hintTimer, hintDuration * 0.7, hintDuration, 255, 0);
      }
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
    pushMatrix();
    pushStyle();
    
    // Dibujar advertencia si es necesario
    if (hasWarning && x > width * 0.7) {
      fill(255, 0, 0, warningAlpha);
      triangle(x - w/2 - 20, y - h - 30, 
               x - w/2 + 20, y - h - 30, 
               x - w/2, y - h - 10);
    }
    
    // Determinar si usar imágenes o formas geométricas basado en accesibilidad y disponibilidad
    boolean useImages = assetManager != null && 
                       assetManager.getFactoryObstacleImage() != null && 
                       !accessManager.highContrastMode;
    
    // Ajustar color para modo daltónico si está activo
    color displayColor = obstacleColor;
    if (accessManager.colorBlindMode) {
      // Ajustar colores para que sean distinguibles en daltonismo
      switch(type) {
        case 0: // Estándar - azul más brillante
          displayColor = color(50, 50, 255);
          break;
        case 1: // Bajo (saltar) - rojo más oscuro
          displayColor = color(200, 0, 0);
          break;
        case 2: // Alto (deslizar) - verde amarillento
          displayColor = color(180, 230, 50);
          break;
        case 3: // Móvil - naranja intenso
          displayColor = color(255, 140, 0);
          break;
        case 4: // Nube tóxica
          displayColor = color(120, 200, 50); // Color verde tóxico
          break;
      }
    }
    
    // Si está en modo alto contraste, usar patrones distintivos
    if (accessManager.highContrastMode) {
      switch(type) {
        case 0: // Estándar - sólido
          displayColor = color(255);
          break;
        case 1: // Bajo - rayas horizontales
          displayColor = color(255);
          drawPatternedRectangle(x - w/2, y - h/2, w, h/2, 1);
          break;
        case 2: // Alto - rayas verticales
          displayColor = color(255);
          drawPatternedRectangle(x - w/4, y - h*1.5, w/2, h*1.5, 2);
          break;
        case 3: // Móvil - puntos
          displayColor = color(255);
          drawPatternedCircle(x, y - h/2, w, 3);
          break;
        case 4: // Nube tóxica
          displayColor = color(255);
          drawPatternedCircle(x, y - h/2, w, 4);
          break;
      }
    } 
    else if (useImages) {
      // Usar imágenes para obstáculos si están disponibles
      imageMode(CENTER);
      PImage obstacleImage = assetManager.getObstacleImage(type);
      
      // Dibujar imagen apropiada según tipo con tint para mantener feedback visual
      tint(255); // Reset tint
      
      switch(type) {
        case 0: // Estándar
          image(obstacleImage, x, y - h/2, w, h);
          break;
        case 1: // Bajo - más ancho y corto - usar imagen de basura
          // Ajustar posición y tamaño para la imagen de basura
          image(obstacleImage, x, y - h/3, w * 1.3, h * 0.8);
          break;
        case 2: // Alto - más alto y delgado
          image(obstacleImage, x, y - h*0.75, w * 0.8, h * 1.5);
          break;
        case 3: // Móvil
          image(obstacleImage, x, y - h/2, w, h);
          break;
        case 4: // Nube tóxica
          // La nube flota un poco más arriba del suelo
          image(obstacleImage, x, y - h*1.2, w * 1.4, h);
          
          // Añadir un efecto de advertencia visual para la nube tóxica
          noStroke();
          fill(120, 255, 50, 30 + 20 * sin(millis() * 0.01));
          ellipse(x, y - h*1.2, w * 1.1, h * 0.7);
          break;
      }
      noTint(); // Reset tint
    } 
    else {
      // Dibujar el obstáculo con color adecuado
      fill(displayColor);
      
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
        case 3: // Ya no usamos obstáculos móviles circulares
          // Si por alguna razón aparece un tipo 3, lo dibujamos como un obstáculo estándar
          rect(x - w/2, y - h, w, h);
          break;
        case 4: // Nube tóxica
          // La nube tóxica está más arriba, así que ajustamos el área de colisión
          float obstacleLeft = x - w*0.7;
          float obstacleRight = x + w*0.7;
          float obstacleTop = y - h*1.6; // Más arriba
          float obstacleBottom = obstacleTop + h*0.8; // Más pequeña verticalmente
          
          // Dibujar la nube tóxica
          rect(obstacleLeft, obstacleTop, obstacleRight - obstacleLeft, obstacleBottom - obstacleTop);
          break;
      }
    }
    
    // Mostrar pista visual si está activa
    if (showHint && hintText.length() > 0 && hintTimer < hintDuration) {
      displayHint();
    }
    
    popStyle();
    popMatrix();
  }
  
  // Ayuda para dibujar texturas en modo alto contraste
  void drawPatternedRectangle(float x, float y, float w, float h, int patternType) {
    rectMode(CORNER);
    noFill();
    stroke(255);
    strokeWeight(2);
    
    // Contorno
    rect(x, y, w, h);
    
    // Patrón interior
    if (patternType == 1) {
      // Rayas horizontales
      for (int i = 0; i < h; i += 8) {
        line(x, y + i, x + w, y + i);
      }
    } else if (patternType == 2) {
      // Rayas verticales
      for (int i = 0; i < w; i += 8) {
        line(x + i, y, x + i, y + h);
      }
    }
  }
  
  void drawPatternedCircle(float x, float y, float diameter, int patternType) {
    noFill();
    stroke(255);
    strokeWeight(2);
    
    // Contorno
    ellipse(x, y, diameter, diameter);
    
    // Patrón interior
    if (patternType == 3) {
      // Puntos
      float radius = diameter / 2;
      for (int i = -int(radius*0.7); i < int(radius*0.7); i += 10) {
        for (int j = -int(radius*0.7); j < int(radius*0.7); j += 10) {
          if (i*i + j*j < radius*radius*0.5) {
            point(x + i, y + j);
          }
        }
      }
    } else if (patternType == 4) {
      // Puntos para la nube tóxica
      float radius = diameter / 2;
      for (int i = -int(radius*0.7); i < int(radius*0.7); i += 10) {
        for (int j = -int(radius*0.7); j < int(radius*0.7); j += 10) {
          if (i*i + j*j < radius*radius*0.5) {
            point(x + i, y + j);
          }
        }
      }
    }
  }
  
  void displayHint() {
    pushStyle();
    
    // Configurar texto
    textAlign(CENTER);
    textSize(16);
    fill(255, 255, 255, hintOpacity);
    
    // Dibujar fondo para mejor legibilidad
    rectMode(CENTER);
    float textWidth = textWidth(hintText);
    fill(0, 0, 0, hintOpacity * 0.7);
    rect(x, y - h - 25, textWidth + 10, 25, 5);
    
    // Dibujar texto
    fill(255, 255, 255, hintOpacity);
    text(hintText, x, y - h - 20);
    
    popStyle();
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
      case 4: return y - h*1.6; // Más arriba para la nube tóxica
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
      case 4: return h*0.8; // Más pequeña para la nube tóxica
      default: return h;
    }
  }
  
  // Detectar colisión con el jugador
  boolean checkCollision(Player player) {
    // Para obstáculo tipo círculo (móvil) - Ya no usamos este tipo
    // Tratamos todos los obstáculos como rectángulos ahora
    /* 
    if (type == 3) {
      float distance = dist(x, y - h/2, player.x, player.y - player.size/2);
      float collisionThreshold = (w/2 + player.size/2) * 0.8;
      return distance < collisionThreshold;
    }
    */
    
    // Ajuste especial para la nube tóxica (tipo 4)
    if (type == 4) {
      // La nube tóxica está más arriba, así que ajustamos el área de colisión
      float obstacleLeft = x - w*0.7;
      float obstacleRight = x + w*0.7;
      float obstacleTop = y - h*1.6; // Más arriba
      float obstacleBottom = obstacleTop + h*0.8; // Más pequeña verticalmente
      
      float playerLeft = player.x - player.size/2;
      float playerRight = player.x + player.size/2;
      float playerTop = player.isSliding ? 
                        player.y - player.size/4 : 
                        player.y - player.size;
      float playerBottom = player.isSliding ? 
                         player.y + player.size/4 : 
                         player.y;
                         
      // Verificar si los rectángulos se superponen
      return (playerLeft < obstacleRight && 
              playerRight > obstacleLeft && 
              playerTop < obstacleBottom && 
              playerBottom > obstacleTop);
    }
    
    // Para todos los demás tipos (rectángulos)
    float obstacleLeft = x - w/2;
    float obstacleRight = x + w/2;
    float obstacleTop = getTop();
    float obstacleBottom = obstacleTop + getHeight();
    
    float playerLeft = player.x - player.size/2;
    float playerRight = player.x + player.size/2;
    float playerTop = player.isSliding ? 
                      player.y - player.size/4 : 
                      player.y - player.size;
    float playerBottom = player.isSliding ? 
                         player.y + player.size/4 : 
                         player.y;
    
    // Verificar si los rectángulos se superponen
    return (playerLeft < obstacleRight && 
            playerRight > obstacleLeft && 
            playerTop < obstacleBottom && 
            playerBottom > obstacleTop);
  }
  
  // Obtener daño del obstáculo (puede ser sobreescrito en subclases)
  int getDamage() {
    // La nube tóxica hace más daño que un obstáculo normal
    // if (type == 4) {
    //   return 2; // Daño mayor para la nube tóxica
    // }
    return 1; // Valor de daño por defecto
  }
  
  // Configurar apariencia tóxica
  void setToxicAppearance(boolean isToxic) {
    this.isToxic = isToxic;
    
    // Ajustar propiedades visuales si es tóxico
    if (isToxic) {
      // Hacer que el color parezca más tóxico
      obstacleColor = lerpColor(obstacleColor, color(120, 200, 0), 0.5);
    }
  }
  
  // Configurar multiplicador de daño
  void setDamageMultiplier(float multiplier) {
    this.damageMultiplier = multiplier;
  }
} 