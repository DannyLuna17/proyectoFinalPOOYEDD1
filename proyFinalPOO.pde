// EcoRunner - juego endless runner sobre cambio climático
// Versión 1.3
// La gloria es de Dios, a los santos nadie los toca.
// Dev: github.com/DannyLuna17

// Importación para GIFs animados
import gifAnimation.*;

// Variable global para almacenar la referencia a PApplet
public static PApplet applet;

// Gestor principal del juego
GameManager gameManager;

void setup() {
  // Guardar referencia a this (PApplet)
  applet = this;
  
  fullScreen(P2D);

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

void mouseDragged() {
  gameManager.handleMouseDragged();
}

void mouseReleased() {
  gameManager.handleMouseReleased();
}
    
void mouseWheel(MouseEvent event) {
  gameManager.handleMouseWheel(event);
}

void exit() {
  // Realizar operaciones de limpieza antes de salir
  gameManager.cleanup();
  super.exit();
}
