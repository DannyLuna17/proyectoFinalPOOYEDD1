class Player {
  float x, y;
  float size;
  float groundY;
  float restingY; // Posición vertical donde el jugador descansa en el suelo
  float vSpeed = 0;
  float gravity = 0.5;
  float jumpForce = -4.5;
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
  color shieldWarningColor = color(255, 100, 100, 150); // Color de advertencia para el escudo (rojizo)
  float shieldSize = 0;
  float shieldPulse = 0;
  boolean isShieldBlinking = false; // Variable para controlar el parpadeo del escudo
  boolean hasShownShieldWarning = false; // Para mostrar la advertencia solo una vez
  int shieldBlinkThreshold = 100; // Comenzar a parpadear 3 segundos antes (60 FPS * 3)
  
  // Variables para plataformas
  boolean isOnPlatform = false;
  Platform currentPlatform = null;
  float lastPlatformY = 0;
  boolean isPlatformJump = false;
  float platformJumpBonus = 1.2; // Bonus de salto en plataformas
  
  // Variables para preservar valores originales antes de aplicar efectos climáticos
  boolean hasWeatherEffectsApplied = false;
  float originalJumpForce = -7.5;
  float originalMaxJumpForce = -22;
  float originalGravity = 0.8;
  
  // Referencias externas
  AccessibilityManager accessManager;
  SoundManager soundManager;
  AssetManager assetManager; // Referencia al gestor de assets
  CollectibleManager collectibleManager; // Referencia al gestor de coleccionables
  
  // Imágenes del jugador
  PImage characterImage;
  PImage shadowImage;
  
  // Fast fall y drop-through
  boolean isFastFalling = false; // Si el jugador está haciendo fast fall
  boolean wantsToDrop = false;   // Si el jugador quiere bajar por plataforma
  float fastFallSpeed = 30;      // Velocidad de caída rápida
  
  // Animación de salto
  boolean playingJumpAnimation = false; 
  int jumpAnimationTimer = 0;          // Contador para la duración de la animación
  int jumpAnimationDuration = 90;      // Duración de la animación en frames (1.5 segundos a 60 FPS)
  
  // Animación de corrida
  boolean playingRunningAnimation = false;  // Si está reproduciendo la animación de correr
  boolean isRunning = false;               // Si el jugador está en estado de correr
  int lastObstacleSpeed = 0;              // Para detectar cambios en la velocidad del mundo
  
  // Constructor simplificado
  Player(float x, float groundY) {
    // Crear un AccessibilityManager y pasarlo tanto al constructor padre como al SoundManager
    AccessibilityManager am = new AccessibilityManager();
    SoundManager sm = new SoundManager(am);
    this.x = x;
    this.groundY = groundY + 10;
    this.restingY = this.groundY + 40; // Calcular posición de reposo consistente
    this.y = this.restingY; // Usar la posición de reposo
    this.size = 90;
    this.currentColor = normalColor;
    this.baseSpeed = 0;
    this.accessManager = am;
    this.soundManager = sm;
  }
  
  // Constructor principal
  Player(float x, float groundY, AccessibilityManager accessManager, SoundManager soundManager) {
    this.x = x;
    this.groundY = groundY + 10;
    this.restingY = this.groundY + 55; // Calcular posición de reposo consistente
    this.y = this.restingY; // Usar la posición de reposo
    this.size = 250;
    this.currentColor = normalColor;
    this.baseSpeed = 0;
    this.accessManager = accessManager;
    this.soundManager = soundManager;
  }
  
  // Constructor con AssetManager
  Player(float x, float groundY, AccessibilityManager accessManager, SoundManager soundManager, AssetManager assetManager) {
    this.x = x;
    this.groundY = groundY + 10;
    this.restingY = this.groundY + 40; // Calcular posición de reposo consistente
    this.y = this.restingY; // Usar la posición de reposo
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
      
      // Iniciar la animación de correr automáticamente al crear el jugador
      startRunning();
    }
  }
  
  // Método para establecer el gestor de coleccionables
  void setCollectibleManager(CollectibleManager cm) {
    this.collectibleManager = cm;
  }
  
  void update() {
    handleJump();
    handleSlide();
    // Fast fall: si está en el aire y activado, cae más rápido
    if (isFastFalling && isInAir()) {
      vSpeed = fastFallSpeed;
    }
    // Resetear fast fall si toca el suelo o plataforma
    if (!isInAir()) {
      isFastFalling = false;
      // Resetear drop-through solo cuando el jugador ya no está en el aire
      wantsToDrop = false;
    }
    
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
      
      // Verificar si el escudo está por expirar para activar parpadeo
      if (shieldDuration > 0 && shieldTimer >= shieldDuration - shieldBlinkThreshold) {
        // Si acabamos de empezar a parpadear y no hemos mostrado la advertencia
        if (!isShieldBlinking && !hasShownShieldWarning && collectibleManager != null) {
          // Mostrar mensaje de advertencia
          collectibleManager.addFloatingText("¡Escudo por expirar!", x, y - size - 20, shieldWarningColor);
          hasShownShieldWarning = true;
        }
        isShieldBlinking = true;
      } else {
        isShieldBlinking = false;
      }
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
    
    // Manejar la animación de salto
    if (playingJumpAnimation) {
      jumpAnimationTimer++;
      // Solo detener la animación cuando termine el tiempo completo
      // No depender del estado isJumping para que la animación se vea completa
      if (jumpAnimationTimer >= jumpAnimationDuration) {
        playingJumpAnimation = false;
        jumpAnimationTimer = 0;
      }
    }
    
    // Manejar la animación de corrida - siempre debe estar activa
    if (!isRunning || !playingRunningAnimation) {
      startRunning(); // Asegurar que siempre esté corriendo
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
      if (y >= restingY) { // Usar restingY en lugar de groundY para mantener consistencia
        y = restingY; // Aterrizar en la misma posición que al inicio
        vSpeed = 0;
        isJumping = false;
        isPlatformJump = false;
        jumpHoldTime = 0;
        isOnPlatform = false;
        currentPlatform = null;
        // La animación de salto continuará hasta completarse por su propio timer
      }
    }
  }
  
  // Comprobar colisión con plataformas
  void checkPlatformCollision(ArrayList<Platform> platforms) {
    if (isSliding) {
      return;
    }
    // Si el jugador quiere bajar, ignorar colisión con plataformas hasta que esté en el aire
    if (wantsToDrop) {
      isOnPlatform = false;
      currentPlatform = null;
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
          // La animación de salto continuará hasta completarse por su propio timer
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
    
    // Debug: imprimir estado de las animaciones
    if (frameCount % 60 == 0) { // Cada segundo
      println("DEBUG - Jump anim: " + playingJumpAnimation + ", Running anim: " + playingRunningAnimation);
    }
    
    // Dibujar escudo
    if (hasShield) {
      pushStyle();
      color adjustedShieldColor = accessManager.getForegroundColor(shieldColor);
      color adjustedWarningColor = accessManager.getForegroundColor(shieldWarningColor);
      
      // Aplicar efecto de parpadeo si el escudo está por expirar
      if (isShieldBlinking) {
        // Efecto de parpadeo más intenso
        if (frameCount % 12 < 6) {
          // Usar color de advertencia con más opacidad en el parpadeo activo
          fill(adjustedWarningColor);
          // Dibujar un escudo ligeramente más grande durante el parpadeo para mayor visibilidad
          ellipse(x, y - size/2, shieldSize * 1.05, shieldSize * 1.05);
        } else {
          // Usar color normal con menos opacidad en el parpadeo inactivo
          fill(red(adjustedShieldColor), green(adjustedShieldColor), blue(adjustedShieldColor), 80);
          ellipse(x, y - size/2, shieldSize, shieldSize);
        }
      } else {
        // Dibujo normal del escudo cuando no está parpadeando
        fill(adjustedShieldColor);
        ellipse(x, y - size/2, shieldSize, shieldSize);
      }
      popStyle();
    }
    
    // Determinar si usar imágenes o formas geométricas basado en accesibilidad y disponibilidad
    // Con filtros overlay, siempre preferir las imágenes originales si están disponibles
    boolean useImages = assetManager != null && 
                       characterImage != null && 
                       shadowImage != null;
    
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
        // Sombra en posición de deslizamiento - justo debajo del jugador
        shadowY = y + size/3; // Pequeño offset debajo del personaje deslizándose
        shadowWidth = size * 1.4;
        shadowHeight = size * 0.35;
      } else {
        // Sombra en posición normal - justo debajo de los pies
        shadowY = y + size/12; // Pequeño offset debajo de los pies del personaje
        shadowWidth = size * 1.1;
        shadowHeight = size * 0.35;
      }
      
      // La sombra se achata más cuando el personaje está más alto (efecto perspectiva)
      float heightFromGround = restingY - y; // Usar restingY como base para calcular la altura del jugador
      if (isJumping && heightFromGround > 0) {
        // Reducir tamaño de sombra proporcionalmente a la altura
        float reductionFactor = map(heightFromGround, 0, 200, 1.0, 0.5);
        shadowWidth *= reductionFactor;
        shadowHeight *= reductionFactor;
        
        // Cuando está saltando, la sombra se proyecta en el suelo pero sigue siendo visible
        shadowY = restingY + size/12; // Proyectar la sombra en el nivel del suelo
      }
      
      // Dibujar la sombra en la posición calculada
      image(shadowImage, x, shadowY, shadowWidth, shadowHeight);
      noTint();
      
      // Dibujar personaje
      pushMatrix();
      // Configurar modo de blend para transparencias
      blendMode(BLEND);
      
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
      } else if (playingJumpAnimation) {
        // PRIORIDAD 1: Mostrar animación de salto cuando está activa
        translate(x, y - size/2); // Aplicar transformación para posicionar correctamente
        
        // Aplicar efecto de parpadeo si es invencible
        if (isInvincible && invincibilityTimer % 10 < 5) {
          tint(255, 255, 100);
        }
        
        // Obtener el GIF de salto directamente
        if (assetManager != null && assetManager.isJumpAnimationGifActive()) {
          Gif jumpGif = assetManager.getJumpAnimationGif();
          if (jumpGif != null) {
            // Dibujar el GIF de salto
            image(jumpGif, 0, 0, size*1.2, size*1.2);
          } else {
            // Fallback
            image(characterImage, 0, 0, size, size);
          }
        } else {
          // Fallback si no hay AssetManager
          image(characterImage, 0, 0, size, size);
        }
      } else if (playingRunningAnimation) {
        // PRIORIDAD 2: Mostrar animación de corrida
        translate(x, y - size/2); // Posicionar correctamente
        
        // Aplicar efecto de parpadeo si es invencible
        if (isInvincible && invincibilityTimer % 10 < 5) {
          tint(255, 255, 100);
        }
        
        // Obtener el GIF de correr directamente
        if (assetManager != null && assetManager.isRunningAnimationGifActive()) {
          Gif runningGif = assetManager.getRunningAnimationGif();
          if (runningGif != null) {
            // Dibujar el GIF de correr
            image(runningGif, 0, 0, size, size);
          } else {
            // Fallback
            image(characterImage, 0, 0, size, size);
          }
        } else {
          // Fallback si no hay AssetManager
          image(characterImage, 0, 0, size, size);
        }
      } else {
        // Personaje en posición normal (idle) - solo si no hay animaciones activas
        // Aplicar efecto de parpadeo si es invencible
        if (isInvincible && invincibilityTimer % 10 < 5) {
          tint(255, 255, 100);
        }
        
        image(characterImage, x, y - size/2, size, size);
      }
      noTint();
      blendMode(BLEND); // Restaurar modo de blend por defecto
      popMatrix();
    } else {
      // Dibujar sombra para modo accesibilidad
      pushStyle();
      fill(0, 100);
      // Sombra justo debajo del jugador, similar al modo con imágenes
      float shadowY = y + size/4; // Pequeño offset debajo de los pies
      float shadowWidth = size * (isSliding ? 1.3 : 1.0);
      float shadowHeight = size * 0.2;
      
      // Si está saltando, ajustar tamaño de sombra
      if (isJumping) {
        float heightFromGround = restingY - y;
        float reductionFactor = map(heightFromGround, 0, 200, 1.0, 0.5);
        shadowWidth *= reductionFactor;
        shadowHeight *= reductionFactor;
        // Cuando salta, proyectar la sombra en el suelo
        shadowY = restingY + size/4;
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
      
      // Ya no detenemos la animación de correr al saltar
      // El jugador puede correr en el aire también
      
      // Iniciar la animación de salto
      playingJumpAnimation = true;
      jumpAnimationTimer = 0;
      
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
    return isJumping && !isOnPlatform && y < restingY; // Usar restingY para verificar correctamente si está en el aire
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
    isShieldBlinking = false; // Reiniciar estado de parpadeo
    hasShownShieldWarning = false; // Reiniciar el indicador de advertencia
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
    stroke(accessManager.getUIBorderColor(color(255, 255, 255, 120)));
    strokeWeight(2);
    rect(x, y, w, h);
    
    // Configurar para mostrar un máximo visible de corazones a la vez
    int visibleHearts = 5; // Número máximo de corazones a mostrar en la barra
    float heartSize = h * 0.9;
    float heartSpacing = (w - visibleHearts * heartSize) / (visibleHearts + 1);
    
    // Colores para los corazones
    color heartColor = accessManager.getForegroundColor(color(255, 50, 50));
    color emptyHeartColor = accessManager.getForegroundColor(color(80, 80, 80));
    color outlineColor = accessManager.getForegroundColor(color(0));
    
    // Calcular cuántos corazones llenos y vacíos mostrar
    boolean showMoreIndicator = health > visibleHearts;
    int filledHearts = min(health, visibleHearts);
    int emptyHearts = visibleHearts - filledHearts;
    
    // Dibujar corazones llenos
    for (int i = 0; i < filledHearts; i++) {
      // Posición del corazón actual
      float heartX = x + heartSpacing + i * (heartSize + heartSpacing);
      float heartY = y + (h - heartSize) / 2;
      
      // Dibujar corazón lleno con borde
      drawHeartShape(heartX, heartY, heartSize, heartColor, outlineColor, true);
    }
    
    // Dibujar corazones vacíos (representan la vida perdida)
    for (int i = 0; i < emptyHearts; i++) {
      // Posición del corazón vacío (continúa después de los llenos)
      float heartX = x + heartSpacing + (filledHearts + i) * (heartSize + heartSpacing);
      float heartY = y + (h - heartSize) / 2;
      
      // Dibujar corazón vacío solo con borde
      drawHeartShape(heartX, heartY, heartSize, emptyHeartColor, outlineColor, false);
      // Dibujar corazón lleno con borde
      drawHeartShape(heartX, heartY, heartSize, heartColor, outlineColor, true);
    }
    
    // Dibujar corazones vacíos (representan la vida perdida)
    for (int i = 0; i < emptyHearts; i++) {
      // Posición del corazón vacío (continúa después de los llenos)
      float heartX = x + heartSpacing + (filledHearts + i) * (heartSize + heartSpacing);
      float heartY = y + (h - heartSize) / 2;
      
      // Dibujar corazón vacío solo con borde
      drawHeartShape(heartX, heartY, heartSize, emptyHeartColor, outlineColor, false);
    }
    
    // Si hay más corazones de los que se pueden mostrar, dibujar indicador más grande
    if (showMoreIndicator) {
      textAlign(LEFT, CENTER);
      fill(accessManager.getForegroundColor(color(255, 50, 50)));
      textSize(h * 0.7); 
      text("+" + (health - visibleHearts), x + w - 50, y + h/2); 
    }
    
    // Borde final sin relleno
    // Borde final sin relleno
    stroke(accessManager.getForegroundColor(color(255)));
    strokeWeight(2);
    noFill();
    rect(x, y, w, h);
    
    popStyle();
  }
  
  // Método para reiniciar el jugador a su estado inicial
  void reset() {
    // Reiniciar posición usando la misma altura que al inicio
    y = restingY; // Usar restingY para mantener consistencia de altura
    
    // Reiniciar estados
    isJumping = false;
    isSliding = false;
    spacePressed = false;
    vSpeed = 0;
    jumpHoldTime = 0;
    slideDuration = 0;
    
    // Reiniciar animación de salto
    playingJumpAnimation = false;
    jumpAnimationTimer = 0;
    
    // Iniciar automáticamente la animación de corrida
    // El jugador siempre está corriendo en el juego
    startRunning();
    
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
    
    // Reiniciar efectos climáticos para prevenir bugs de salto
    hasWeatherEffectsApplied = false;
    jumpForce = originalJumpForce;       
    maxJumpForce = originalMaxJumpForce; 
    gravity = originalGravity;           
    
    // Restaurar color
    currentColor = normalColor;
  }

  // Dibuja la forma de un corazón con opciones mejoradas
  void drawHeartShape(float x, float y, float size, color fillColor, color borderColor, boolean filled) {
    pushMatrix();
    translate(x + size/2, y + size/2);
    
    // Configurar el borde negro
    stroke(borderColor);
    strokeWeight(3); 
    
    if (filled) {
      // Corazón lleno
      fill(fillColor);
    } else {
      // Corazón vacío
      noFill();
    }
    
    // Configurar el borde negro
    stroke(borderColor);
    strokeWeight(3); 
    
    if (filled) {
      // Corazón lleno
      fill(fillColor);
    } else {
      // Corazón vacío
      noFill();
    }
    
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
  
  // Nuevo método para activar fast fall
  void startFastFall() {
    if (isInAir()) {
      isFastFalling = true;
    }
  }
  
  // Este método hace que el jugador baje por la plataforma cuando está parado sobre ella y presiona la flecha abajo
  // Básicamente, ignora la colisión con la plataforma y lo pone en modo de caída. Súper útil para bajar rápido sin saltar.
  void dropThroughPlatform() {
    // Solo si está en plataforma
    if (isOnPlatform && currentPlatform != null) {
      wantsToDrop = true;
      isOnPlatform = false;
      currentPlatform = null;
      isJumping = true;
      vSpeed = 0;
    }
  }
  
  // Método para iniciar la corrida  
  void startRunning() {
    isRunning = true;
    playingRunningAnimation = true;
    
    // Inicializar la animación en el AssetManager si está disponible
    if (assetManager != null) {
      assetManager.startRunningAnimation();
    }
  }
  
  // Método para detener la corrida  
  void stopRunning() {
    isRunning = false;
    playingRunningAnimation = false;
    
    // Detener la animación en el AssetManager si está disponible
    if (assetManager != null) {
      assetManager.stopRunningAnimation();
    }
  }
}
