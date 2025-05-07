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
  AssetManager assetManager;
  
  GameInitializer() {
    // El constructor está vacío porque la inicialización se hace en initializeComponents
  }
  
  void initializeComponents() {
    try {
      // Inicializar primero el gestor de assets
      initializeAssetManager();
      
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
  
  void initializeAssetManager() {
    // Inicializar el gestor de assets con la referencia a PApplet
    assetManager = new AssetManager(applet);
  }
  
  void initializeCoreComponents() {
    // Inicializar en orden correcto: primero accesibilidad, luego sonido, luego juego
    accessManager = new AccessibilityManager();
    soundManager = new SoundManager(accessManager);
    game = new Game(accessManager, soundManager, assetManager);
  }
  
  // Inicializar video intro
  void initializeVideoIntro() {
    videoIntroMenu = new VideoIntroMenu(accessManager, soundManager, assetManager);
    // No necesita establecer una referencia al juego
  }
  
  // Inicializar el menú principal
  void initializeMenu() {
    menu = new Menu(accessManager, videoIntroMenu, game, soundManager, assetManager);
  }
  
  // Métodos getter para recuperar componentes inicializados
  Game getGame() {
    return game;
  }
  
  Menu getMenu() {
    return menu;
  }
  
  SoundManager getSoundManager() {
    return soundManager;
  }
  
  AccessibilityManager getAccessibilityManager() {
    return accessManager;
  }
  
  VideoIntroMenu getVideoIntroMenu() {
    return videoIntroMenu;
  }
  
  // Mostrar instrucciones del juego
  void printGameInstructions() {
    println("\n====== INSTRUCCIONES DEL JUEGO ======");
    println("- Presiona ARRIBA o ESPACIO para saltar");
    println("- Presiona ABAJO para deslizarte");
    println("- Presiona P para pausar");
    println("- Presiona M para silenciar");
    println("- Recoge items buenos y evita obstáculos");
    println("===================================\n");
  }
} 