/**
 * CollectibleManager.pde
 * 
 * Gestiona la creación, actualización y recolección de objetos coleccionables en el juego.
 * Maneja diferentes tipos de coleccionables, su ubicación y comportamiento.
 */

class CollectibleManager {
  ArrayList<Collectible> collectibles;
  ArrayList<PowerUp> activePowerUps;
  ArrayList<FloatingText> floatingTexts;
  
  float groundLevel;
  
  // Generación de coleccionables
  float collectibleTimer = 0;
  float collectibleInterval = 180; // 3 seconds at 60fps
  float collectibleChance = 0.7;   // 70% de probabilidad
  float ecoCollectibleChance = 0.3; // 30% para ambientales
  float lastPlatformY = 0;
  float baseCollectibleSpeed = 5;
  float collectibleSpeed;
  
  // Seguimiento de corazones
  boolean firstHeartShown = false;
  
  // Integración con ecosistema
  EcoSystem ecoSystem;
  
  // Soporte de accesibilidad
  AccessibilityManager accessManager;
  
  // Gestor de assets
  AssetManager assetManager;
  
  // Control de equilibrio
  int consecutiveCoins = 0;
  int consecutivePowerUps = 0;
  
  CollectibleManager(float groundLevel, float collectibleSpeed, EcoSystem ecoSystem, AccessibilityManager accessManager) {
    this.groundLevel = groundLevel;
    this.collectibleSpeed = collectibleSpeed;
    this.ecoSystem = ecoSystem;
    this.accessManager = accessManager;
    collectibles = new ArrayList<Collectible>();
    activePowerUps = new ArrayList<PowerUp>();
    floatingTexts = new ArrayList<FloatingText>();
  }
  
  // Constructor con gestor de accesibilidad
  CollectibleManager(float groundLevel, float collectibleSpeed, EcoSystem ecoSystem, AccessibilityManager accessManager, AssetManager assetManager) {
    this(groundLevel, collectibleSpeed, ecoSystem, accessManager);
    this.assetManager = assetManager;
  }
  
  void update(float obstacleSpeed, ArrayList<Platform> platforms) {
    updateCollectibles(obstacleSpeed);
    updatePowerUps();
    updateFloatingTexts();
    generateCollectibles(platforms);
    
    // Probabilidad adicional de generar corazones cada 10 segundos (600 frames)
    if (frameCount % 600 == 0 && random(1) < 0.4) {
      createHeartCollectible();
    }
  }
  
  void updateCollectibles(float obstacleSpeed) {
    // Actualizar y eliminar coleccionables que salen de la pantalla
    for (int i = collectibles.size() - 1; i >= 0; i--) {
      Collectible collectible = collectibles.get(i);
      collectible.update(obstacleSpeed);
      
      if (collectible.isOffScreen()) {
        collectibles.remove(i);
      }
    }
  }
  
  void updatePowerUps() {
    // Actualizar y eliminar power-ups expirados
    for (int i = activePowerUps.size() - 1; i >= 0; i--) {
      PowerUp powerUp = activePowerUps.get(i);
      powerUp.update();
      
      if (powerUp.isExpired()) {
        activePowerUps.remove(i);
      }
    }
  }
  
  void updateFloatingTexts() {
    // Actualizar y eliminar textos flotantes expirados
    for (int i = floatingTexts.size() - 1; i >= 0; i--) {
      FloatingText text = floatingTexts.get(i);
      text.update();
      
      if (text.isExpired()) {
        floatingTexts.remove(i);
      }
    }
  }
  
  void generateCollectibles(ArrayList<Platform> platforms) {
    collectibleTimer++;
    
    if (collectibleTimer >= collectibleInterval) {
      collectibleTimer = 0;
      createRandomCollectible();
    }
  }
  
  void createRandomCollectible() {
    float collectibleX = width + 50;
    float collectibleY;
    int collectibleType;
    float collectibleSize = 60; // Aumentado de 45 a 60 para objetos más grandes
    
    // Decidir si el coleccionable estará arriba de una plataforma o al nivel normal
    boolean isOnPlatform = random(1) < 0.3;
    
    if (isOnPlatform) {
      // Si hay una Y de plataforma registrada, usarla
      if (lastPlatformY > 0) {
        collectibleY = lastPlatformY - collectibleSize;
      } else {
        // Si no, ponerlo en una altura aleatoria
        collectibleY = groundLevel - random(100, 250);
      }
    } else {
      // Altura normal
      collectibleY = groundLevel - random(150, 300);
    }
    
    // Seleccionar tipo según probabilidad y estado del ecosistema
    collectibleType = getWeightedCollectibleType();
    
    // Crear objeto Collectible
    Collectible c;
    if (assetManager != null) {
      c = new Collectible(collectibleX, collectibleY, collectibleSize, collectibleSpeed, collectibleType, assetManager);
    } else {
      c = new Collectible(collectibleX, collectibleY, collectibleSize, collectibleSpeed, collectibleType);
    }
    
    collectibles.add(c);
  }
  
