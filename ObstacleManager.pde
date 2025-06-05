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
  float obstacleInterval = 140; // Frames entre obstáculos (aumentado para mayor separación)
  float baseObstacleSpeed = 5;
  float obstacleSpeed;
  
  // Espaciado de obstáculos
  float minObstacleSpacing = 250; // Espacio mínimo entre obstáculos
  int maxObstaclesOnScreen = 5;   // Máximo de obstáculos en pantalla a la vez
  float lastObstacleX = 0;        // Posición del último obstáculo creado
  
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
  
  // Control de dificultad
  int scoreBasedDifficultyLevel = 1;
  
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
    
    // Verificar si hay demasiados obstáculos en pantalla o si no hay suficiente espacio
    if (obstacles.size() >= maxObstaclesOnScreen) {
      return; // No generar más obstáculos si ya hay demasiados
    }
    
    if (obstacleTimer >= obstacleInterval) {
      // Verificar el espacio disponible para el próximo obstáculo
      if (hasEnoughSpaceForNewObstacle()) {
        obstacleTimer = 0;
        
        if (inPattern) {
          createPatternObstacle();
        } else {
          // Ajustar probabilidad de patrón según nivel de dificultad
          // Menos patrones a mayor dificultad para dar más espacio entre obstáculos
          float patternProbability = map(scoreBasedDifficultyLevel, 1, 15, 0.35, 0.25);
          if (random(1) < patternProbability) {
            startNewPattern();
          } else {
            createRandomObstacle();
          }
        }
      }
    }
  }
  
  // Verificar si hay suficiente espacio para un nuevo obstáculo
  boolean hasEnoughSpaceForNewObstacle() {
    float requiredSpace = minObstacleSpacing; 
    
    // Si no hay obstáculos, siempre hay espacio
    if (obstacles.size() == 0) {
      return true;
    }
    
    // Verificar si el último obstáculo está lo suficientemente lejos
    Obstacle lastObstacle = obstacles.get(obstacles.size() - 1);
    return (lastObstacle.x < width || (width + requiredSpace) < lastObstacle.x);
  }
  
  void startNewPattern() {
    inPattern = true;
    patternStep = 0;
    
    // Limitar la complejidad de los patrones basado en la dificultad actual
    // para que no haya patrones muy largos en niveles avanzados
    int maxPatternsBasedOnDifficulty = min(patterns.length - 1, scoreBasedDifficultyLevel / 2);
    
    // Limitar aún más cuando la dificultad es muy alta para dar más espacio
    if (scoreBasedDifficultyLevel > 10) {
      maxPatternsBasedOnDifficulty = min(maxPatternsBasedOnDifficulty, 2);
    }
    
    // Seleccionar un patrón basado en la dificultad
    int maxPatternIndex = min(maxPatternsBasedOnDifficulty, patternsCompleted / 2);
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
    // Incluir tipos con diferentes probabilidades según dificultad
    ArrayList<Integer> availableTypes = new ArrayList<Integer>();
    
    // Siempre incluir tipos básicos
    availableTypes.add(0); // Básico
    availableTypes.add(1); // Alto
    availableTypes.add(2); // Bajo
    
    availableTypes.add(4); // Nube tóxica
    
    // Seleccionar tipo aleatorio
    int randomIndex = int(random(availableTypes.size()));
    int obstacleType = availableTypes.get(randomIndex);
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
    
    // Registrar la posición de este obstáculo
    lastObstacleX = obstacleX;
    
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
  
  // Actualizar nivel de dificultad basado en puntuación (llamado desde Game)
  void setScoreBasedDifficultyLevel(int level) {
    this.scoreBasedDifficultyLevel = level;
    
    // Ajustar el espaciado mínimo y máximo de obstáculos según dificultad
    // A mayor dificultad, mayor espacio mínimo entre obstáculos
    minObstacleSpacing = 250 + (level * 10);
    
    // Ajustar el número máximo de obstáculos en pantalla
    // A mayor dificultad, menos obstáculos para evitar saturación
    maxObstaclesOnScreen = 5;
    if (level > 8) {
      maxObstaclesOnScreen = 4;
    }
    if (level > 12) {
      maxObstaclesOnScreen = 3;
    }
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
    scoreBasedDifficultyLevel = 1;
  }
  
  // Alias para limpiar todos los obstáculos
  void clearAll() {
    reset();
  }
} 