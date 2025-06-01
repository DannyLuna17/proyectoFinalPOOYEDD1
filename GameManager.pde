/**
 * GameManager.pde
 * 
 * Clase principal de gestión del juego que coordina todos los componentes.
 * Proporciona acceso centralizado al estado del juego y maneja el flujo general.
 */

class GameManager {
  // Componentes principales
  Game game;
  Menu menu;
  SoundManager soundManager;
  AccessibilityManager accessManager;
  VideoIntroMenu videoIntroMenu;
  Leaderboard leaderboard;
  PlayerNameInput playerNameInput;
  XPSummaryScreen xpSummaryScreen; // Pantalla de resumen de XP que se muestra después del leaderboard
  
  // Gestores
  GameStateManager stateManager;
  GameRenderer renderer;
  InputHandler inputHandler;
  CleanupManager cleanupManager;
  
  // Estado
  int selectedMenuItem;
  
  GameManager() {
    // Inicializar todos los componentes a través de GameInitializer
    initializeComponents();
    
    // Crear clases gestoras
    createManagers();
    
    // Establecer estado inicial
    selectedMenuItem = 0;
  }
  
  void initializeComponents() {
    GameInitializer initializer = new GameInitializer();
    initializer.initializeComponents();
    
    // Obtener referencias a los componentes inicializados
    game = initializer.getGame();
    menu = initializer.getMenu();
    soundManager = initializer.getSoundManager();
    accessManager = initializer.getAccessibilityManager();
    videoIntroMenu = initializer.getVideoIntroMenu();
    leaderboard = initializer.getLeaderboard();
    playerNameInput = initializer.getPlayerNameInput();
    
    // Inicializar pantalla de resumen de XP
    xpSummaryScreen = new XPSummaryScreen(accessManager, game.playerProgression);
    
    // Mostrar instrucciones del juego
    initializer.printGameInstructions();
  }
  
  void createManagers() {
    // Crear gestor de estados
    stateManager = new GameStateManager();
    stateManager.setState(STATE_INTRO_VIDEO);
    
    // Crear renderizador con todos los componentes necesarios
    renderer = new GameRenderer(game, menu, videoIntroMenu, accessManager, leaderboard, playerNameInput, xpSummaryScreen);
    renderer.setGameState(stateManager.getState());
    renderer.setSelectedMenuItem(selectedMenuItem);
    
    // Crear gestor de entrada con todos los componentes necesarios
    inputHandler = new InputHandler(game, menu, accessManager, soundManager, videoIntroMenu);
    inputHandler.setGameState(stateManager.getState());
    inputHandler.setSelectedMenuItem(selectedMenuItem);
    inputHandler.leaderboard = leaderboard;
    inputHandler.playerNameInput = playerNameInput;
    inputHandler.setGameManager(this);
    
    // Crear gestor de limpieza
    cleanupManager = new CleanupManager();
  }
  
  void update() {
    // Verificar transiciones de estado
    checkForStateTransitions();
    
    // Verificar automáticamente el estado de fin de juego
    if (inputHandler != null) {
      inputHandler.checkGameOver();
    }
  }
  
  void render() {
    renderer.render();
  }
  
  void checkForStateTransitions() {
    // Verificar si el video de introducción ha terminado
    if (stateManager.getState() == STATE_INTRO_VIDEO && videoIntroMenu.isComplete()) {
      stateManager.setState(STATE_MAIN_MENU);
      updateComponentsAfterStateChange();
    }
    
    // Verificar si el juego ha terminado
    if (stateManager.getState() == STATE_GAME && game.gameOver) {
      stateManager.setState(STATE_GAME_OVER);
      updateComponentsAfterStateChange();
    }
  }
  
  void updateComponentsAfterStateChange() {
    inputHandler.setGameState(stateManager.getState());
    inputHandler.setSelectedMenuItem(selectedMenuItem);
    renderer.setGameState(stateManager.getState());
    renderer.setSelectedMenuItem(selectedMenuItem);
    menu.updateSelectedItem(stateManager.getState(), selectedMenuItem);
  }
  
  void setSelectedMenuItem(int selectedMenuItem) {
    this.selectedMenuItem = selectedMenuItem;
    renderer.setSelectedMenuItem(selectedMenuItem);
    inputHandler.setSelectedMenuItem(selectedMenuItem);
    menu.updateSelectedItem(stateManager.getState(), selectedMenuItem);
  }
  
  void cleanup() {
    cleanupManager.performCleanup();
  }
  
  // Métodos para manejar eventos
  void handleKeyPressed() {
    inputHandler.handleKeyPressed();
  }
  
  void handleKeyReleased() {
    inputHandler.handleKeyReleased();
  }
  
  void handleMousePressed() {
    inputHandler.handleMousePressed();
  }
  
  void handleMouseDragged() {
    inputHandler.handleMouseDragged();
  }
  
  void handleMouseReleased() {
    inputHandler.handleMouseReleased();
  }
  
  void handleMouseWheel(MouseEvent event) {
    inputHandler.handleMouseWheel(event);
  }
} 
