class Player {
  float x, y;
  float size;
  float groundY;
  float vSpeed = 0;
  float gravity = 0.5;
  float jumpForce = -12;
  float maxJumpForce = -10;
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
  
  Player(float x, float groundY) {
    this.x = x;
    this.groundY = groundY;
    this.y = groundY;
    this.size = 50;
    this.currentColor = normalColor;
    this.baseSpeed = 0;
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
    if (spacePressed && isJumping && jumpHoldTime < maxJumpHoldTime) {
      jumpHoldTime++;
      vSpeed = map(jumpHoldTime, 0, maxJumpHoldTime, jumpForce, maxJumpForce);
    }
    
    if (isJumping) {
      vSpeed += gravity;
      y += vSpeed;
      
      if (y >= groundY) {
        y = groundY;
        vSpeed = 0;
        isJumping = false;
        jumpHoldTime = 0;
      }
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
  }
  
  void jump() {
    if (!isJumping && !isSliding) {
      isJumping = true;
      spacePressed = true;
      vSpeed = jumpForce;
      jumpHoldTime = 0;
      
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
  
  boolean isColliding(Obstacle obstacle) {
    if (isInvincible) return false;
    
    float playerWidth = isSliding ? size * 1.2 : size;
    float playerHeight = isSliding ? size/2 : size;
    float playerTop = isSliding ? y + size/4 - playerHeight/2 : y - size;
    
    if (x + playerWidth/2 > obstacle.x - obstacle.w/2 &&
        x - playerWidth/2 < obstacle.x + obstacle.w/2 &&
        y > obstacle.getTop() &&
        playerTop < obstacle.getTop() + obstacle.getHeight()) {
      return true;
    }
    return false;
  }
  
  boolean isCollectingItem(Collectible collectible) {
    float playerWidth = isSliding ? size * 1.2 : size;
    float playerHeight = isSliding ? size/2 : size;
    float playerTop = isSliding ? y + size/4 - playerHeight/2 : y - size;
    
    float dist = dist(x, y - size/2, collectible.x, collectible.y);
    return dist < (size/2 + collectible.size/2);
  }
  
  void takeDamage() {
    if (!isInvincible) {
      if (!hasShield) {
        health--;
        isInvincible = true;
        invincibilityTimer = 0;
      } else {
        deactivateShield();
      }
    }
  }
  
  boolean isDead() {
    return health <= 0;
  }
  
  void drawHealthBar(float x, float y, float width, float height) {
    pushStyle();
    
    rectMode(CORNER);
    
    // Fondo
    color bgColor = accessManager.highContrastMode ? color(40) : color(100);
    fill(bgColor);
    rect(x, y, width, height);
    
    // Barra de salud
    color healthBarColor = accessManager.highContrastMode ? 
                          accessManager.highContrastUIElement : color(0, 255, 0);
    fill(healthBarColor);
    float healthWidth = map(health, 0, 3, 0, width);
    rect(x, y, healthWidth, height);
    
    // Borde
    noFill();
    color borderColor = accessManager.getUIBorderColor(color(0));
    stroke(borderColor);
    strokeWeight(2);
    rect(x, y, width, height);
    
    popStyle();
  }
  
  void activateShield(int duration) {
    hasShield = true;
    shieldDuration = duration;
    shieldTimer = 0;
  }
  
  void activateSpeedBoost(int duration) {
    hasSpeedBoost = true;
    speedMultiplier = 1.5;
    speedBoostDuration = duration;
    speedBoostTimer = 0;
  }
  
  void activateDoublePoints(int duration) {
    hasDoublePoints = true;
    pointsMultiplier = 2;
    doublePointsDuration = duration;
    doublePointsTimer = 0;
  }
  
  void deactivateShield() {
    hasShield = false;
    shieldTimer = 0;
  }
  
  void deactivateSpeedBoost() {
    hasSpeedBoost = false;
    speedMultiplier = 1.0;
  }
  
  void deactivateDoublePoints() {
    hasDoublePoints = false;
    pointsMultiplier = 1;
  }
  
  int getPointsMultiplier() {
    return pointsMultiplier;
  }
} 