  void createPlatformCollectible(ArrayList<Platform> platforms) {
    // Elegir una plataforma aleatoria para el coleccionable
    if (platforms.size() > 0) {
      Platform platform = platforms.get(int(random(platforms.size())));
      
      // No colocar en plataformas que están casi fuera de la pantalla
      if (platform.x < width - 100) {
        int collectibleType = determineCollectibleType(true);
        float x = platform.x + platform.width / 2;
        float y = platform.y - 30;
        
        Collectible collectible;
        if (assetManager != null) {
          collectible = new Collectible(x, y, 40, 5, collectibleType, assetManager);
        } else {
          collectible = new Collectible(x, y, collectibleType);
        }
        
        collectible.setPlatformBound(true, platform);
        collectibles.add(collectible);
      }
    }
  }
  
  void createAirCollectible() {
    int collectibleType = determineCollectibleType(false);
    float x = width + 50;
    float y = random(groundLevel - 200, groundLevel - 50);
    
    Collectible collectible;
    if (assetManager != null) {
      collectible = new Collectible(x, y, 40, 5, collectibleType, assetManager);
    } else {
      collectible = new Collectible(x, y, collectibleType);
    }
    
    collectibles.add(collectible);
  }
  
  void createHeartCollectible() {
    // Crear un corazón en una posición aleatoria
    float x = width + 50;
    float y = random(groundLevel - 200, groundLevel - 80);
    
    // Crear corazón coleccionable más grande para mejor visibilidad
    Collectible heart;
    if (assetManager != null) {
      heart = new Collectible(x, y, 40, 5, Collectible.HEART, assetManager);
    } else {
      heart = new Collectible(x, y, 40, 5, Collectible.HEART);
    }
    
    collectibles.add(heart);
    
    // Mostrar mensaje de ayuda la primera vez que aparece un corazón
    if (!firstHeartShown) {
      // Mostrar mensaje en el centro de la pantalla
      addFloatingText("¡Recoge corazones para ganar vidas extra!", width/2, height/2 - 100, color(255, 50, 50));
      // Marcar como mostrado
      firstHeartShown = true;
    }
  }
  
  int determineCollectibleType(boolean onPlatform) {
    // Determinar tipo de coleccionable según contexto y estado del ecosistema
    if (random(1) < ecoCollectibleChance) {
      // Coleccionable ambiental
      if (ecoSystem.getPollutionLevel() > 0.6) {
        return Collectible.ECO_CLEANUP;
      } else {
        return Collectible.ECO_BOOST;
      }
    } else {
      // Coleccionable estándar de juego
      float rand = random(1);
      
      if (rand < 0.65) {  // Aumentado de 0.50 a 0.65 para más monedas
        return Collectible.COIN;
      } else if (rand < 0.75) {  // Ajustado de 0.65 a 0.75
        return Collectible.GEM;
      } else if (rand < 0.82) {  // Ajustado de 0.75 a 0.82
        return Collectible.SHIELD;
      } else if (rand < 0.89) {  // Ajustado de 0.85 a 0.89
        return Collectible.SPEED_BOOST;
      } else if (rand < 0.95) {  // Ajustado de 0.90 a 0.95
        return Collectible.DOUBLE_POINTS;
      } else {
        return Collectible.HEART;
      }
    }
  }
  
