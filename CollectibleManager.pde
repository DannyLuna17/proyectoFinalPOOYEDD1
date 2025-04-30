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
  float collectibleInterval = 120; // Frames entre intentos
  float collectibleChance = 0.7;   // 70% de probabilidad
  float ecoCollectibleChance = 0.3; // 30% para ambientales
  
  // Integración con ecosistema
  EcoSystem ecoSystem;
  
  // Soporte de accesibilidad
  AccessibilityManager accessManager;
  
  CollectibleManager(float groundLevel, EcoSystem ecoSystem) {
    this.groundLevel = groundLevel;
    this.ecoSystem = ecoSystem;
    
    collectibles = new ArrayList<Collectible>();
    activePowerUps = new ArrayList<PowerUp>();
    floatingTexts = new ArrayList<FloatingText>();
    
    // Gestor de accesibilidad por defecto
    this.accessManager = new AccessibilityManager();
  }
  
  // Constructor con gestor de accesibilidad
  CollectibleManager(float groundLevel, EcoSystem ecoSystem, AccessibilityManager accessManager) {
    this(groundLevel, ecoSystem);
    this.accessManager = accessManager;
  }
  
  void update(float obstacleSpeed, ArrayList<Platform> platforms) {
    updateCollectibles(obstacleSpeed);
    updatePowerUps();
    updateFloatingTexts();
    generateCollectibles(platforms);
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
      
      if (random(1) < collectibleChance) {
        boolean onPlatform = random(1) < 0.6 && platforms.size() > 0;
        
        if (onPlatform) {
          createPlatformCollectible(platforms);
        } else {
          createAirCollectible();
        }
      }
    }
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
        
        Collectible collectible = new Collectible(x, y, collectibleType);
        collectible.setPlatformBound(true, platform);
        collectibles.add(collectible);
      }
    }
  }
  
  void createAirCollectible() {
    int collectibleType = determineCollectibleType(false);
    float x = width + 50;
    float y = random(groundLevel - 200, groundLevel - 50);
    
    Collectible collectible = new Collectible(x, y, collectibleType);
    collectibles.add(collectible);
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
      
      if (rand < 0.6) {
        return Collectible.COIN;
      } else if (rand < 0.75) {
        return Collectible.GEM;
      } else if (rand < 0.85) {
        return Collectible.SHIELD;
      } else if (rand < 0.95) {
        return Collectible.SPEED_BOOST;
      } else {
        return Collectible.DOUBLE_POINTS;
      }
    }
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
    // Apply shield power-up to player
    player.activateShield(300); // 5 seconds
    PowerUp powerUp = new PowerUp(PowerUp.SHIELD, 300, accessManager);
    powerUp.setPosition(width - 40, 60); // Position in top-right corner of HUD
    activePowerUps.add(powerUp);
    
    // Show floating text
    addFloatingText("¡Escudo Activo!", player.x, player.y - 30, color(100, 255, 100));
  }
  
  void activateSpeedBoost(Player player) {
    // Apply speed boost power-up to player
    player.activateSpeedBoost(300, 1.5); // 5 seconds, 50% boost
    PowerUp powerUp = new PowerUp(PowerUp.SPEED_BOOST, 300, accessManager);
    powerUp.setPosition(width - 40, 100); // Position below shield in HUD
    activePowerUps.add(powerUp);
    
    // Show floating text
    addFloatingText("¡Velocidad Aumentada!", player.x, player.y - 30, color(255, 100, 100));
  }
  
  void activateDoublePoints(Player player) {
    // Apply double points power-up to player
    player.activateDoublePoints(300); // 5 seconds
    PowerUp powerUp = new PowerUp(PowerUp.DOUBLE_POINTS, 300, accessManager);
    powerUp.setPosition(width - 40, 140); // Position below speed boost in HUD
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
} 