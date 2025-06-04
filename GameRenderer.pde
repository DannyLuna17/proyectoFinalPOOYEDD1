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
  Leaderboard leaderboard;
  PlayerNameInput playerNameInput;
  XPSummaryScreen xpSummaryScreen; // Pantalla de resumen de XP
  LoadingScreen loadingScreen; 
  
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
  
  // Constructor actualizado con leaderboard y playerNameInput
  GameRenderer(Game game, Menu menu, VideoIntroMenu videoIntroMenu, 
              AccessibilityManager accessManager, Leaderboard leaderboard,
              PlayerNameInput playerNameInput, XPSummaryScreen xpSummaryScreen) {
    this.game = game;
    this.menu = menu;
    this.videoIntroMenu = videoIntroMenu;
    this.accessManager = accessManager;
    this.leaderboard = leaderboard;
    this.playerNameInput = playerNameInput;
    this.xpSummaryScreen = xpSummaryScreen;
    
    // Inicializar referencia al gestor de estado
    if (game != null) {
      this.stateManager = game.gameStateManager;
    }
  }
  
  // Constructor completo con pantalla de carga
  GameRenderer(Game game, Menu menu, VideoIntroMenu videoIntroMenu, 
              AccessibilityManager accessManager, Leaderboard leaderboard,
              PlayerNameInput playerNameInput, XPSummaryScreen xpSummaryScreen,
              LoadingScreen loadingScreen) {
    this.game = game;
    this.menu = menu;
    this.videoIntroMenu = videoIntroMenu;
    this.accessManager = accessManager;
    this.leaderboard = leaderboard;
    this.playerNameInput = playerNameInput;
    this.xpSummaryScreen = xpSummaryScreen;
    this.loadingScreen = loadingScreen;
    
    // Inicializar referencia al gestor de estado
    if (game != null) {
      this.stateManager = game.gameStateManager;
    }
  }
  
  // Establecer referencias a leaderboard y playerNameInput después de la construcción
  void setLeaderboard(Leaderboard leaderboard) {
    this.leaderboard = leaderboard;
  }
  
  void setPlayerNameInput(PlayerNameInput playerNameInput) {
    this.playerNameInput = playerNameInput;
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
    // Limpiar completamente el canvas antes de renderizar para evitar superposiciones
    if (getGameState() == STATE_MAIN_MENU) {
      // Si estamos en el menú principal, asegurar que no quede ningún elemento del juego
      // Forzar una limpieza completa del canvas
      pushStyle();
      // Usar el reset completo de Processing 
      background(0);
      clear();
      popStyle();
    }
    
    renderCurrentGameState();
    displayAccessibilityHelpers();
    
    // Aplicar filtros de accesibilidad como overlay al final de todo
    // Esto asegura que afecten a todos los elementos visuales del juego
    // El orden importa: primero alto contraste, luego daltonismo
    accessManager.applyHighContrastFilter();
    accessManager.applyColorBlindFilter();
  }
  
  void renderCurrentGameState() {
    int currentState = getGameState();
    
    // Añadir una capa de protección adicional
    if (currentState == STATE_MAIN_MENU) {
      // Asegurarse de que no se rendericen otros estados cuando estamos en el menú principal
      renderMainMenu();
      return;
    }
    
    switch(currentState) {
      case STATE_LOADING:
        renderLoadingScreen();
        break;
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
      case STATE_LEADERBOARD:
        renderLeaderboard();
        break;
      case STATE_NAME_INPUT:
        renderNameInput();
        break;
      case STATE_XP_SUMMARY:
        renderXPSummary();
        break;
    }
  }
  
  void renderLoadingScreen() {
    if (loadingScreen != null) {
      loadingScreen.display();
    } else {
      // fallback si no hay pantalla de carga - ir directo al video intro
      stateManager.setState(STATE_INTRO_VIDEO);
    }
  }
  
  void renderIntroVideo() {
    videoIntroMenu.display();
  }
  
  void renderMainMenu() {
    // Asegurarse de que estamos en el menú principal
    if (getGameState() == STATE_MAIN_MENU) {
      // No usamos una limpieza negra aquí, permitimos que el menú
      // maneje completamente su fondo para evitar problemas visuales
      
      // Animación de botones
      if (!videoIntroMenu.buttonsRevealed) {
        videoIntroMenu.display();
      } else {
        menu.displayMainMenu();
      }
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
  
  void renderLeaderboard() {
    // Primero determinar qué pantalla está detrás del leaderboard
    // Si venimos del juego, mostramos el juego; si no, el menú principal
    // Esto es súper importante para mantener el contexto visual y que el usuario no se pierda
    boolean fromGame = game.gameOver || game.gameStateManager.getState() == STATE_GAME_OVER;
    
    if (fromGame) {
      // Renderizar juego como fondo si venimos del juego
      // Así el jugador puede ver su partida detrás del leaderboard
      game.display();
    } else {
      // Renderizar menú principal como fondo en otros casos
      // El menú se ve de fondo y el leaderboard flota encima
      menu.displayMainMenu();
    }
    
    // Luego mostrar la tabla de clasificación como popup encima
    if (leaderboard != null) {
      leaderboard.display();
    }
  }
  
  void renderNameInput() {
    // Primero renderizar el juego como fondo
    game.display();
    
    if (playerNameInput != null) {
      // Actualizar el efecto visual del cursor
      playerNameInput.update();
      
      // Establecer datos del juego finalizado
      playerNameInput.setGameData(game.getScore(), game.playTimeSeconds);
      
      // Mostrar interfaz de entrada
      playerNameInput.display();
    } else {
      // Fallback si la entrada de nombre no está disponible
      renderGameOver();
    }
  }
  
  void renderXPSummary() {
    // Primero renderizar fondo tenue del juego
    game.display();
    
    // Actualizar la pantalla de resumen de XP
    if (xpSummaryScreen != null) {
      xpSummaryScreen.update();
      xpSummaryScreen.display();
    } else {
      // Fallback si no está disponible, volver al menú principal
      stateManager.setState(STATE_MAIN_MENU);
    }
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