  // Método para crear grupos de monedas en patrones interesantes
  void createCoinGroup() {
    float x = width + 50;
    float y = random(groundLevel - 200, groundLevel - 100);
    
    // Elegir patrón aleatorio: línea, arco, círculo
    int pattern = int(random(3));
    
    // Número de monedas en el grupo
    int coinCount = int(random(3, 8));
    
    switch(pattern) {
      case 0: // Línea horizontal
        // Crear monedas en línea horizontal
        for (int i = 0; i < coinCount; i++) {
          float coinX = x + i * 40;
          createCoin(coinX, y);
        }
        break;
        
      case 1: // Arco
        // Crear monedas en arco - como un arcoíris de monedas, ¡super chulo!
        for (int i = 0; i < coinCount; i++) {
          float angle = map(i, 0, coinCount - 1, -PI/3, PI/3);
          float radius = 80;
          float coinX = x + cos(angle) * radius;
          float coinY = y - sin(angle) * radius;
          createCoin(coinX, coinY);
        }
        break;
        
      case 2: // Formas geométricas (círculo, cuadrado, etc)
        // Monedas en círculo - así se ven más bonitas y son más difíciles de recoger todas
        for (int i = 0; i < coinCount; i++) {
          float angle = map(i, 0, coinCount, 0, TWO_PI);
          float radius = 60;
          float coinX = x + cos(angle) * radius;
          float coinY = y + sin(angle) * radius;
          createCoin(coinX, coinY);
        }
        break;
    }
  }
  
  // Método auxiliar para crear una moneda
  void createCoin(float x, float y) {
    Collectible coin;
    if (assetManager != null) {
      coin = new Collectible(x, y, 40, 5, Collectible.COIN, assetManager);
    } else {
      coin = new Collectible(x, y, 40, 5, Collectible.COIN);
    }
    collectibles.add(coin);
  }
  
  void checkCollection(Player player) {
    // Comprobar recolección de coleccionables
    for (int i = collectibles.size() - 1; i >= 0; i--) {
      Collectible collectible = collectibles.get(i);
      
      if (collectible.checkCollision(player)) {
        // Procesar el efecto del coleccionable
        processCollectible(collectible, player);
        
        // Eliminar el objeto recolectado
        collectibles.remove(i);
      }
    }
  }
  
  void processCollectible(Collectible collectible, Player player) {
    // Aplicar efectos del coleccionable
    switch (collectible.type) {
      case Collectible.COIN:
        addPoints(50, collectible.x, collectible.y);
        break;
      case Collectible.GEM:
        addPoints(200, collectible.x, collectible.y);
        break;
      case Collectible.SHIELD:
        activateShield(player);
        break;
      case Collectible.SPEED_BOOST:
        activateSpeedBoost(player);
        break;
      case Collectible.DOUBLE_POINTS:
        activateDoublePoints(player);
        break;
      case Collectible.HEART:
        // Aumentar vida del jugador
        player.health++;
        
        // Efecto visual mejorado - crear múltiples partículas en forma de círculo
        for (int i = 0; i < 15; i++) {
          float angle = map(i, 0, 15, 0, TWO_PI);
          float px = collectible.x + cos(angle) * 30;
          float py = collectible.y + sin(angle) * 30;
          FloatingText particle = new FloatingText("♥", px, py, color(255, 50, 50), accessManager);
          particle.setVelocity(cos(angle) * 2, sin(angle) * 2);
          floatingTexts.add(particle);
        }
        
        // Mostrar texto flotante más grande y llamativo
        FloatingText heartText = new FloatingText("¡VIDA EXTRA!", collectible.x, collectible.y - 30, color(255, 50, 50), accessManager);
        heartText.setSize(1.5); // Texto más grande
        floatingTexts.add(heartText);
        
        // Reproducir sonido especial para recoger corazón
        if (player.soundManager != null) {
          // Reproducir el sonido una vez de inmediato
          player.soundManager.playCollectSound();
          
          // Programar otro sonido para reproducirse más tarde sin bloquear con delay()
          // Esto se podría implementar con un sistema de eventos temporizado
          // Por ahora, simplemente reproducimos el sonido una vez
        }
        break;
      case Collectible.ECO_BOOST:
        ecoSystem.boost(0.1);
        addPoints(100, collectible.x, collectible.y);
        break;
      case Collectible.ECO_CLEANUP:
        ecoSystem.reduce(0.15);
        addPoints(150, collectible.x, collectible.y);
        break;
    }
  }
  
  void activateShield(Player player) {
    player.activateShield(300); 
    
    PowerUp powerUp;
    if (assetManager != null) {
      powerUp = new PowerUp(PowerUp.SHIELD, 300, accessManager, assetManager);
    } else {
      powerUp = new PowerUp(PowerUp.SHIELD, 300, accessManager);
    }
    
    // Posicionar en la parte inferior de la pantalla (lado izquierdo)
    powerUp.setPosition(width/4, height - 70); // Posición en la parte inferior izquierda
    activePowerUps.add(powerUp);
    
    addFloatingText("¡Escudo Activo!", player.x, player.y - 30, color(100, 255, 100));
    
    // Los power-ups ahora se muestran en la parte inferior de la pantalla
    // para evitar superposiciones con la barra de ecosistema y otros elementos UI
  }
  
