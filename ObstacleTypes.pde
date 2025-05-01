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
}

// Obstáculo bajo (requiere deslizarse)
class LowObstacle extends Obstacle {
  LowObstacle(float x, float y) {
    super(x, y, 70, 40, 5.0, 1, new AccessibilityManager());
  }
  
  LowObstacle(float x, float y, AccessibilityManager accessManager) {
    super(x, y, 70, 40, 5.0, 1, accessManager);
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
} 