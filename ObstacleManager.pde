/**
 * ObstacleManager.pde
 * 
 * Gestiona la creación, actualización y eliminación de obstáculos en el juego.
 * Maneja patrones de generación de obstáculos y escalado de dificultad.
 */

class ObstacleManager {
  ArrayList<Obstacle> obstacles;
  float groundLevel;
  
  // Generación de obstáculos
  float obstacleTimer = 0;
  float obstacleInterval = 90; // Frames entre obstáculos
  float baseObstacleSpeed = 5;
  float obstacleSpeed;
  
  // Generación de patrones
  boolean inPattern = false;
  int patternStep = 0;
  int currentPattern = 0;
  int patternsCompleted = 0;
  int[][] patterns = {
    {0, 0, 1}, // Patrón básico
    {1, 2, 1}, // Salto, deslizar, salto
    {2, 2, 0, 2}, // Deslizar, deslizar, básico, deslizar
    {0, 4, 0}, // Patrón con nube tóxica (reemplazando tipo 3)
    {1, 0, 4, 1}, // Complejo con nube tóxica (reemplazando tipo 3)
    {0, 1, 4, 1, 0} // Experto con nube tóxica (reemplazando tipo 3)
  };
  
  // Integración con ecosistema
  EcoSystem ecoSystem;
  
  // Referencia de accesibilidad
  AccessibilityManager accessManager;
  
  // Referencia al gestor de assets
  AssetManager assetManager;
  
  ObstacleManager(float groundLevel, float obstacleSpeed, EcoSystem ecoSystem) {
    this.groundLevel = groundLevel;
    this.obstacleSpeed = obstacleSpeed;
    this.ecoSystem = ecoSystem;
    this.accessManager = ecoSystem.accessManager; // Obtener gestor de accesibilidad del ecosistema
    obstacles = new ArrayList<Obstacle>();
  }
  
  // Constructor con AssetManager
  ObstacleManager(float groundLevel, float obstacleSpeed, EcoSystem ecoSystem, AssetManager assetManager) {
    this(groundLevel, obstacleSpeed, ecoSystem);
    this.assetManager = assetManager;
  }
  
  void update() {
    updateObstacles();
    generateObstacles();
  }
  
  void updateObstacles() {
    // Actualizar y eliminar obstáculos que están fuera de la pantalla
    for (int i = obstacles.size() - 1; i >= 0; i--) {
      Obstacle obstacle = obstacles.get(i);
      obstacle.update();
      
      if (obstacle.isOffscreen()) {
        obstacles.remove(i);
      }
    }
  }
  
  void generateObstacles() {
    obstacleTimer++;
    
    if (obstacleTimer >= obstacleInterval) {
      obstacleTimer = 0;
      
      if (inPattern) {
        createPatternObstacle();
      } else {
        // 35% de probabilidad de iniciar una secuencia de patrones, de lo contrario genera un obstáculo aleatorio
        if (random(1) < 0.35) {
          startNewPattern();
        } else {
          createRandomObstacle();
        }
      }
    }
  }
  
  void startNewPattern() {
    inPattern = true;
    patternStep = 0;
    
    // Seleccionar un patrón basado en la dificultad
    int maxPatternIndex = min(patterns.length - 1, patternsCompleted / 2);
    currentPattern = int(random(maxPatternIndex + 1));
    
    createPatternObstacle();
  }
  
  void createPatternObstacle() {
    if (patternStep < patterns[currentPattern].length) {
      int obstacleType = patterns[currentPattern][patternStep];
      createObstacleByType(obstacleType);
      patternStep++;
    } else {
      // Patrón completado
      inPattern = false;
      patternsCompleted++;
    }
  }
  
  void createRandomObstacle() {
    // Ahora incluimos tipo 4 (nube tóxica) en las opciones
    // y eliminamos completamente el tipo 3 (móvil) que ya no se usa
    int[] availableTypes = {0, 1, 2, 4}; // Básico, Alto, Bajo, Nube tóxica
    int randomIndex = int(random(availableTypes.length));
    int obstacleType = availableTypes[randomIndex];
    createObstacleByType(obstacleType);
  }
  
  void createObstacleByType(int type) {
    // Parámetros base del obstáculo
    float obstacleX = width + 50;
    Obstacle obstacle;
    
    // Crear obstáculo según el tipo
    switch (type) {
      case 1: // Obstáculo alto (saltar)
        if (assetManager != null) {
          obstacle = new TallObstacle(obstacleX, groundLevel, accessManager, assetManager);
        } else {
          obstacle = new TallObstacle(obstacleX, groundLevel, accessManager);
        }
        break;
      case 2: // Obstáculo bajo (deslizar)
        if (assetManager != null) {
          obstacle = new LowObstacle(obstacleX, groundLevel, accessManager, assetManager);
        } else {
          obstacle = new LowObstacle(obstacleX, groundLevel, accessManager);
        }
        break;
      case 3: // Este caso ya no se usa, pero lo dejamos por compatibilidad
        // Si por alguna razón llega un tipo 3, creamos un obstáculo básico en su lugar
        // Comentario explicativo en español
        if (assetManager != null) {
          obstacle = new Obstacle(obstacleX, groundLevel, 60, 120, obstacleSpeed, 0, accessManager, assetManager);
        } else {
          obstacle = new Obstacle(obstacleX, groundLevel, 60, 120, obstacleSpeed, 0, accessManager);
        }
        break;
      case 4: // Obstáculo de nube tóxica
        if (assetManager != null) {
          obstacle = new ToxicCloudObstacle(obstacleX, groundLevel, accessManager, assetManager);
        } else {
          obstacle = new ToxicCloudObstacle(obstacleX, groundLevel, accessManager);
        }
        break;
      default: // Obstáculo básico
        if (assetManager != null) {
          // Aumentamos el tamaño del obstáculo básico para mantener la proporción
          obstacle = new Obstacle(obstacleX, groundLevel, 60, 120, obstacleSpeed, 0, accessManager, assetManager);
        } else {
          obstacle = new Obstacle(obstacleX, groundLevel, 60, 120, obstacleSpeed, 0, accessManager);
        }
    }
    
    // Aplicar efectos ambientales
    applyEnvironmentalEffects(obstacle);
    
    // Añadir a la lista
    obstacles.add(obstacle);
  }
  
  void applyEnvironmentalEffects(Obstacle obstacle) {
    // Modificar apariencia y comportamiento del obstáculo según el estado del ecosistema
    float pollutionLevel = ecoSystem.getPollutionLevel();
    
    // Cambios visuales
    if (pollutionLevel > 0.7) {
      obstacle.setToxicAppearance(true);
      obstacle.setDamageMultiplier(1.5);
    } else if (pollutionLevel > 0.4) {
      obstacle.setToxicAppearance(true);
      obstacle.setDamageMultiplier(1.2);
    }
  }
  
  void setObstacleSpeed(float speed) {
    this.obstacleSpeed = speed;
  }
  
  ArrayList<Obstacle> getObstacles() {
    return obstacles;
  }
  
  void reset() {
    obstacles.clear();
    obstacleTimer = 0;
    obstacleSpeed = baseObstacleSpeed;
    inPattern = false;
    patternStep = 0;
    currentPattern = 0;
    patternsCompleted = 0;
  }
  
  // Alias para limpiar todos los obstáculos
  void clearAll() {
    reset();
  }
} 