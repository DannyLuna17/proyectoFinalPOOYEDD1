/**
 * PlatformManager.pde
 * 
 * Gestiona la creación, actualización y eliminación de plataformas en el juego.
 * Maneja patrones de generación de plataformas y escalado de dificultad.
 */

class PlatformManager {
  ArrayList<Platform> platforms;
  float groundLevel;
  
  // Generación de plataformas
  float platformTimer = 0;
  float platformInterval = 120; // Frames entre plataformas
  float platformChance = 0.7;   // 70% de probabilidad
  int maxPlatforms = 8;         // Máximo de plataformas en pantalla
  
  // Escalado de dificultad
  float obstacleSpeed;
  
  // Referencia de accesibilidad
  AccessibilityManager accessManager;
  
  // Referencia al gestor de obstáculos para evitar solapamientos
  ObstacleManager obstacleManager;
  
  PlatformManager(float groundLevel, float obstacleSpeed) {
    this.groundLevel = groundLevel;
    this.obstacleSpeed = obstacleSpeed;
    this.accessManager = new AccessibilityManager();
    platforms = new ArrayList<Platform>();
  }
  
  // Constructor con gestor de accesibilidad
  PlatformManager(float groundLevel, float obstacleSpeed, AccessibilityManager accessManager) {
    this.groundLevel = groundLevel;
    this.obstacleSpeed = obstacleSpeed;
    this.accessManager = accessManager;
    platforms = new ArrayList<Platform>();
  }
  
  // Establecer referencia al gestor de obstáculos
  void setObstacleManager(ObstacleManager obstacleManager) {
    this.obstacleManager = obstacleManager;
  }
  
  void update() {
    updatePlatforms();
    generatePlatforms();
  }
  
  void updatePlatforms() {
    // Actualizar y eliminar plataformas que están fuera de la pantalla
    for (int i = platforms.size() - 1; i >= 0; i--) {
      Platform platform = platforms.get(i);
      platform.update(obstacleSpeed);
      
      if (!platform.isOnScreen()) {
        platforms.remove(i);
      }
    }
  }
  
  void generatePlatforms() {
    platformTimer++;
    
    if (platformTimer >= platformInterval && platforms.size() < maxPlatforms) {
      platformTimer = 0;
      
      if (random(1) < platformChance) {
        createRandomPlatform();
      }
    }
  }
  
  void createRandomPlatform() {
    // Número máximo de intentos para encontrar una posición válida
    int maxAttempts = 5;
    int attempts = 0;
    boolean validPosition = false;
    Platform platform = null;
    
    // Intentamos varias veces hasta encontrar una posición sin solapamientos
    // o hasta agotar los intentos máximos
    while (!validPosition && attempts < maxAttempts) {
      // Parámetros básicos de la plataforma
      float platformX = width + 50;
      // Variar la altura para evitar colisiones
      float platformY = random(groundLevel - 200, groundLevel - 100);
      float platformWidth = random(160, 280); // Plataformas más anchas
      int platformType = int(random(4)); // 0: Normal, 1: Rebote, 2: Móvil, 3: Desapareciendo
      
      switch (platformType) {
        case 1: // Plataforma de rebote
          platform = new BouncePlatform(platformX, platformY, platformWidth, accessManager);
          break;
        case 2: // Plataforma móvil
          platform = new MovingPlatform(platformX, platformY, platformWidth, accessManager);
          break;
        case 3: // Plataforma que desaparece
          platform = new DisappearingPlatform(platformX, platformY, platformWidth, accessManager);
          break;
        default: // Plataforma normal
          platform = new Platform(platformX, platformY, platformWidth, accessManager);
      }
      
      // Verificar si hay solapamiento con plataformas existentes
      boolean overlapsWithPlatform = false;
      for (Platform existingPlatform : platforms) {
        if (platform.overlapsWith(existingPlatform)) {
          overlapsWithPlatform = true;
          break;
        }
      }
      
      // Verificar si hay solapamiento con obstáculos
      boolean overlapsWithObstacle = false;
      if (obstacleManager != null) {
        overlapsWithObstacle = overlapsWithObstacle(platform, obstacleManager.getObstacles());
      }
      
      // Si no hay solapamientos, tenemos una posición válida
      if (!overlapsWithPlatform && !overlapsWithObstacle) {
        validPosition = true;
      } else {
        // Intentar de nuevo con una nueva posición
        attempts++;
      }
    }
    
    // Añadir solo si encontramos una posición válida
    if (validPosition && platform != null) {
      platforms.add(platform);
    }
  }
  
  // Verificar si una plataforma se solapa con algún obstáculo
  boolean overlapsWithObstacle(Platform platform, ArrayList<Obstacle> obstacles) {
    // Márgenes de seguridad para evitar colocaciones demasiado cercanas
    float xSafetyMargin = 30; // Margen horizontal adicional
    float ySafetyMargin = 40; // Margen vertical adicional
    
    for (Obstacle obstacle : obstacles) {
      // Verificar superposición horizontal con margen de seguridad
      boolean xOverlap = (platform.x + platform.width + xSafetyMargin > obstacle.x - obstacle.w/2) && 
                         (platform.x - xSafetyMargin < obstacle.x + obstacle.w/2);
      
      // Verificar superposición vertical con margen de seguridad
      boolean yOverlap = (platform.y + platform.height + ySafetyMargin > obstacle.y - obstacle.h) && 
                         (platform.y - ySafetyMargin < obstacle.y);
      
      if (xOverlap && yOverlap) {
        return true; // Hay solapamiento con este obstáculo
      }
    }
    return false; // No hay solapamiento con ningún obstáculo
  }
  
  void setObstacleSpeed(float speed) {
    this.obstacleSpeed = speed;
  }
  
  ArrayList<Platform> getPlatforms() {
    return platforms;
  }
  
  void reset() {
    platforms.clear();
    platformTimer = 0;
  }
  
  // Método para limpiar todas las plataformas
  void clearAllPlatforms() {
    reset();
  }
} 