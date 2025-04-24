class Game {
  Player player;
  ArrayList<Obstacle> obstacles;
  ArrayList<Collectible> collectibles;
  ArrayList<PowerUp> activePowerUps;
  EcoSystem ecoSystem;
  Weather weatherSystem;
  
  float scrollSpeed = 5;
  float baseObstacleSpeed = 5;
  float obstacleSpeed;
  float groundLevel;
  float obstacleTimer = 0;
  float obstacleInterval = 90; // frames entre obstáculos
  float[] backgroundX = new float[2]; // scroll continuo
  
  // Coleccionables
  float collectibleTimer = 0;
  float collectibleInterval = 120; // Frames entre intentos
  float collectibleChance = 0.7; // 70% de probabilidad
  float ecoCollectibleChance = 0.3; // 30% para ambiental
  
  // Dificultad
  int difficultyLevel = 1;
  int lastDifficultyIncrease = 0;
  int scoreDifficultyThreshold = 1000; // Puntos para aumentar
  
  // Patrones
  int currentPattern = 0;
  int patternsCompleted = 0;
  boolean inPattern = false;
  int patternStep = 0;
  int[][] patterns = {
    {0, 0, 1}, // Patrón básico
    {1, 2, 1}, // Salto, desliz, salto
    {2, 2, 0, 2}, // Desliz, desliz, est, desliz
    {3, 0, 3}, // Móvil, est, móvil
    {1, 3, 2, 1}, // Complejo
    {3, 3, 2, 1, 0} // Experto
  };
  
  // Puntuación
  int score = 0;
  int highScore = 0;
  int scoreIncrement = 1;
  int bonusPoints = 0;
  int framesSinceLastCollision = 0;
  int bonusThreshold = 300; // 5 segundos sin colisión
  int collectiblesCollected = 0;
  
  // Logros
  int consecutiveObstaclesAvoided = 0;
  int maxConsecutiveObstaclesAvoided = 0;
  
  // Estado
  boolean gameOver = false;
  boolean gameStarted = false;
  
  // Textos flotantes
  ArrayList<FloatingText> floatingTexts;
  
  Game() {
    reset();
  }
  
  void reset() {
    groundLevel = height * 0.8;
    player = new Player(width * 0.2, groundLevel);
    obstacles = new ArrayList<Obstacle>();
    collectibles = new ArrayList<Collectible>();
    activePowerUps = new ArrayList<PowerUp>();
    floatingTexts = new ArrayList<FloatingText>();
    ecoSystem = new EcoSystem();
    weatherSystem = new Weather();
    
    // Fondo
    backgroundX[0] = 0;
    backgroundX[1] = width;
    
    // Resetear puntuación
    if (score > highScore) {
      highScore = score;
    }
    score = 0;
    framesSinceLastCollision = 0;
    collectiblesCollected = 0;
    
    // Dificultad
    difficultyLevel = 1;
    lastDifficultyIncrease = 0;
    obstacleSpeed = baseObstacleSpeed;
    
    // Patrones
    inPattern = false;
    patternStep = 0;
    currentPattern = 0;
    patternsCompleted = 0;
    consecutiveObstaclesAvoided = 0;
    
    // Temporizadores
    collectibleTimer = 0;
    
    gameOver = false;
    gameStarted = true;
  }
  
  void update() {
    if (gameOver || gameState == STATE_PAUSED) {
      return;
    }
    
    try {
      // Actualizar eco-sistema
      ecoSystem.update();
      
      // Actualizar clima
      weatherSystem.update(ecoSystem);
      
      // Actualizar apariencia del jugador
      player.updateEnvironmentalAppearance(ecoSystem);
      
      // Efectos del clima
      applyWeatherEffectsToPlayer();
      
      // Actualizar jugador
      player.update();
      
      // Fondo
      scrollBackground();
      
      // Obstáculos
      updateObstaclesWithEcoImpact();
      
      // Coleccionables
      updateCollectibles();
      
      // Power-ups
      updatePowerUps();
      
      // Colisiones
      checkCollisions();
      
      // Recolección
      checkCollectibleCollection();
      
      // Puntuación
      updateScore();
      
      // Textos flotantes
      updateFloatingTexts();
      
      // Dificultad
      updateDifficulty();
      
      // Consecuencias ambientales
      applyEnvironmentalConsequences();
      
      // Game over
      if (player.isDead()) {
        triggerGameOver();
      }
      
      // Validación
      if (testRunner != null && testRunner.debugSystem.validationActive) {
        validateGameState();
      }
    } catch (Exception e) {
      // Error
      if (testRunner != null) {
        testRunner.debugSystem.logError("Error en game.update(): " + e.getMessage());
      } else {
        println("ERROR en game.update(): " + e.getMessage());
        e.printStackTrace();
      }
    }
  }
  
  void applyWeatherEffectsToPlayer() {
    // Efectos en salto
    float jumpMod = weatherSystem.getJumpModifier();
    if (jumpMod != 0) {
      player.jumpForce = -12 * (1 + jumpMod);
      player.maxJumpForce = -16 * (1 + jumpMod);
    } else {
      player.jumpForce = -12;
      player.maxJumpForce = -16;
    }
    
    // Efectos en velocidad
    float speedMod = weatherSystem.getSpeedModifier();
    
    // Velocidad de scroll
    if (speedMod != 0) {
      float baseScrollSpeed = 5 + (difficultyLevel * 0.3);
      float weatherAdjustedSpeed = baseScrollSpeed * (1 + speedMod);
      scrollSpeed = constrain(weatherAdjustedSpeed, 3, 10);
      
      obstacleSpeed = baseObstacleSpeed * (1 + speedMod);
    }
    
    // Indicador visual
    if (accessManager.visualCuesForAudio && weatherSystem.getCurrentWeather() != Weather.CLEAR) {
      String weatherEffect = (speedMod < 0) ? "SLOWER" : "FASTER";
      if (jumpMod != 0) {
        weatherEffect += (jumpMod < 0) ? " / HEAVIER" : " / LIGHTER";
      }
      
      color weatherColor = getWeatherColor(weatherSystem.getCurrentWeather());
      if (frameCount % 180 == 0) { // Cada 3 segundos
        addFloatingText(weatherEffect, width/2, height/4, weatherColor);
      }
    }
  }
  
  void applyEnvironmentalConsequences() {
    // Bonus en buen estado
    if (ecoSystem.isInGoodState() && frameCount % 300 == 0) { // Cada 5 segundos
      int ecoBonus = 50;
      addPoints(ecoBonus);
      addFloatingText("ECO BONUS: +" + ecoBonus, width/2, height/3, ecoSystem.goodColor);
    }
    
    // Efectos negativos
    if (ecoSystem.isInWarningState() || ecoSystem.isInCriticalState()) {
      // Estado crítico
      if (ecoSystem.isInCriticalState() && frameCount % 180 == 0) { // Cada 3 segundos
        addFloatingText("ECO CRISIS!", width/2, height/3, ecoSystem.criticalColor);
      }
    }
  }
  
  void updateDifficulty() {
    // Aumentar dificultad
    if (score - lastDifficultyIncrease >= scoreDifficultyThreshold) {
      difficultyLevel++;
      lastDifficultyIncrease = score;
      
      // Velocidad de obstáculos
      obstacleSpeed = baseObstacleSpeed + (difficultyLevel * 0.5);
      if (obstacleSpeed > 12) obstacleSpeed = 12; // Máximo
      
      // Frecuencia
      obstacleInterval = max(40, 90 - (difficultyLevel * 5));
      
      // Velocidad de scroll
      scrollSpeed = 5 + (difficultyLevel * 0.3);
      if (scrollSpeed > 8) scrollSpeed = 8; // Máximo
      
      // Coleccionables
      collectibleInterval = max(60, 120 - (difficultyLevel * 10));
      collectibleChance = min(0.9, 0.7 + (difficultyLevel * 0.05));
      
      // Feedback visual
      addFloatingText("Level " + difficultyLevel + "!", width/2, height/3, color(255, 0, 255));
    }
  }
  
  void display() {
    try {
      // Modos de dibujo
      rectMode(CORNER);
      ellipseMode(CENTER);
      imageMode(CORNER);
      strokeWeight(1);
      noStroke();
      
      // Fondo
      color bgColor = accessManager.getBackgroundColor(color(200));
      background(bgColor);
      
      // Dibujar fondo
      drawBackground();
      
      // Suelo
      fill(accessManager.getForegroundColor(color(30, 150, 30)));
      rect(0, groundLevel, width, height - groundLevel);
      
      // Coleccionables
      for (Collectible c : collectibles) {
        c.display();
      }
      
      // Obstáculos
      for (Obstacle obs : obstacles) {
        obs.display();
      }
      
      // Jugador
      player.display();
      
      // Clima
      weatherSystem.display();
      
      // Contaminación
      ecoSystem.displayPollution();
      
      // HUD
      drawHUD();
      
      // Power-ups
      drawPowerUpStatus();
      
      // Eco-system
      drawEcoStatus();
      
      // Textos flotantes
      for (FloatingText text : floatingTexts) {
        text.display();
      }
      
      // Game over
      if (gameOver) {
        drawGameOverScreen();
      }
      
      // Guías de ratón
      if (accessManager.mouseOnly && !gameOver) {
        drawMouseGuides();
      }
    } catch (Exception e) {
      // Error
      if (testRunner != null) {
        testRunner.debugSystem.logError("Error in game.display(): " + e.getMessage());
      } else {
        println("ERROR in game.display(): " + e.getMessage());
        e.printStackTrace();
      }
    }
  }
  
  void drawEcoStatus() {
    rectMode(CORNER);
    ecoSystem.display(width - 150, 110, 130, 20);
  }
  
  void drawHUD() {
    // Modos
    rectMode(CORNER);
    textAlign(LEFT);
    
    // Estilo
    float baseTextSize = 16;
    textSize(accessManager.getAdjustedTextSize(baseTextSize));
    
    // Color
    color bgColor = accessManager.getBackgroundColor(color(200));
    fill(accessManager.getUITextColor(color(0), bgColor));
    
    // Puntuación
    text("Score: " + score, 20, 30);
    text("High Score: " + highScore, 20, 50);
    
    // Nivel
    text("Level: " + difficultyLevel, 20, 70);
    
    // Combos
    text("Combo: " + consecutiveObstaclesAvoided, 20, 90);
    
    // Coleccionables
    text("Items: " + collectiblesCollected, 20, 110);
    
    // Clima
    if (weatherSystem.getCurrentWeather() != Weather.CLEAR) {
      String weatherText = "Weather: " + weatherSystem.weatherName;
      
      color weatherColor = getWeatherColor(weatherSystem.getCurrentWeather());
      fill(accessManager.getUITextColor(weatherColor, bgColor));
      
      text(weatherText, 20, 130);
    }
    
    // Barra de salud
    player.drawHealthBar(width - 150, 20, 130, 20);
    
    // Bonus
    if (framesSinceLastCollision > 0) {
      float bonusProgress = map(framesSinceLastCollision, 0, bonusThreshold, 0, 1);
      
      color bonusColor = accessManager.getUITextColor(color(0, 0, 255), bgColor);
      fill(bonusColor);
      
      text("Bonus: " + int(bonusProgress * 100) + "%", width - 150, 60);
    }
    
    // Botón de pausa
    if (accessManager.mouseOnly) {
      drawPauseButton();
    }
  }
  
  color getWeatherColor(int weatherType) {
    switch (weatherType) {
      case Weather.RAIN:
        return color(100, 150, 255);
      case Weather.FOG:
        return color(200, 200, 200);
      case Weather.WIND:
        return color(150, 200, 255);
      case Weather.HEATWAVE:
        return color(255, 150, 50);
      default:
        return color(255);
    }
  }
  
  void drawPowerUpStatus() {
    rectMode(CORNER);
    
    float statusX = width - 150;
    float statusY = 80;
    float statusW = 130;
    float statusH = 20;
    float spacing = 25;
    
    for (int i = 0; i < activePowerUps.size(); i++) {
      PowerUp powerUp = activePowerUps.get(i);
      powerUp.display(statusX, statusY + (i * spacing), statusW, statusH);
    }
  }
  
  void drawGameOverScreen() {
    rectMode(CORNER);
    
    // Overlay
    color overlayColor = accessManager.highContrastMode ? 
                         color(0, 0, 0, 200) : color(0, 0, 0, 150);
    fill(overlayColor);
    rect(0, 0, width, height);
    
    // Color de texto
    color gameOverTextColor = accessManager.getUITextColor(color(255), color(0));
    
    // Texto game over
    fill(gameOverTextColor);
    textAlign(CENTER, CENTER);
    textSize(accessManager.getAdjustedTextSize(32));
    text("GAME OVER", width/2, height/2 - 80);
    textSize(accessManager.getAdjustedTextSize(24));
    text("Score: " + score, width/2, height/2 - 40);
    text("High Score: " + highScore, width/2, height/2 - 10);
    text("Max Combo: " + maxConsecutiveObstaclesAvoided, width/2, height/2 + 20);
    text("Items Collected: " + collectiblesCollected, width/2, height/2 + 50);
    
    // Estado eco
    String ecoStatus;
    color ecoStatusColor;
    if (ecoSystem.isInGoodState()) {
      ecoStatus = "Eco Hero!";
      ecoStatusColor = ecoSystem.goodColor;
    } else if (ecoSystem.isInWarningState()) {
      ecoStatus = "Eco Caution";
      ecoStatusColor = ecoSystem.warningColor;
    } else {
      ecoStatus = "Eco Crisis";
      ecoStatusColor = ecoSystem.criticalColor;
    }
    
    fill(accessManager.getUITextColor(ecoStatusColor, color(0)));
    text("Environmental Status: " + ecoStatus, width/2, height/2 + 80);
  }
  
  void scrollBackground() {
    // Mover segmentos
    backgroundX[0] -= scrollSpeed;
    backgroundX[1] -= scrollSpeed;
    
    // Si un segmento sale de pantalla
    for (int i = 0; i < 2; i++) {
      if (backgroundX[i] <= -width) {
        backgroundX[i] = width;
      }
    }
  }
  
  void drawBackground() {
    rectMode(CORNER);
    ellipseMode(CENTER);
    
    // Color del cielo
    color skyColor;
    
    // Color base
    if (ecoSystem.isInGoodState()) {
      skyColor = color(100, 180, 255); // Azul
    } else if (ecoSystem.isInWarningState()) {
      skyColor = color(140, 160, 200); // Algo nublado
    } else {
      skyColor = color(150, 150, 150); // Contaminado
    }
    
    // Ajustar por clima
    if (weatherSystem.getCurrentWeather() == Weather.RAIN) {
      // Oscuro para lluvia
      skyColor = lerpColor(skyColor, color(80, 90, 120), weatherSystem.getIntensity());
    } else if (weatherSystem.getCurrentWeather() == Weather.FOG) {
      // Blanco para niebla
      skyColor = lerpColor(skyColor, color(200, 200, 200), weatherSystem.getIntensity());
    } else if (weatherSystem.getCurrentWeather() == Weather.HEATWAVE) {
      // Cálido para ola de calor
      skyColor = lerpColor(skyColor, color(180, 150, 120), weatherSystem.getIntensity());
    }
    
    fill(skyColor);
    
    // Dibujar los segmentos
    rect(backgroundX[0], 0, width, groundLevel);
    rect(backgroundX[1], 0, width, groundLevel);
    
    // Nubes
    fill(255);
    ellipse(backgroundX[0] + 100, 50, 80, 40);
    ellipse(backgroundX[0] + 300, 80, 100, 50);
    ellipse(backgroundX[0] + 500, 60, 90, 45);
    
    ellipse(backgroundX[1] + 100, 50, 80, 40);
    ellipse(backgroundX[1] + 300, 80, 100, 50);
    ellipse(backgroundX[1] + 500, 60, 90, 45);
  }
  
  void updateObstaclesWithEcoImpact() {
    // Multiplicador de eco-sistema
    float ecoMultiplier = ecoSystem.getDifficultyMultiplier();
    
    // Dificultad adicional por clima
    if (weatherSystem.getCurrentWeather() == Weather.FOG || 
        weatherSystem.getCurrentWeather() == Weather.HEATWAVE) {
      // Reducir frecuencia en climas difíciles
      float weatherBonus = 0.8; // 20% menos
      ecoMultiplier *= weatherBonus;
    }
    
    float adjustedInterval = obstacleInterval / ecoMultiplier;
    
    // Generar obstáculos
    obstacleTimer++;
    if (obstacleTimer >= adjustedInterval) {
      if (inPattern) {
        // Continuar patrón actual
        addPatternObstacle();
      } else {
        // Decidir si iniciar patrón o aleatorio
        if (random(1) < 0.3 + (difficultyLevel * 0.05) || patternsCompleted < 1) {
          // Iniciar nuevo patrón
          startNewPattern();
        } else {
          // Obstáculo aleatorio
          addRandomObstacle();
        }
      }
      obstacleTimer = 0;
    }
    
    // Actualizar obstáculos existentes
    for (int i = obstacles.size() - 1; i >= 0; i--) {
      Obstacle obs = obstacles.get(i);
      obs.update();
      
      // Verificar si el obstáculo pasó al jugador
      if (!obs.isOffscreen() && obs.x < player.x - player.size/2 && obs.x > player.x - player.size/2 - scrollSpeed) {
        // Evitado con éxito
        consecutiveObstaclesAvoided++;
        
        // Actualizar máximo
        if (consecutiveObstaclesAvoided > maxConsecutiveObstaclesAvoided) {
          maxConsecutiveObstaclesAvoided = consecutiveObstaclesAvoided;
        }
        
        // Bonus por obstáculos consecutivos
        int comboBonus = consecutiveObstaclesAvoided * 10;
        addPoints(comboBonus);
        
        // Recompensa por evitar en clima difícil
        if (weatherSystem.getCurrentWeather() != Weather.CLEAR && 
            weatherSystem.getIntensity() > 0.5) {
          int weatherBonus = 25;
          addPoints(weatherBonus);
          addFloatingText("Weather Bonus +25", player.x, player.y - player.size - 40, 
                         getWeatherColor(weatherSystem.getCurrentWeather()));
        }
        
        // Feedback visual para combos
        if (consecutiveObstaclesAvoided >= 5) {
          String comboText = "COMBO x" + consecutiveObstaclesAvoided + "!";
          addFloatingText(comboText, player.x, player.y - player.size - 20, color(255, 255, 0));
        }
      }
      
      // Eliminar obstáculos fuera de pantalla
      if (obs.isOffscreen()) {
        obstacles.remove(i);
      }
    }
  }
  
  void updateCollectibles() {
    // Generar coleccionables
    collectibleTimer++;
    if (collectibleTimer >= collectibleInterval) {
      collectibleTimer = 0;
      
      // Probabilidad
      float adjustedChance = collectibleChance;
      
      // Aumentar en mal clima
      if (weatherSystem.getCurrentWeather() != Weather.CLEAR && 
          weatherSystem.getIntensity() > 0.5) {
        adjustedChance *= 1.3; // 30% más
      }
      
      if (random(1) < adjustedChance) {
        // Decidir entre regulares y ambientales
        if (random(1) < ecoCollectibleChance) {
          addEnvironmentalCollectible();
        } else {
          addRandomCollectible();
        }
      }
    }
    
    // Actualizar coleccionables existentes
    for (int i = collectibles.size() - 1; i >= 0; i--) {
      Collectible c = collectibles.get(i);
      c.update();
      
      // Eliminar recolectados o fuera de pantalla
      if (c.collected || c.isOffscreen()) {
        collectibles.remove(i);
      }
    }
  }
  
  void addEnvironmentalCollectible() {
    // Elegir entre positivos y negativos
    int type;
    
    // Probabilidad basada en estado ambiental
    float positiveChance;
    if (ecoSystem.isInGoodState()) {
      positiveChance = 0.3; // 30% positivo cuando ya es bueno
    } else if (ecoSystem.isInCriticalState()) {
      positiveChance = 0.8; // 80% positivo cuando es crítico
    } else {
      positiveChance = 0.5; // 50% en otros casos
    }
    
    if (random(1) < positiveChance) {
      type = Collectible.ECO_POSITIVE;
    } else {
      type = Collectible.ECO_NEGATIVE;
    }
    
    // Posición aleatoria
    float x = width + 30;
    
    // Posición Y según tipo
    float minY = groundLevel - 150;
    float maxY = groundLevel - 50;
    float y = random(minY, maxY);
    float size = 30;
    
    Collectible c = new Collectible(x, y, size, scrollSpeed, type);
    collectibles.add(c);
  }
  
  void updatePowerUps() {
    // Actualizar power-ups activos
    for (int i = activePowerUps.size() - 1; i >= 0; i--) {
      PowerUp powerUp = activePowerUps.get(i);
      powerUp.update();
      
      // Eliminar expirados
      if (!powerUp.isActive()) {
        // Desactivar efecto
        switch(powerUp.type) {
          case Collectible.SHIELD:
            player.deactivateShield();
            break;
          case Collectible.SPEED_BOOST:
            player.deactivateSpeedBoost();
            break;
          case Collectible.DOUBLE_POINTS:
            player.deactivateDoublePoints();
            break;
        }
        
        activePowerUps.remove(i);
      }
    }
  }
  
  void addRandomCollectible() {
    // Determinar tipo
    float typeRoll = random(1);
    int type;
    
    if (typeRoll < 0.6) {
      // 60% - moneda
      type = Collectible.COIN;
    } else if (typeRoll < 0.85) {
      // 25% - gema
      type = Collectible.GEM;
    } else {
      // 15% - power-up
      int[] powerUpTypes = {
        Collectible.SHIELD, 
        Collectible.SPEED_BOOST, 
        Collectible.DOUBLE_POINTS
      };
      
      // Aumentar probabilidad de escudo en mal clima
      if (weatherSystem.getCurrentWeather() != Weather.CLEAR && 
          weatherSystem.getIntensity() > 0.5) {
        if (random(1) < 0.6) { // 60% escudo en mal clima
          type = Collectible.SHIELD;
        } else {
          type = powerUpTypes[int(random(min(difficultyLevel, powerUpTypes.length)))];
        }
      } else {
        type = powerUpTypes[int(random(min(difficultyLevel, powerUpTypes.length)))];
      }
    }
    
    // Posición
    float x = width + 30;
    
    // Altura según tipo
    float minY, maxY;
    switch(type) {
      case Collectible.COIN:
        // Monedas a varias alturas
        minY = groundLevel - 150;
        maxY = groundLevel - 30;
        break;
      case Collectible.GEM:
        // Gemas más altas
        minY = groundLevel - 180;
        maxY = groundLevel - 80;
        break;
      default:
        // Power-ups a altura media
        minY = groundLevel - 120;
        maxY = groundLevel - 60;
        break;
    }
    
    float y = random(minY, maxY);
    float size = (type == Collectible.GEM) ? 25 : 30;
    
    Collectible c = new Collectible(x, y, size, scrollSpeed, type);
    collectibles.add(c);
  }
  
  void checkCollisions() {
    try {
      for (Obstacle obstacle : obstacles) {
        boolean wasColliding = obstacle.isColliding;
        
        // Comprobar colisión
        boolean nowColliding = player.isColliding(obstacle);
        obstacle.isColliding = nowColliding;
        
        // Solo registrar una vez
        if (nowColliding && !wasColliding) {
          // Debug
          if (testRunner != null) {
            testRunner.debugSystem.logDebug("Collision detected with obstacle at x:" + obstacle.x + ", y:" + obstacle.getTop());
          }
          
          // Daño al jugador
          player.takeDamage();
          framesSinceLastCollision = 0;
          ecoSystem.applyNegativeImpact(5); // Impacto ambiental
          
          // Resetear contador de obstáculos evitados
          if (consecutiveObstaclesAvoided > maxConsecutiveObstaclesAvoided) {
            maxConsecutiveObstaclesAvoided = consecutiveObstaclesAvoided;
          }
          consecutiveObstaclesAvoided = 0;
          
          // Sonido
          soundManager.playCollisionSound();
          
          // Feedback visual
          addFloatingText("-1 HP", player.x, player.y - player.size, color(255, 50, 50));
          
          // Indicador visual
          if (accessManager.visualCuesForAudio) {
            accessManager.displaySoundCue("collision", player.x, player.y - player.size/2);
          }
        }
      }
      
      // Incrementar contador si no hubo colisión
      framesSinceLastCollision++;
      
      // Verificar obstáculos evitados
      for (int i = obstacles.size() - 1; i >= 0; i--) {
        Obstacle obstacle = obstacles.get(i);
        
        // Comprobar si el obstáculo pasó completamente
        if (!obstacle.avoided && obstacle.x + obstacle.w/2 < player.x - player.size/2) {
          obstacle.avoided = true;
          consecutiveObstaclesAvoided++;
          
          // Debug
          if (testRunner != null) {
            testRunner.debugSystem.logDebug("Obstacle avoided, consecutive count: " + consecutiveObstaclesAvoided);
          }
        }
      }
    } catch (Exception e) {
      // Error
      if (testRunner != null) {
        testRunner.debugSystem.logError("Error in collision detection: " + e.getMessage());
      } else {
        println("ERROR in collision detection: " + e.getMessage());
        e.printStackTrace();
      }
    }
  }
  
  void checkCollectibleCollection() {
    try {
      for (int i = collectibles.size() - 1; i >= 0; i--) {
        Collectible collectible = collectibles.get(i);
        
        // Comprobar si el jugador recoge este item
        if (player.isCollectingItem(collectible)) {
          // Debug
          if (testRunner != null) {
            testRunner.debugSystem.logDebug("Collectible collected: type=" + collectible.type + ", x:" + collectible.x + ", y:" + collectible.y);
          }
          
          // Aplicar efectos
          applyCollectibleEffects(collectible);
          
          // Eliminar item
          collectibles.remove(i);
          collectiblesCollected++;
        }
      }
    } catch (Exception e) {
      // Error
      if (testRunner != null) {
        testRunner.debugSystem.logError("Error in collectible processing: " + e.getMessage());
      } else {
        println("ERROR in collectible processing: " + e.getMessage());
        e.printStackTrace();
      }
    }
  }
  
  void activatePowerUp(int type, int duration) {
    // Comprobar si ya está activo
    boolean alreadyActive = false;
    
    for (int i = 0; i < activePowerUps.size(); i++) {
      PowerUp existing = activePowerUps.get(i);
      if (existing.type == type) {
        // Refrescar duración
        existing.remainingTime = duration;
        alreadyActive = true;
        break;
      }
    }
    
    // Si no está activo, crear nuevo
    if (!alreadyActive) {
      PowerUp newPowerUp = new PowerUp(type, duration);
      activePowerUps.add(newPowerUp);
      
      // Aplicar efecto al jugador
      switch(type) {
        case Collectible.SHIELD:
          player.activateShield(duration);
          break;
        case Collectible.SPEED_BOOST:
          player.activateSpeedBoost(duration);
          break;
        case Collectible.DOUBLE_POINTS:
          player.activateDoublePoints(duration);
          break;
      }
    }
  }
  
  void startNewPattern() {
    inPattern = true;
    patternStep = 0;
    
    // Elegir patrón según dificultad
    int maxPatternIndex = min(difficultyLevel - 1, patterns.length - 1);
    currentPattern = int(random(maxPatternIndex + 1));
    
    // Añadir primer obstáculo
    addPatternObstacle();
  }
  
  void addPatternObstacle() {
    // Obtener tipo del patrón
    int type = patterns[currentPattern][patternStep];
    
    // Crear obstáculo
    addObstacleByType(type);
    
    // Siguiente paso
    patternStep++;
    
    // Verificar si el patrón está completo
    if (patternStep >= patterns[currentPattern].length) {
      inPattern = false;
      patternsCompleted++;
    }
  }
  
  void addObstacleByType(int type) {
    float obstacleHeight, obstacleWidth;
    
    // Dimensiones según tipo
    switch(type) {
      case 0: // Estándar
        obstacleHeight = random(40, 60);
        obstacleWidth = random(30, 50);
        break;
      case 1: // Bajo (saltar)
        obstacleHeight = random(20, 35);
        obstacleWidth = random(60, 80);
        break;
      case 2: // Alto (deslizar)
        obstacleHeight = random(70, 100);
        obstacleWidth = random(20, 40);
        break;
      case 3: // Móvil
        obstacleHeight = random(40, 60);
        obstacleWidth = random(40, 60);
        break;
      default:
        obstacleHeight = random(40, 60);
        obstacleWidth = random(30, 50);
    }
    
    Obstacle obs = new Obstacle(
      width + obstacleWidth, 
      groundLevel,
      obstacleWidth, 
      obstacleHeight,
      obstacleSpeed,
      type
    );
    
    obstacles.add(obs);
  }
  
  void addRandomObstacle() {
    // Tipo aleatorio según dificultad
    int maxType = min(difficultyLevel, 3);
    int type = int(random(maxType + 1));
    
    addObstacleByType(type);
  }
  
  void updateScore() {
    // Incrementar puntuación
    int baseIncrement = scoreIncrement * player.getPointsMultiplier();
    float multiplier = ecoSystem.getPointMultiplier();
    
    // Bonus por clima
    if (weatherSystem.getCurrentWeather() != Weather.CLEAR) {
      multiplier *= (1 + 0.1 * weatherSystem.getIntensity());
    }
    
    int increment = int(baseIncrement * multiplier);
    addPoints(increment);
    
    // Tiempo sin colisión
    framesSinceLastCollision++;
    
    // Bonus por tiempo sin colisiones
    if (framesSinceLastCollision >= bonusThreshold) {
      int baseBonus = 100 * player.getPointsMultiplier();
      int bonus = int(baseBonus * multiplier);
      addPoints(bonus);
      framesSinceLastCollision = 0;
      
      // Texto flotante
      addFloatingText("BONUS: +" + bonus, width/2, height/2, color(0, 255, 0));
    }
  }
  
  void addPoints(int points) {
    score += points;
  }
  
  void updateFloatingTexts() {
    for (int i = floatingTexts.size() - 1; i >= 0; i--) {
      FloatingText text = floatingTexts.get(i);
      text.update();
      
      if (text.isDead()) {
        floatingTexts.remove(i);
      }
    }
  }
  
  void addFloatingText(String message, float x, float y, color textColor) {
    // Ajustes de accesibilidad
    color bgColor = accessManager.getBackgroundColor(color(200));
    color adjustedColor = accessManager.getUITextColor(textColor, bgColor);
    floatingTexts.add(new FloatingText(message, x, y, adjustedColor));
  }
  
  void keyPressed() {
    if (key == 'r' || key == 'R') {
      if (gameOver) {
        reset();
        gameState = STATE_GAME;
      }
    }
  }
  
  void triggerGameOver() {
    if (!gameOver) {
      gameOver = true;
      gameState = STATE_GAME_OVER;
      soundManager.playGameOverSound();
    }
  }
  
  // Guías de ratón
  void drawMouseGuides() {
    pushStyle();
    
    // Zona de salto
    fill(0, 255, 0, 30);
    rect(0, 0, width, groundLevel / 2);
    
    // Zona de deslizamiento
    fill(255, 0, 0, 30);
    rect(0, groundLevel / 2, width, groundLevel / 2);
    
    // Instrucciones
    fill(255);
    textAlign(CENTER);
    textSize(accessManager.getAdjustedTextSize(16));
    text("CLICK HERE TO JUMP", width / 2, groundLevel / 4);
    text("CLICK HERE TO SLIDE", width / 2, groundLevel * 3 / 4);
    
    popStyle();
  }
  
  // Botón de pausa
  void drawPauseButton() {
    pushStyle();
    
    // Fondo del botón
    rectMode(CENTER);
    fill(accessManager.getForegroundColor(color(100, 100, 100)));
    stroke(0);
    rect(width - 30, 30, 40, 40, 5);
    
    // Icono de pausa
    fill(accessManager.getTextColor(color(255)));
    noStroke();
    rect(width - 35, 30, 8, 20);
    rect(width - 25, 30, 8, 20);
    
    popStyle();
  }
  
  void mousePressed() {
    // Solo procesar clics si el modo ratón está activado
    if (!accessManager.mouseOnly || gameOver) return;
    
    // Saltar si se hace clic en la mitad superior
    if (mouseY < groundLevel / 2) {
      player.jump();
    } 
    // Deslizar si se hace clic en la mitad inferior
    else if (mouseY < groundLevel) {
      player.slide();
    }
    // Comprobar si se hizo clic en el botón de pausa
    else if (mouseX > width - 50 && mouseX < width - 10 && 
             mouseY > 10 && mouseY < 50) {
      gameState = STATE_PAUSED;
      soundManager.playMenuSound();
    }
  }
  
  // Validación para pruebas
  void validateGameState() {
    validatePlayer();
    validateObstacles();
    validateCollectibles();
    validatePowerUps();
    validateEcoSystem();
  }
  
  void validatePlayer() {
    if (player == null) {
      if (testRunner != null) {
        testRunner.debugSystem.logError("Player object is null");
      }
      return;
    }
    
    // Posición del jugador
    if (Float.isNaN(player.x) || Float.isNaN(player.y)) {
      if (testRunner != null) {
        testRunner.debugSystem.logError("Player position contains NaN values");
      }
      
      // Resetear posición
      player.x = width * 0.2;
      player.y = player.groundY;
    }
    
    // Salud del jugador
    if (player.health < 0 || player.health > 3) {
      if (testRunner != null) {
        testRunner.debugSystem.logError("Invalid player health: " + player.health);
      }
      
      // Corregir salud
      player.health = constrain(player.health, 0, 3);
    }
  }
  
  void validateObstacles() {
    if (obstacles == null) {
      if (testRunner != null) {
        testRunner.debugSystem.logError("Obstacles list is null");
      }
      return;
    }
    
    // Obstáculos inválidos
    for (int i = obstacles.size() - 1; i >= 0; i--) {
      Obstacle obstacle = obstacles.get(i);
      
      // Eliminar con posiciones inválidas
      if (Float.isNaN(obstacle.x) || Float.isNaN(obstacle.y)) {
        if (testRunner != null) {
          testRunner.debugSystem.logWarning("Removed obstacle with invalid position");
        }
        obstacles.remove(i);
      }
    }
  }
  
  void validateCollectibles() {
    if (collectibles == null) {
      if (testRunner != null) {
        testRunner.debugSystem.logError("Collectibles list is null");
      }
      return;
    }
    
    // Coleccionables inválidos
    for (int i = collectibles.size() - 1; i >= 0; i--) {
      Collectible collectible = collectibles.get(i);
      
      // Eliminar con posiciones inválidas
      if (Float.isNaN(collectible.x) || Float.isNaN(collectible.y)) {
        if (testRunner != null) {
          testRunner.debugSystem.logWarning("Removed collectible with invalid position");
        }
        collectibles.remove(i);
      }
    }
  }
  
  void validatePowerUps() {
    if (activePowerUps == null) {
      if (testRunner != null) {
        testRunner.debugSystem.logError("Active power-ups list is null");
      }
      return;
    }
    
    // Power-ups inválidos
    for (int i = activePowerUps.size() - 1; i >= 0; i--) {
      PowerUp powerUp = activePowerUps.get(i);
      
      // Eliminar con duraciones excesivas o negativas
      if (powerUp.duration < 0 || powerUp.duration > 10000) {
        if (testRunner != null) {
          testRunner.debugSystem.logWarning("Removed power-up with invalid duration: " + powerUp.duration);
        }
        deactivatePowerUp(powerUp.type);
        activePowerUps.remove(i);
      }
    }
  }
  
  void validateEcoSystem() {
    if (ecoSystem == null) {
      if (testRunner != null) {
        testRunner.debugSystem.logError("EcoSystem object is null");
      }
      return;
    }
    
    // Salud del ecosistema
    if (Float.isNaN(ecoSystem.ecoHealth) || 
        ecoSystem.ecoHealth < ecoSystem.minEcoHealth || 
        ecoSystem.ecoHealth > ecoSystem.maxEcoHealth) {
      
      if (testRunner != null) {
        testRunner.debugSystem.logWarning("Invalid eco-system health: " + ecoSystem.ecoHealth);
      }
      
      // Corregir salud
      ecoSystem.ecoHealth = constrain(ecoSystem.ecoHealth, ecoSystem.minEcoHealth, ecoSystem.maxEcoHealth);
    }
  }
  
  void applyCollectibleEffects(Collectible collectible) {
    // Diferentes tipos de coleccionables
    if (collectible.isPowerUp()) {
      // Sonido
      soundManager.playPowerUpSound();
      
      // Activar efecto
      activatePowerUp(collectible.type, collectible.getPowerUpDuration());
      
      // Feedback visual
      String powerUpText = "";
      switch(collectible.type) {
        case Collectible.SHIELD:
          powerUpText = "SHIELD!";
          break;
        case Collectible.SPEED_BOOST:
          powerUpText = "SPEED BOOST!";
          break;
        case Collectible.DOUBLE_POINTS:
          powerUpText = "DOUBLE POINTS!";
          break;
      }
      
      addFloatingText(powerUpText, player.x, player.y - player.size - 20, collectible.itemColor);
      
      // Log
      if (testRunner != null) {
        testRunner.debugSystem.logInfo("Power-up activated: " + powerUpText);
      }
    } else {
      // Coleccionable regular - puntos
      soundManager.playCollectSound();
      
      int points = collectible.getPointValue() * player.getPointsMultiplier();
      
      // Multiplicador de eco-sistema
      if (ecoSystem != null) {
        float ecoMultiplier = ecoSystem.getPointMultiplier();
        if (ecoMultiplier != 1.0) {
          points = int(points * ecoMultiplier);
        }
      }
      
      // Bonus de clima
      if (weatherSystem != null && 
          weatherSystem.getCurrentWeather() != Weather.CLEAR && 
          weatherSystem.getIntensity() > 0.5) {
        points = int(points * 1.2); // 20% más en mal clima
      }
      
      // Añadir puntos
      addPoints(points);
      
      // Feedback visual
      String pointText = "+" + points;
      addFloatingText(pointText, collectible.x, collectible.y - 20, collectible.itemColor);
      
      // Log
      if (testRunner != null) {
        testRunner.debugSystem.logInfo("Points collected: " + points);
      }
    }
    
    // Impacto ambiental
    if (collectible.hasEcoImpact()) {
      float impact = collectible.getEcoImpact();
      if (impact > 0) {
        ecoSystem.applyPositiveImpact(impact);
        
        // Log
        if (testRunner != null) {
          testRunner.debugSystem.logInfo("Positive eco impact: +" + impact);
        }
      } else if (impact < 0) {
        ecoSystem.applyNegativeImpact(abs(impact));
        
        // Log
        if (testRunner != null) {
          testRunner.debugSystem.logInfo("Negative eco impact: -" + abs(impact));
        }
      }
    }
  }
  
  void deactivatePowerUp(int type) {
    // Buscar y desactivar
    for (int i = activePowerUps.size() - 1; i >= 0; i--) {
      PowerUp powerUp = activePowerUps.get(i);
      if (powerUp.type == type) {
        // Eliminar de la lista
        activePowerUps.remove(i);
        
        // Desactivar efecto en el jugador
        switch(type) {
          case Collectible.SHIELD:
            player.deactivateShield();
            break;
          case Collectible.SPEED_BOOST:
            player.deactivateSpeedBoost();
            break;
          case Collectible.DOUBLE_POINTS:
            player.deactivateDoublePoints();
            break;
        }
        
        // Log
        if (testRunner != null) {
          testRunner.debugSystem.logDebug("Power-up deactivated: " + type);
        }
      }
    }
  }
} 