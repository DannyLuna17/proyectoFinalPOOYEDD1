class Player {
  float x, y;
  float size;
  float groundY;
  float vSpeed = 0;
  float gravity = 0.5;
  float jumpForce = -12;
  float maxJumpForce = -12;
  boolean isJumping = false;
  boolean isSliding = false;
  boolean spacePressed = false;
  int jumpHoldTime = 0;
  int maxJumpHoldTime = 15;
  
  // Deslizamiento
  int slideDuration = 0;
  int maxSlideDuration = 45;
  
  // Salud
  int health = 3;
  boolean isInvincible = false;
  int invincibilityTimer = 0;
  int invincibilityDuration = 90;
  
  // Colores
  color normalColor = color(255, 0, 0);
  color slidingColor = color(200, 0, 100);
  color invincibleColor = color(255, 255, 0);
  color currentColor;
  
  // Estados del ecosistema
  color goodEnvColor = color(255, 50, 50);
  color warningEnvColor = color(200, 50, 0);
  color criticalEnvColor = color(150, 0, 0);
  
  // Power-ups
  boolean hasShield = false;
  boolean hasSpeedBoost = false;
  boolean hasDoublePoints = false;
  float baseSpeed = 0;
  float speedMultiplier = 1.0;
  int pointsMultiplier = 1;
  
  // Timers de power-ups
  int shieldDuration = 0;
  int shieldTimer = 0;
  int speedBoostDuration = 0;
  int speedBoostTimer = 0;
  int doublePointsDuration = 0;
  int doublePointsTimer = 0;
  
  // Escudo
  color shieldColor = color(100, 255, 100, 100);
  float shieldSize = 0;
  float shieldPulse = 0;
  
  // Variables para plataformas
  boolean isOnPlatform = false;
  Platform currentPlatform = null;
  float lastPlatformY = 0;
  boolean isPlatformJump = false;
  float platformJumpBonus = 1.2; // Bonus de salto en plataformas
  
  // Referencias externas
  AccessibilityManager accessManager;
  SoundManager soundManager;
  
  // Constructor simplificado
  Player(float x, float groundY) {
    // Crear un AccessibilityManager y pasarlo tanto al constructor padre como al SoundManager
    AccessibilityManager am = new AccessibilityManager();
    SoundManager sm = new SoundManager(am);
    this.x = x;
    this.groundY = groundY;
    this.y = groundY;
    this.size = 50;
    this.currentColor = normalColor;
    this.baseSpeed = 0;
    this.accessManager = am;
    this.soundManager = sm;
  }
  
  // Constructor principal
  Player(float x, float groundY, AccessibilityManager accessManager, SoundManager soundManager) {
    this.x = x;
    this.groundY = groundY;
    this.y = groundY;
    this.size = 50;
    this.currentColor = normalColor;
    this.baseSpeed = 0;
    this.accessManager = accessManager;
    this.soundManager = soundManager;
  }
  
  void update() {
    handleJump();
    handleSlide();
    
    if (isInvincible) {
      invincibilityTimer++;
      // Parpadeo
      if (invincibilityTimer % 10 < 5) {
        currentColor = invincibleColor;
      } else {
        currentColor = normalColor;
      }
      
      if (invincibilityTimer >= invincibilityDuration) {
        isInvincible = false;
        invincibilityTimer = 0;
        if (!isSliding) {
          currentColor = normalColor;
        }
      }
    }
    
    // Efecto escudo
    if (hasShield) {
      shieldPulse = (shieldPulse + 0.05) % TWO_PI;
      shieldSize = size * 1.5 + sin(shieldPulse) * 5;
    }
    
    // Actualizar timers de power-ups
    if (hasShield && shieldDuration > 0) {
      shieldTimer++;
      if (shieldTimer >= shieldDuration) {
        deactivateShield();
      }
    }
    
    if (hasSpeedBoost && speedBoostDuration > 0) {
      speedBoostTimer++;
      if (speedBoostTimer >= speedBoostDuration) {
        deactivateSpeedBoost();
      }
    }
    
    if (hasDoublePoints && doublePointsDuration > 0) {
      doublePointsTimer++;
      if (doublePointsTimer >= doublePointsDuration) {
        deactivateDoublePoints();
      }
    }
  }
  
  void handleJump() {
    // Si estamos en plataforma y no saltando, ajustar Y
    if (isOnPlatform && !isJumping && currentPlatform != null) {
      // Para plataformas móviles, actualizamos la posición Y constantemente
      y = currentPlatform.y;
      
      // Mantener velocidad vertical a cero cuando estamos parados sobre una plataforma
      vSpeed = 0;
    }
    
    if (spacePressed && isJumping && jumpHoldTime < maxJumpHoldTime) {
      jumpHoldTime++;
      // Si saltamos desde una plataforma, aplicar bonus de salto
      if (isPlatformJump) {
        vSpeed = map(jumpHoldTime, 0, maxJumpHoldTime, jumpForce * platformJumpBonus, maxJumpForce * platformJumpBonus);
      } else {
        vSpeed = map(jumpHoldTime, 0, maxJumpHoldTime, jumpForce, maxJumpForce);
      }
    }
    
    if (isJumping) {
      vSpeed += gravity;
      y += vSpeed;
      
      // Comprobar si aterrizamos en el suelo
      if (y >= groundY) {
        y = groundY;
        vSpeed = 0;
        isJumping = false;
        isPlatformJump = false;
        jumpHoldTime = 0;
        isOnPlatform = false;
        currentPlatform = null;
      }
    }
  }
  
  // Comprobar colisión con plataformas
  void checkPlatformCollision(ArrayList<Platform> platforms) {
    // Si estamos deslizándonos, no interactuamos con plataformas
    if (isSliding) {
      return;
    }
    
    // Resetear estado de plataforma si no estamos saltando
    if (!isJumping && !isOnPlatform) {
      isOnPlatform = false;
      currentPlatform = null;
    }
    
    // Comprobar cada plataforma
    boolean foundPlatform = false;
    
    // Primera pasada: priorizar plataforma actual si todavía estamos sobre ella
    if (isOnPlatform && currentPlatform != null) {
      if (currentPlatform.isPlayerOn(this)) {
        foundPlatform = true;
        y = currentPlatform.y; // Asegurar que seguimos la plataforma
        lastPlatformY = currentPlatform.y;
        
        // Si estábamos cayendo, resetear estado de salto
        if (isJumping && vSpeed > 0) {
          vSpeed = 0;
          isJumping = false;
          jumpHoldTime = 0;
        }
      }
    }
    
    // Si no estamos en la plataforma actual, buscar otras
    if (!foundPlatform) {
      for (Platform platform : platforms) {
        // Evitar volver a comprobar la plataforma actual si ya lo hicimos
        if (platform == currentPlatform) continue;
        
        // Comprobar si el jugador está sobre la plataforma
        if (platform.isPlayerOn(this)) {
          // Estamos sobre una plataforma
          isOnPlatform = true;
          currentPlatform = platform;
          lastPlatformY = platform.y;
          
          // Si estábamos cayendo (saltando), aterrizar en la plataforma
          if (isJumping && vSpeed > 0) {
            y = platform.y;
            vSpeed = 0;
            isJumping = false;
            jumpHoldTime = 0;
            
            // Comprobar si es plataforma de rebote
            if (platform.type == 1) {
              // Plataforma de rebote - salto automático más fuerte
              jump();
              vSpeed = jumpForce * 1.3;
              isPlatformJump = true;
              soundManager.playCollectSound(); // Efecto de rebote
            }
          }
          
          foundPlatform = true;
          break;
        }
      }
    }
    
    // Si no encontramos plataforma y estábamos en una, comenzar a caer
    if (!foundPlatform && isOnPlatform && !isJumping) {
      isOnPlatform = false;
      currentPlatform = null;
      isJumping = true;
      vSpeed = 0; // Comenzar a caer sin velocidad inicial
    }
  }
  
  void handleSlide() {
    if (isSliding) {
      slideDuration++;
      currentColor = slidingColor;
      
      if (slideDuration >= maxSlideDuration) {
        stopSliding();
      }
    }
  }
  
  void updateEnvironmentalAppearance(EcoSystem ecoSystem) {
    if (!isSliding && !isInvincible) {
      if (ecoSystem.isInGoodState()) {
        normalColor = goodEnvColor;
      } else if (ecoSystem.isInWarningState()) {
        normalColor = warningEnvColor;
      } else if (ecoSystem.isInCriticalState()) {
        normalColor = criticalEnvColor;
      }
      currentColor = normalColor;
    }
  }
  
  void display() {
    ellipseMode(CENTER);
    rectMode(CORNER);
    
    color adjustedCurrentColor = accessManager.getForegroundColor(currentColor);
    
    // Dibujar escudo
    if (hasShield) {
      pushStyle();
      color adjustedShieldColor = accessManager.getForegroundColor(shieldColor);
      fill(adjustedShieldColor);
      ellipse(x, y - size/2, shieldSize, shieldSize);
      popStyle();
    }
    
    // Dibujar jugador
    fill(adjustedCurrentColor);
    
    if (isSliding) {
      // Forma deslizamiento
      ellipse(x, y + size/4, size * 1.2, size/2);
    } else {
      // Forma normal
      ellipse(x, y - size/2, size, size);
    }
    
    // Efecto de velocidad
    if (hasSpeedBoost) {
      pushStyle();
      fill(accessManager.getForegroundColor(color(255, 50, 50, 150)));
      for (int i = 1; i <= 3; i++) {
        float lineX = x - i * 10;
        float lineWidth = 5;
        float lineHeight = isSliding ? size/2 : size;
        float lineY = isSliding ? y + size/4 : y - size/2;
        rect(lineX, lineY, lineWidth, lineHeight);
      }
      popStyle();
    }
    
    // Indicador de puntos dobles
    if (hasDoublePoints) {
      pushStyle();
      fill(accessManager.getForegroundColor(color(255, 100, 255)));
      textAlign(CENTER);
      textSize(accessManager.getAdjustedTextSize(14));
      text("2x", x, y - size - 10);
      popStyle();
    }
    
    // Indicador de plataforma
    if (isOnPlatform && currentPlatform != null) {
      pushStyle();
      stroke(adjustedCurrentColor);
      strokeWeight(2);
      line(x - 15, y + 5, x + 15, y + 5);
      popStyle();
    }
  }
  
  void jump() {
    if ((!isJumping && !isSliding) || isOnPlatform) {
      isJumping = true;
      spacePressed = true;
      
      // Salto desde plataforma
      if (isOnPlatform) {
        isPlatformJump = true;
        vSpeed = jumpForce * platformJumpBonus; // Salto más potente desde plataformas
      } else {
        isPlatformJump = false;
        vSpeed = jumpForce;
      }
      
      jumpHoldTime = 0;
      isOnPlatform = false;
      
      soundManager.playJumpSound();
      
      if (accessManager.visualCuesForAudio) {
        accessManager.displaySoundCue("jump", x, y - size);
      }
    }
  }
  
  void releaseJump() {
    spacePressed = false;
  }
  
  void slide() {
    if (!isJumping) {
      isSliding = true;
      slideDuration = 0;
      currentColor = slidingColor;
      
      // Si estábamos en una plataforma, caer
      if (isOnPlatform) {
        isOnPlatform = false;
        currentPlatform = null;
        isJumping = true;
        vSpeed = 0;
      }
      
      soundManager.playMenuSound();
      
      if (accessManager.visualCuesForAudio) {
        accessManager.displaySoundCue("slide", x, y + size/4);
      }
    }
  }
  
  void stopSliding() {
    isSliding = false;
    slideDuration = 0;
    if (!isInvincible) {
      currentColor = normalColor;
    }
  }
  
  // Para saber si está en el aire (no en el suelo ni en plataforma)
  boolean isInAir() {
    return isJumping && !isOnPlatform && y < groundY;
  }
  
  // Para saber si está muerto
  boolean isDead() {
    return health <= 0;
  }
  
  // Método para tomar daño
  void takeDamage() {
    if (!isInvincible && !hasShield) {
      health--;
      isInvincible = true;
      invincibilityTimer = 0;
      
      // Efecto de daño
      soundManager.playHitSound();
    } else if (hasShield) {
      // El escudo absorbe el golpe
      deactivateShield();
      soundManager.playShieldBreakSound();
    }
  }
  
  // Métodos para power-ups
  void activateShield(int duration) {
    hasShield = true;
    shieldDuration = duration;
    shieldTimer = 0;
  }
  
  void deactivateShield() {
    hasShield = false;
    shieldDuration = 0;
    shieldTimer = 0;
  }
  
  void activateSpeedBoost(int duration, float multiplier) {
    hasSpeedBoost = true;
    speedBoostDuration = duration;
    speedBoostTimer = 0;
    speedMultiplier = multiplier;
  }
  
  void deactivateSpeedBoost() {
    hasSpeedBoost = false;
    speedBoostDuration = 0;
    speedBoostTimer = 0;
    speedMultiplier = 1.0;
  }
  
  void activateDoublePoints(int duration) {
    hasDoublePoints = true;
    doublePointsDuration = duration;
    doublePointsTimer = 0;
    pointsMultiplier = 2;
  }
  
  void deactivateDoublePoints() {
    hasDoublePoints = false;
    doublePointsDuration = 0;
    doublePointsTimer = 0;
    pointsMultiplier = 1;
  }
  
  // Método para detectar colisión con obstáculos
  boolean isColliding(Obstacle obstacle) {
    // Obtener dimensiones del jugador
    float playerWidth = isSliding ? size * 1.2 : size;
    float playerHeight = isSliding ? size/2 : size;
    float playerBottom = y;
    float playerTop = isSliding ? playerBottom - playerHeight/2 : playerBottom - playerHeight;
    float playerLeft = x - playerWidth/2;
    float playerRight = x + playerWidth/2;
    
    // Obtener dimensiones del obstáculo
    float obstacleTop = obstacle.y - obstacle.h;
    float obstacleBottom = obstacle.y;
    float obstacleLeft = obstacle.x - obstacle.w/2;
    float obstacleRight = obstacle.x + obstacle.w/2;
    
    // Si el jugador es invencible, no hay colisión
    if (isInvincible) return false;
    
    // Comprobar si hay solapamiento en ambas dimensiones
    return (playerRight > obstacleLeft && 
            playerLeft < obstacleRight && 
            playerBottom > obstacleTop && 
            playerTop < obstacleBottom);
  }
  
  // Método para comprobar si estamos recogiendo un coleccionable
  boolean isCollectingItem(Collectible collectible) {
    // Calcular distancia entre el centro del jugador y el centro del coleccionable
    float distance = dist(x, y - size/2, collectible.x, collectible.y);
    
    // Considerar colisión si la distancia es menor que la suma de los radios
    float collectionRadius = (size/2 + collectible.size/2) * 0.8;
    
    return distance < collectionRadius;
  }
  
  // Dibujar barra de salud
  void drawHealthBar(float x, float y, float w, float h) {
    pushStyle();
    rectMode(CORNER);
    
    // Fondo de la barra
    fill(accessManager.getBackgroundColor(color(100)));
    rect(x, y, w, h);
    
    // Configuración para dibujar corazones
    int maxHearts = 3;
    float heartSize = h * 0.8;
    float heartSpacing = (w - maxHearts * heartSize) / (maxHearts + 1);
    
    // Dibujar corazones
    for (int i = 0; i < maxHearts; i++) {
      // Posición del corazón actual
      float heartX = x + heartSpacing + i * (heartSize + heartSpacing);
      float heartY = y + (h - heartSize) / 2;
      
      // Dibujar corazón lleno o vacío según la salud del jugador
      if (i < health) {
        // Corazón lleno
        fill(accessManager.getForegroundColor(color(255, 0, 0)));
      } else {
        // Corazón vacío
        fill(accessManager.getForegroundColor(color(100, 0, 0)));
      }
      
      // Dibujar corazón
      drawHeartShape(heartX, heartY, heartSize);
    }
    
    // Borde
    stroke(accessManager.getForegroundColor(color(255)));
    noFill();
    rect(x, y, w, h);
    
    popStyle();
  }
  
  // Dibuja la forma de un corazón
  void drawHeartShape(float x, float y, float size) {
    pushMatrix();
    translate(x + size/2, y + size/2);
    
    beginShape();
    // Un corazón hecho con vértices
    vertex(0, size/4);
    bezierVertex(0, 0, -size/2, 0, -size/2, -size/4);
    bezierVertex(-size/2, -size/2, 0, -size/2, 0, -size/4);
    bezierVertex(0, -size/2, size/2, -size/2, size/2, -size/4);
    bezierVertex(size/2, 0, 0, 0, 0, size/4);
    endShape(CLOSE);
    
    popMatrix();
  }
} 