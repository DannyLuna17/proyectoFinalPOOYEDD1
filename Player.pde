class Player {
  float x, y;
  float size;
  float groundY;
  float vSpeed = 0;
  float gravity = 0.5;
  float jumpForce = -14.5;
  float maxJumpForce = -16;
  boolean isJumping = false;
  boolean isSliding = false;
  boolean spacePressed = false;
  int jumpHoldTime = 0;
  int maxJumpHoldTime = 15;
  
  // Coyote time
  // Tiempo corto después de caer de una plataforma durante el cual aún se puede saltar
  int coyoteTime = 0;
  int maxCoyoteTime = 15; // Aproximadamente 15 frames (1/4 de segundo a 60 FPS)
  boolean canCoyoteJump = false;
  
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
  AssetManager assetManager; // Referencia al gestor de assets
  
  // Imágenes del jugador
  PImage characterImage;
  PImage shadowImage;
  
  // Constructor simplificado
  Player(float x, float groundY) {
    // Crear un AccessibilityManager y pasarlo tanto al constructor padre como al SoundManager
    AccessibilityManager am = new AccessibilityManager();
    SoundManager sm = new SoundManager(am);
    this.x = x;
    this.groundY = groundY;
    this.y = groundY;
    this.size = 90;
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
    this.size = 150;
    this.currentColor = normalColor;
    this.baseSpeed = 0;
    this.accessManager = accessManager;
    this.soundManager = soundManager;
  }
  
  // Constructor con AssetManager
  Player(float x, float groundY, AccessibilityManager accessManager, SoundManager soundManager, AssetManager assetManager) {
    this.x = x;
    this.groundY = groundY;
    this.y = groundY;
    this.size = 135;
    this.currentColor = normalColor;
    this.baseSpeed = 0;
    this.accessManager = accessManager;
    this.soundManager = soundManager;
    this.assetManager = assetManager;
    
    // Cargar imágenes del jugador desde AssetManager
    if (assetManager != null) {
      characterImage = assetManager.getCharacterImage();
      shadowImage = assetManager.getShadowImage();
    }
  }
  
  void update() {
    handleJump();
    handleSlide();
    
    // Actualizar contador de coyote time
    if (canCoyoteJump) {
      coyoteTime++;
      if (coyoteTime >= maxCoyoteTime) {
        canCoyoteJump = false;
        coyoteTime = 0;
      }
    }
    
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
      shieldSize = size * 1.5 + sin(shieldPulse) * 7;
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
      
      // Activar coyote time
      // Permite al jugador saltar durante un breve periodo después de caer de una plataforma
      canCoyoteJump = true;
      coyoteTime = 0;
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
    imageMode(CENTER);
    
    color adjustedCurrentColor = accessManager.getForegroundColor(currentColor);
    
    // Dibujar escudo
    if (hasShield) {
      pushStyle();
      color adjustedShieldColor = accessManager.getForegroundColor(shieldColor);
      fill(adjustedShieldColor);
      ellipse(x, y - size/2, shieldSize, shieldSize);
      popStyle();
    }
    
    // Determinar si usar imágenes o formas geométricas basado en accesibilidad y disponibilidad
    boolean useImages = assetManager != null && 
                       characterImage != null && 
                       shadowImage != null && 
                       !accessManager.highContrastMode;
    
    if (useImages) {
      // Dibujar sombra mejorada
      pushStyle();
      tint(0, 180); // Sombra un poco más oscura
      
      // Calcular tamaño y posición de la sombra
      float shadowY;
      float shadowWidth;
      float shadowHeight;
      
      // La sombra se proyecta en el suelo o plataforma donde está el jugador
      if (isSliding) {
        // Sombra en posición de deslizamiento
        shadowY = y + 2;
        shadowWidth = size * 1.4;
        shadowHeight = size * 0.35;
      } else {
        // Sombra en posición normal
        shadowY = y + 2;
        shadowWidth = size * 1.1;
        shadowHeight = size * 0.35;
      }
      
      // La sombra se achata más cuando el personaje está más alto (efecto perspectiva)
      float heightFromGround = groundY - y;
      if (isJumping && heightFromGround > 0) {
        // Reducir tamaño de sombra proporcionalmente a la altura
        float reductionFactor = map(heightFromGround, 0, 200, 1.0, 0.5);
        shadowWidth *= reductionFactor;
        shadowHeight *= reductionFactor;
        
        // Aplicar ligero desplazamiento para simular perspectiva
        float shadowOffset = map(heightFromGround, 0, 200, 0, size/2);
        shadowY = groundY - 2; // La sombra siempre está en el suelo/plataforma
      }
      
      // Dibujar la sombra en la posición calculada
      image(shadowImage, x, shadowY, shadowWidth, shadowHeight);
      noTint();
      
      // Dibujar personaje
      pushMatrix();
      if (isSliding) {
        // Personaje en posición de deslizamiento (más horizontal)
        translate(x, y - size * 0.2);
        // Rotar ligeramente el personaje al deslizarse
        rotate(PI/2); // 90 grados
        
        // Aplicar efecto de parpadeo si es invencible
        if (isInvincible && invincibilityTimer % 10 < 5) {
          tint(255, 255, 100);
        }
        
        image(characterImage, 0, 0, size * 0.8, size * 1.2);
      } else {
        // Personaje en posición normal
        
        // Aplicar efecto de parpadeo si es invencible
        if (isInvincible && invincibilityTimer % 10 < 5) {
          tint(255, 255, 100);
        }
        
        image(characterImage, x, y - size/2, size, size);
      }
      noTint();
      popMatrix();
    } else {
      // Dibujar sombra para modo accesibilidad
      pushStyle();
      fill(0, 100);
      float shadowY = groundY - 2;
      float shadowWidth = size * (isSliding ? 1.3 : 1.0);
      float shadowHeight = size * 0.2;
      
      // Si está saltando, ajustar tamaño de sombra
      if (isJumping) {
        float heightFromGround = groundY - y;
        float reductionFactor = map(heightFromGround, 0, 200, 1.0, 0.5);
        shadowWidth *= reductionFactor;
        shadowHeight *= reductionFactor;
      }
      
      ellipse(x, shadowY, shadowWidth, shadowHeight);
      popStyle();
      
      // Dibujar jugador con formas geométricas (para accesibilidad)
      fill(adjustedCurrentColor);
      
      if (isSliding) {
        // Forma deslizamiento
        ellipse(x, y + size/4, size * 1.2, size/2);
      } else {
        // Forma normal
        ellipse(x, y - size/2, size, size);
      }
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
    // Permitir salto normal o durante coyote time
    if ((!isJumping && !isSliding) || isOnPlatform || canCoyoteJump) {
      // Desactivar coyote time después de usarlo
      if (canCoyoteJump) {
        canCoyoteJump = false;
        coyoteTime = 0;
      }
      
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
    
    // Ajustar el hitbox para ser un poco más pequeño que el sprite visual
    // para una mejor experiencia de juego
    float hitboxReduction = 0.75; // 75% del tamaño visual (más favorable al jugador)
    playerWidth *= hitboxReduction;
    playerHeight *= hitboxReduction;
    
    // Cálculo del margen de gracia para hacer el juego más justo
    float graceMargin = size * 0.05; // Margen de 5% del tamaño del jugador
    
    float playerBottom = y - graceMargin;
    float playerTop = isSliding ? playerBottom - playerHeight/2 : playerBottom - playerHeight;
    float playerLeft = x - playerWidth/2 + graceMargin;
    float playerRight = x + playerWidth/2 - graceMargin;
    
    // Obtener dimensiones del obstáculo
    float obstacleTop = obstacle.getTop();
    float obstacleBottom = obstacleTop + obstacle.getHeight();
    float obstacleLeft = obstacle.x - obstacle.w/2;
    float obstacleRight = obstacle.x + obstacle.w/2;
    
    // Si el jugador es invencible, no hay colisión
    if (isInvincible) return false;
    
    // Comprobar si hay solapamiento en ambas dimensiones
    boolean collision = (playerRight > obstacleLeft && 
                        playerLeft < obstacleRight && 
                        playerBottom > obstacleTop && 
                        playerTop < obstacleBottom);
    
    // Dar un poco más de margen para colisiones menores
    // Esto hace que roces muy leves no cuenten como colisión
    if (collision) {
      // Calcular porcentaje de superposición
      float overlapX = min(playerRight, obstacleRight) - max(playerLeft, obstacleLeft);
      float overlapY = min(playerBottom, obstacleBottom) - max(playerTop, obstacleTop);
      
      // Área de superposición relativa al tamaño del jugador
      float overlapArea = (overlapX * overlapY) / (playerWidth * playerHeight);
      
      // Si la superposición es mínima, ignorarla
      // Esto favorece al jugador en caso de roces leves
      if (overlapArea < 0.1) { // Menos del 10% de superposición
        collision = false;
      }
    }
    
    return collision;
  }
  
  // Método para comprobar si estamos recogiendo un coleccionable
  boolean isCollectingItem(Collectible collectible) {
    // Calcular distancia entre el centro del jugador y el centro del coleccionable
    float distance = dist(x, y - size/2, collectible.x, collectible.y);
    
    // Considerar colisión si la distancia es menor que la suma de los radios
    float collectionRadius = (size/2 + collectible.size/2) * 1.8;
    
    // Ajustar dinámicamente el radio de colección basado en la velocidad del jugador
    // Esto hace más fácil recoger coleccionables cuando se va rápido
    if (hasSpeedBoost) {
      collectionRadius *= 1.5; // 50% más grande cuando tiene boost de velocidad
    }
    
    // Radio adicional cuando el jugador está en el aire (saltando)
    if (isJumping) {
      collectionRadius *= 1.2; // 20% extra si está saltando
    }
    
    // Ayudar a la recolección mientras se está en movimiento
    // Calculamos la proyección futura para anticipar la colección
    if (vSpeed != 0 || isJumping) {
      // Intentar predecir dónde estará el jugador en los siguientes frames
      for (float t = 0.1; t <= 1.0; t += 0.3) {
        float futureY = y - size/2 + vSpeed * t;
        float futureDist = dist(x, futureY, collectible.x, collectible.y);
        
        // Usar la distancia más corta (actual o futura)
        distance = min(distance, futureDist);
      }
    }
    
    return distance < collectionRadius;
  }
  
  // Dibujar barra de salud
  void drawHealthBar(float x, float y, float w, float h) {
    pushStyle();
    rectMode(CORNER);
    
    // Fondo de la barra
    fill(accessManager.getBackgroundColor(color(100)));
    rect(x, y, w, h);
    
    // Configurar para mostrar un máximo visible de corazones a la vez
    int visibleHearts = 5; // Número máximo de corazones a mostrar en la barra
    float heartSize = h * 0.8;
    float heartSpacing = (w - visibleHearts * heartSize) / (visibleHearts + 1);
    
    // Si el jugador tiene más corazones de los que caben, mostrar un indicador
    boolean showMoreIndicator = health > visibleHearts;
    int heartsToShow = min(health, visibleHearts);
    
    // Dibujar corazones visibles
    for (int i = 0; i < heartsToShow; i++) {
      // Posición del corazón actual
      float heartX = x + heartSpacing + i * (heartSize + heartSpacing);
      float heartY = y + (h - heartSize) / 2;
      
      // Dibujar corazón lleno
      fill(accessManager.getForegroundColor(color(255, 0, 0)));
      drawHeartShape(heartX, heartY, heartSize);
    }
    
    // Si hay más corazones de los que se pueden mostrar, dibujar indicador
    if (showMoreIndicator) {
      textAlign(LEFT, CENTER);
      fill(accessManager.getForegroundColor(color(255, 0, 0)));
      textSize(h * 0.6);
      text("+" + (health - visibleHearts), x + w - 40, y + h/2);
    }
    
    // Borde
    stroke(accessManager.getForegroundColor(color(255)));
    noFill();
    rect(x, y, w, h);
    
    popStyle();
  }
  
  // Método para reiniciar el jugador a su estado inicial
  void reset() {
    // Reiniciar posición
    y = groundY;
    
    // Reiniciar estados
    isJumping = false;
    isSliding = false;
    spacePressed = false;
    vSpeed = 0;
    jumpHoldTime = 0;
    slideDuration = 0;
    
    // Reiniciar plataformas
    isOnPlatform = false;
    currentPlatform = null;
    lastPlatformY = 0;
    isPlatformJump = false;
    
    // Reiniciar power-ups
    deactivateShield();
    deactivateSpeedBoost();
    deactivateDoublePoints();
    
    // Reiniciar coyote time
    canCoyoteJump = false;
    coyoteTime = 0;
    
    // Reiniciar estado de invencibilidad
    isInvincible = false;
    invincibilityTimer = 0;
    
    // Restaurar color
    currentColor = normalColor;
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