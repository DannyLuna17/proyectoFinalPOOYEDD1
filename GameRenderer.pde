/**
 * GameRenderer.pde
 * 
 * Responsable de renderizar los diferentes estados del juego, manejar transiciones,
 * y proporcionar una interfaz de usuario consistente en toda la aplicación.
 */

class GameRenderer {
  // Referencias a componentes principales
  Game game;
  Menu menu;
  VideoIntroMenu videoIntroMenu;
  AccessibilityManager accessManager;
  
  // Estado de la interfaz
  int selectedMenuItem;
  int gameState; // Referencia local al estado actual del juego
  GameStateManager stateManager; // Referencia al gestor de estado global
  
  GameRenderer(Game game, Menu menu, VideoIntroMenu videoIntroMenu, 
              AccessibilityManager accessManager) {
    this.game = game;
    this.menu = menu;
    this.videoIntroMenu = videoIntroMenu;
    this.accessManager = accessManager;
    
    // Inicializar referencia al gestor de estado
    if (game != null) {
      this.stateManager = game.gameStateManager;
    }
  }
  
  void setSelectedMenuItem(int selectedMenuItem) {
    this.selectedMenuItem = selectedMenuItem;
  }
  
  void setGameState(int gameState) {
    this.gameState = gameState;
    // Actualizar el gestor de estado si está disponible
    if (stateManager != null) {
      stateManager.setState(gameState);
    }
  }
  
  int getGameState() {
    // Obtener el estado del gestor si está disponible, de lo contrario usar copia local
    return stateManager != null ? stateManager.getState() : gameState;
  }
  
  void render() {
    renderCurrentGameState();
    displayAccessibilityHelpers();
  }
  
  void renderCurrentGameState() {
    int currentState = getGameState();
    switch(currentState) {
      case STATE_INTRO_VIDEO:
        renderIntroVideo();
        break;
      case STATE_MAIN_MENU:
        renderMainMenu();
        break;
      case STATE_INSTRUCTIONS:
        menu.displayInstructions();
        break;
      case STATE_SETTINGS:
        menu.displaySettings();
        break;
      case STATE_GAME:
        renderGameplay();
        break;
      case STATE_GAME_OVER:
        renderGameOver();
        break;
      case STATE_PAUSED:
        renderPausedGame();
        break;
    }
  }
  
  void renderIntroVideo() {
    videoIntroMenu.display();
  }
  
  void renderMainMenu() {
    // Animación de botones
    if (!videoIntroMenu.buttonsRevealed) {
      videoIntroMenu.display();
    } else {
      menu.displayMainMenu();
    }
  }
  
  void renderGameplay() {
    game.update();
    game.display();
  }
  
  void renderGameOver() {
    game.display();
    menu.displayGameOverOptions();
  }
  
  void renderPausedGame() {
    game.display();
    menu.displayPauseMenu();
  }
  
  void displayAccessibilityHelpers() {
    int currentState = getGameState();
    if (accessManager.keyboardOnly && (currentState != STATE_GAME)) {
      displayKeyboardNavHelper();
    }
  }
  
  void displayKeyboardNavHelper() {
    pushStyle();
    fill(0, 0, 0, 150);
    rectMode(CORNER);
    rect(0, height - 30, width, 30);
    
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(accessManager.getAdjustedTextSize(12));
    
    int currentState = getGameState();
    if (currentState == STATE_MAIN_MENU) {
      // Controles de navegación horizontal para el menú principal
      text("←→ o A/D: Navegar | ENTER o ESPACIO: Seleccionar | ESC: Atrás", width/2, height - 15);
    } else {
      // Controles de navegación vertical para otros menús
      text("↑↓ o W/S: Navegar | ENTER o ESPACIO: Seleccionar | ESC: Atrás", width/2, height - 15);
    }
    
    popStyle();
  }
} 