// EcoRunner - juego endless runner sobre cambio climático
// Versión 1.3

// Gestor principal del juego
GameManager gameManager;

void setup() {
  size(1920, 1080, P2D);

//  fullScreen();
  
  try {
    // Inicializar el gestor del juego
    gameManager = new GameManager();
  } catch (Exception e) {
    println("ERROR en setup: " + e.getMessage());
    e.printStackTrace();
  }
}

void draw() {
  try {
    // Actualizar estado del juego
    gameManager.update();
    
    // Renderizar el juego
    gameManager.render();
  } catch (Exception e) {
      println("ERROR en draw(): " + e.getMessage());
      e.printStackTrace();
  }
}

void keyPressed() {
  gameManager.handleKeyPressed();
}

void keyReleased() {
  gameManager.handleKeyReleased();
}

void mousePressed() {
  gameManager.handleMousePressed();
    }
    
void mouseWheel(MouseEvent event) {
  gameManager.handleMouseWheel(event);
    }

void exit() {
  // Realizar operaciones de limpieza antes de salir
  gameManager.cleanup();
  super.exit();
}