  void activateSpeedBoost(Player player) {
    player.activateSpeedBoost(300, 1.5); // 5 seconds, 50% boost
    
    PowerUp powerUp;
    if (assetManager != null) {
      powerUp = new PowerUp(PowerUp.SPEED_BOOST, 300, accessManager, assetManager);
    } else {
      powerUp = new PowerUp(PowerUp.SPEED_BOOST, 300, accessManager);
    }
    
    // Posicionar en la parte inferior de la pantalla (centro)
    powerUp.setPosition(width/2, height - 70); // Posición en la parte inferior central
    activePowerUps.add(powerUp);
    
    // Show floating text
    addFloatingText("¡Velocidad Aumentada!", player.x, player.y - 30, color(255, 100, 100));
  }
  
  void activateDoublePoints(Player player) {
    // Apply double points power-up to player
    player.activateDoublePoints(300); // 5 seconds
    
    PowerUp powerUp;
    if (assetManager != null) {
      powerUp = new PowerUp(PowerUp.DOUBLE_POINTS, 300, accessManager, assetManager);
    } else {
      powerUp = new PowerUp(PowerUp.DOUBLE_POINTS, 300, accessManager);
    }
    
    // Posicionar en la parte inferior de la pantalla (lado derecho)
    powerUp.setPosition(3*width/4, height - 70); // Posición en la parte inferior derecha
    activePowerUps.add(powerUp);
    
    // Show floating text
    addFloatingText("¡Puntos Dobles!", player.x, player.y - 30, color(255, 200, 50));
  }
  
  void addPoints(int points, float x, float y) {
    // Create floating text for points
    addFloatingText("+" + points, x, y - 20, color(255, 255, 50));
  }
  
  void addFloatingText(String text, float x, float y, color textColor) {
    FloatingText floatingText = new FloatingText(text, x, y, textColor, accessManager);
    floatingTexts.add(floatingText);
  }
  
  ArrayList<Collectible> getCollectibles() {
    return collectibles;
  }
  
  ArrayList<PowerUp> getActivePowerUps() {
    return activePowerUps;
  }
  
  ArrayList<FloatingText> getFloatingTexts() {
    return floatingTexts;
  }
  
  void reset() {
    collectibles.clear();
    activePowerUps.clear();
    floatingTexts.clear();
    collectibleTimer = 0;
  }
  
  // Método para limpiar todos los coleccionables y power-ups
  void clearAll() {
    reset();
  }
  
  int getWeightedCollectibleType() {
    // Ajusta las probabilidades basándose en varios factores
    
    // Probabilidad para coleccionables ambientales según el nivel de contaminación
    float envFactor = ecoSystem.getPollutionLevel();
    float ecoProb = 0.3 + envFactor * 0.2; // Aumenta si hay más contaminación
    
    // Menos probabilidad de power-ups consecutivos
    if (consecutivePowerUps >= 2) {
      ecoProb *= 0.5;
    }
    
    // Decidir si crear un coleccionable ambiental
    if (random(1) < ecoProb) {
      consecutivePowerUps = 0; // Reiniciar contador
      
      // Si hay mucha contaminación, mayor chance de objetos de limpieza
      if (envFactor > 0.6 && random(1) < 0.7) {
        return Collectible.ECO_CLEANUP;
      } else {
        return Collectible.ECO_POSITIVE;
      }
    }
    
    // Distribución balanceada para el resto de coleccionables
    float rand = random(1);
    
    // Si ya tuvimos muchas monedas seguidas, reducir probabilidad
    float coinProb = (consecutiveCoins > 5) ? 0.4 : 0.65;
    
    if (rand < coinProb) {
      consecutiveCoins++;
      consecutivePowerUps = 0;
      return Collectible.COIN;
    } else if (rand < 0.75) {
      consecutiveCoins = 0;
      consecutivePowerUps = 0;
      return Collectible.GEM;
    } else {
      // Es un power-up, aumentar contador
      consecutiveCoins = 0;
      consecutivePowerUps++;
      
      // Seleccionar el tipo de power-up
      float powerRand = random(1);
      if (powerRand < 0.35) {
        return Collectible.SHIELD;
      } else if (powerRand < 0.70) {
        return Collectible.SPEED_BOOST;
      } else if (powerRand < 0.95) {
        return Collectible.DOUBLE_POINTS;
      } else {
        return Collectible.HEART;
      }
    }
  }
} 