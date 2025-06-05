/**
 * ObstacleTypes.pde
 * 
 * Contiene tipos de obstáculos especializados que heredan de la clase base Obstacle.
 */

// Obstáculo alto (requiere saltar)
class TallObstacle extends Obstacle {
  // Aumentar ancho de obstáculo alto
  TallObstacle(float x, float y) {
    super(x, y, 140, 180, 5.0, 2, new AccessibilityManager());
  }
  
  TallObstacle(float x, float y, AccessibilityManager accessManager) {
    super(x, y, 140, 180, 5.0, 2, accessManager);
  }
  
  TallObstacle(float x, float y, AccessibilityManager accessManager, AssetManager assetManager) {
    super(x, y, 140, 180, 5.0, 2, accessManager, assetManager);
  }
}

// Obstáculo bajo (requiere deslizarse) - usando basura.png
class LowObstacle extends Obstacle {
  LowObstacle(float x, float y) {
    super(x, y, 90, 75, 5.0, 1, new AccessibilityManager());
  }
  
  LowObstacle(float x, float y, AccessibilityManager accessManager) {
    super(x, y, 90, 75, 5.0, 1, accessManager);
  }
  
  LowObstacle(float x, float y, AccessibilityManager accessManager, AssetManager assetManager) {
    super(x, y, 90, 75, 5.0, 1, accessManager, assetManager);
  }
}

// Obstáculo móvil (oscila arriba y abajo) - Esta clase ya no se utiliza en el juego
// Se mantiene por compatibilidad con el código existente
// Los obstáculos circulares que se mueven verticalmente han sido eliminados
class MovingObstacle extends Obstacle {
  MovingObstacle(float x, float y) {
    super(x, y, 75, 75, 5.0, 3, new AccessibilityManager());
  }
  
  MovingObstacle(float x, float y, AccessibilityManager accessManager) {
    super(x, y, 75, 75, 5.0, 3, accessManager);
  }
  
  MovingObstacle(float x, float y, AccessibilityManager accessManager, AssetManager assetManager) {
    super(x, y, 75, 75, 5.0, 3, accessManager, assetManager);
  }
}

// Obstáculo de nube tóxica (usando nube.png)
class ToxicCloudObstacle extends Obstacle {
  // Propiedades para seguir al jugador
  float verticalOffset = 0; 
  float horizontalSpeed = 0.8; // Velocidad de movimiento horizontal hacia el jugador
  float verticalSpeed = 0.2; // Velocidad de movimiento vertical
  Player targetPlayer = null; // Referencia al jugador
  
  // Constructor básico
  ToxicCloudObstacle(float x, float y) {
    super(x, y - 20, 105, 90, 5.0, 4, new AccessibilityManager());
    // Configurar como tóxico por defecto
    setToxicAppearance(true);
    // Aumentar el multiplicador de daño
    setDamageMultiplier(1.3);
  }
  
  // Constructor con gestor de accesibilidad
  ToxicCloudObstacle(float x, float y, AccessibilityManager accessManager) {
    super(x, y - 20, 105, 90, 5.0, 4, accessManager);
    // Configurar como tóxico por defecto
    setToxicAppearance(true);
    // Aumentar el multiplicador de daño
    setDamageMultiplier(1.3);
  }
  
  // Constructor con gestores de accesibilidad y assets
  ToxicCloudObstacle(float x, float y, AccessibilityManager accessManager, AssetManager assetManager) {
    super(x, y - 20, 105, 90, 5.0, 4, accessManager, assetManager);
    // Configurar como tóxico por defecto
    setToxicAppearance(true);
    // Aumentar el multiplicador de daño
    setDamageMultiplier(1.3);
  }
  
  // Método para establecer el jugador objetivo
  void setTargetPlayer(Player player) {
    this.targetPlayer = player;
  }
  
  // Sobrescribir el método update para seguir al jugador
  @Override
  void update() {
    // Primero, movimiento normal de derecha a izquierda
    x -= speed;
    
    // Si tenemos un jugador objetivo, mover la nube hacia él
    if (targetPlayer != null) {
      /* 
       * La nube ahora persigue al jugador! Calculamos la dirección hacia él
       * y nos movemos suavemente para crear un efecto más realista.
       * Esta mecánica hace que el juego sea más desafiante ya que no es tan
       * fácil esquivar la nube tóxica.
       */
      float directionX = targetPlayer.x - x;
      
      // Movimiento suave hacia el jugador
      if (abs(directionX) > 10) { // Evitar vibraciones cuando está cerca
        x += horizontalSpeed * (directionX > 0 ? 1 : -1);
      }
      
      // Movimiento de flotación vertical - la nube se mueve arriba y abajo suavemente
      // Usamos una función seno para crear un efecto de flotación natural
      y = initialY - verticalOffset + sin(millis() * 0.001) * 15;
    }
    
    // Continuar con la actualización normal
    if (hasWarning) {
      // Efecto de parpadeo
      warningAlpha = 127 + 127 * sin(millis() * 0.01);
    }
    
    // Actualizar timer de pista visual
    if (showHint && hintTimer < hintDuration) {
      hintTimer++;
      
      // Desvanecer al final
      if (hintTimer > hintDuration * 0.7) {
        hintOpacity = map(hintTimer, hintDuration * 0.7, hintDuration, 255, 0);
      }
    }
  }
} 