/**
 * GameInitializer.pde
 * 
 * Maneja la inicialización de todos los componentes y subsistemas del juego.
 * Centraliza el código de configuración para hacerlo más fácil de mantener.
 */

class GameInitializer {
  // Componentes del juego que serán inicializados
  Game game;
  Menu menu;
  SoundManager soundManager;
  AccessibilityManager accessManager;
  VideoIntroMenu videoIntroMenu;
  
  GameInitializer() {
    // El constructor está vacío porque la inicialización se hace en initializeComponents
  }
  
  void initializeComponents() {
    try {
      // Inicializar componentes principales, pero no el Menú todavía
      initializeCoreComponents();
      
      // Inicializar la intro de video antes del menú
      initializeVideoIntro();
      
      // Ahora inicializar el menú con la intro de video
      initializeMenu();
      
      // Ahora que el menú está inicializado, asignarlo al VideoIntroMenu
      videoIntroMenu.setMenu(menu);
      
      // Configurar ajustes de accesibilidad
      accessManager.keyboardOnly = false; 
      accessManager.mouseOnly = false;
      
      println("Setup completado");
    } catch (Exception e) {
      println("ERROR en setup: " + e.getMessage());
      e.printStackTrace();
    }
  }
  
  void initializeCoreComponents() {
    // Inicializar en orden correcto: primero accesibilidad, luego sonido, luego juego
    accessManager = new AccessibilityManager();
    soundManager = new SoundManager(accessManager);
    game = new Game(accessManager, soundManager);
  }
  
  void initializeVideoIntro() {
    try {
      println("Inicializando intro de video...");
      videoIntroMenu = new VideoIntroMenu(accessManager, soundManager);
      videoIntroMenu.startVideo();
      println("Intro de video inicializado");
    } catch (Exception e) {
      println("ERROR inicializando intro: " + e.getMessage());
      e.printStackTrace();
      
      // Inicialización alternativa
      if (videoIntroMenu == null) {
        videoIntroMenu = new VideoIntroMenu(accessManager, soundManager);
        videoIntroMenu.videoFinished = true;
        videoIntroMenu.videoSkipped = true;
        videoIntroMenu.buttonsRevealed = true;
      }
    }
  }
  
  void initializeMenu() {
    // Crear menú con referencia a la intro de video y referencias adicionales al juego y soundManager
    menu = new Menu(accessManager, videoIntroMenu, game, soundManager);
  }
  
  void printGameInstructions() {
    println("EcoRunner - Juego sobre Cambio Climático");
    println("Controles: ESPACIO para saltar, FLECHA ABAJO para deslizarse, P para pausa");
    println("Accesibilidad: Tecla A o menú principal");
    println("ESC durante intro para saltar al menú");
  }
  
  // Getters para los componentes inicializados
  Game getGame() { return game; }
  Menu getMenu() { return menu; }
  SoundManager getSoundManager() { return soundManager; }
  AccessibilityManager getAccessibilityManager() { return accessManager; }
  VideoIntroMenu getVideoIntroMenu() { return videoIntroMenu; }
} 