/**
 * ObstacleTypes.pde
 * 
 * Contiene tipos de obstáculos especializados que heredan de la clase base Obstacle.
 */

// Obstáculo alto (requiere saltar)
class TallObstacle extends Obstacle {
  TallObstacle(float x, float y) {
    super(x, y, 30, 120, 5.0, 2, new AccessibilityManager());
  }
  
  TallObstacle(float x, float y, AccessibilityManager accessManager) {
    super(x, y, 30, 120, 5.0, 2, accessManager);
  }
  
  TallObstacle(float x, float y, AccessibilityManager accessManager, AssetManager assetManager) {
    super(x, y, 30, 120, 5.0, 2, accessManager, assetManager);
  }
}

// Obstáculo bajo (requiere deslizarse) - usando basura.png
class LowObstacle extends Obstacle {
  LowObstacle(float x, float y) {
    super(x, y, 60, 50, 5.0, 1, new AccessibilityManager());
  }
  
  LowObstacle(float x, float y, AccessibilityManager accessManager) {
    super(x, y, 60, 50, 5.0, 1, accessManager);
  }
  
  LowObstacle(float x, float y, AccessibilityManager accessManager, AssetManager assetManager) {
    super(x, y, 60, 50, 5.0, 1, accessManager, assetManager);
  }
}

// Obstáculo móvil (oscila arriba y abajo) - Esta clase ya no se utiliza en el juego
// Se mantiene por compatibilidad con el código existente
// Los obstáculos circulares que se mueven verticalmente han sido eliminados
class MovingObstacle extends Obstacle {
  MovingObstacle(float x, float y) {
    super(x, y, 50, 50, 5.0, 3, new AccessibilityManager());
  }
  
  MovingObstacle(float x, float y, AccessibilityManager accessManager) {
    super(x, y, 50, 50, 5.0, 3, accessManager);
  }
  
  MovingObstacle(float x, float y, AccessibilityManager accessManager, AssetManager assetManager) {
    super(x, y, 50, 50, 5.0, 3, accessManager, assetManager);
  }
}

// Obstáculo de nube tóxica (usando nube.png)
class ToxicCloudObstacle extends Obstacle {
  ToxicCloudObstacle(float x, float y) {
    super(x, y, 70, 60, 5.0, 4, new AccessibilityManager());
    // Configurar como tóxico por defecto
    setToxicAppearance(true);
    // Aumentar el multiplicador de daño
    setDamageMultiplier(1.3);
  }
  
  ToxicCloudObstacle(float x, float y, AccessibilityManager accessManager) {
    super(x, y, 70, 60, 5.0, 4, accessManager);
    // Configurar como tóxico por defecto
    setToxicAppearance(true);
    // Aumentar el multiplicador de daño
    setDamageMultiplier(1.3);
  }
  
  ToxicCloudObstacle(float x, float y, AccessibilityManager accessManager, AssetManager assetManager) {
    super(x, y, 70, 60, 5.0, 4, accessManager, assetManager);
    // Configurar como tóxico por defecto
    setToxicAppearance(true);
    // Aumentar el multiplicador de daño
    setDamageMultiplier(1.3);
  }
} 