// EcoRunner - juego tipo endless runner sobre cambio climático
Game game;
Menu menu;
SoundManager soundManager;
AccessibilityManager accessManager;
TestRunner testRunner;
VideoIntroMenu videoIntroMenu;

// Navegación
int selectedMenuItem = 0;

// Estados del juego
final int STATE_INTRO_VIDEO = -1;
final int STATE_MAIN_MENU = 0;
final int STATE_INSTRUCTIONS = 1;
final int STATE_SETTINGS = 2;
final int STATE_GAME = 3;
final int STATE_GAME_OVER = 4;
final int STATE_PAUSED = 5;
final int STATE_ACCESSIBILITY = 6;
final int STATE_TESTING = 7;
int gameState = STATE_INTRO_VIDEO;

// Historial de cambios
String[] changelog = {
  "1.0.1 - Implementada navegación con teclado y ratón",
  "1.0.2 - Corregidos problemas de renderizado de texto",
  "1.0.3 - Arreglada función de reinicio en modo daltónico",
  "1.0.4 - Arreglados conflictos de navegación",
  "1.0.5 - Corregidos bugs en transición entre menús",
  "1.1.0 - Añadido framework de pruebas y manejo de errores",
  "1.2.0 - Añadido video intro y mejoradas transiciones"
};

void setup() {
  size(1280, 720);
  
  try {
    game = new Game();
    soundManager = new SoundManager();
    accessManager = new AccessibilityManager();
    menu = new Menu();
    
    testRunner = new TestRunner(game);
    
    try {
      println("Inicializando intro de video...");
      videoIntroMenu = new VideoIntroMenu();
      videoIntroMenu.startVideo();
      println("Intro de video inicializado");
    } catch (Exception e) {
      println("ERROR inicializando intro: " + e.getMessage());
      e.printStackTrace();
      
      if (videoIntroMenu == null) {
        videoIntroMenu = new VideoIntroMenu();
        videoIntroMenu.videoFinished = true;
        videoIntroMenu.videoSkipped = true;
        videoIntroMenu.buttonsRevealed = true;
      }
    }
    
    println("EcoRunner - Juego sobre Cambio Climático");
    println("Controles: ESPACIO para saltar, FLECHA ABAJO para deslizarse, P para pausa");
    println("Accesibilidad: Tecla A o menú principal");
    println("Pruebas: Tecla T para ejecutar, D para debug");
    println("ESC durante intro para saltar al menú");
    
    accessManager.keyboardOnly = false; 
    accessManager.mouseOnly = false;
    
    if (testRunner != null && testRunner.debugSystem != null) {
      testRunner.debugSystem.logInfo("Setup completado");
    }
  } catch (Exception e) {
    println("ERROR en setup: " + e.getMessage());
    e.printStackTrace();
  }
}

void draw() {
  try {
    // Test results
    if (testRunner != null && testRunner.showTestResults && keyPressed && (keyCode == ENTER || keyCode == RETURN)) {
      testRunner.showTestResults = false;
      keyCode = 0;
      key = 0;
      keyPressed = false;
      println("DEBUG: Resultados cerrados con Enter");
    }
    
    // Botón de cierre
    if (testRunner != null && testRunner.showTestResults && testRunner.testFramework.closeRequested) {
      println("DEBUG: Cierre solicitado");
      testRunner.showTestResults = false;
      testRunner.testFramework.closeRequested = false;
    }
    
    // Test runner
    if (testRunner != null) {
      testRunner.update();
    }
    
    // Estados del juego
    switch(gameState) {
      case STATE_INTRO_VIDEO:
        videoIntroMenu.display();
        
        // Comprobar si terminó
        if (videoIntroMenu.isComplete()) {
          gameState = STATE_MAIN_MENU;
          selectedMenuItem = 0;
          menu.updateSelectedItem(gameState, selectedMenuItem);
          println("INTRO COMPLETA: Ir a menú principal");
        }
        break;
      case STATE_MAIN_MENU:
        // Animación de botones
        if (!videoIntroMenu.buttonsRevealed) {
          videoIntroMenu.display();
        } else {
          menu.displayMainMenu();
        }
        break;
      case STATE_INSTRUCTIONS:
        menu.displayInstructions();
        break;
      case STATE_SETTINGS:
        menu.displaySettings();
        break;
      case STATE_GAME:
        game.update();
        game.display();
        break;
      case STATE_GAME_OVER:
        game.display();
        menu.displayGameOverOptions();
        break;
      case STATE_PAUSED:
        game.display();
        menu.displayPauseMenu();
        break;
      case STATE_TESTING:
        background(50);
        fill(255);
        textAlign(CENTER);
        textSize(24);
        text("Modo de Pruebas Activo", width/2, height/2 - 50);
        break;
    }
    
    // Ayuda navegación con teclado
    if (accessManager.keyboardOnly && (gameState != STATE_GAME)) {
      displayKeyboardNavHelper();
    }
    
    // UI test runner
    if (testRunner != null) {
      testRunner.display();
    }
  } catch (Exception e) {
    if (testRunner != null && testRunner.debugSystem != null) {
      testRunner.handleError(e, "draw");
    } else {
      println("ERROR en draw(): " + e.getMessage());
      e.printStackTrace();
    }
  }
}

void keyPressed() {
  try {
    // Input para intro
    if (gameState == STATE_INTRO_VIDEO) {
      videoIntroMenu.handleKeyPressed();
      return;
    }
    
    // Log viewer
    if (testRunner != null && testRunner.showingLogViewer) {
      testRunner.keyPressed();
      return;
    }
    
    // Then check if test results are being shown
    if (testRunner != null && testRunner.showTestResults) {
      testRunner.keyPressed();
      return; // Exit early to prevent any other processing
    }
    
    // Then pass test/debug keys to test runner
    if (testRunner != null && (key == testRunner.TEST_TOGGLE_KEY || 
                              key == testRunner.DEBUG_TOGGLE_KEY || 
                              key == testRunner.DEBUG_LOG_KEY)) {
      testRunner.keyPressed();
      return;
    }
    
    // Global accessibility toggle
    if (key == 'a' || key == 'A') {
      if (gameState != STATE_SETTINGS && gameState != STATE_GAME) {
        gameState = STATE_SETTINGS;
        selectedMenuItem = 3; // Position to the first accessibility option
        menu.updateSelectedItem(gameState, selectedMenuItem);
        return;
      }
    }
    
    // Handle keyboard navigation in menu screens
    if (gameState != STATE_GAME) {
      handleKeyboardNavigation();
      return;
    }
    
    // Game state-specific key handling
    if (gameState == STATE_GAME) {
      // Use accessibility manager to get the appropriate keys
      if (key == accessManager.getJumpKey()) {
        game.player.jump();
        if (testRunner != null) {
          testRunner.logGameEvent("Player Jump", "x:" + game.player.x + ", y:" + game.player.y);
        }
      } else if (key == accessManager.getSlideKey() || keyCode == DOWN) {
        game.player.slide();
        if (testRunner != null) {
          testRunner.logGameEvent("Player Slide", "x:" + game.player.x + ", y:" + game.player.y);
        }
      } else if (key == accessManager.pauseKey) {
        gameState = STATE_PAUSED;
        soundManager.playMenuSound();
        selectedMenuItem = 0; // Reset selection to first pause menu item
        menu.updateSelectedItem(gameState, selectedMenuItem);
      }
      
      // Pass the key press to the game for handling restart
      game.keyPressed();
      
      // Check if game is over
      if (game.gameOver) {
        gameState = STATE_GAME_OVER;
        selectedMenuItem = 0; // Reset selection to first game over menu item
        menu.updateSelectedItem(gameState, selectedMenuItem);
        
        if (testRunner != null) {
          testRunner.logGameEvent("Game Over", "Score: " + game.score);
        }
      }
    } else if (gameState == STATE_PAUSED) {
      if (key == accessManager.pauseKey) {
        gameState = STATE_GAME;
        soundManager.playMenuSound();
      }
    } else if (gameState == STATE_GAME_OVER) {
      if (key == 'r' || key == 'R') {
        game.reset();
        gameState = STATE_GAME;
        
        if (testRunner != null) {
          testRunner.logGameEvent("Game Reset", "New game started");
        }
      }
    }
    
    // Also pass keyPressed to testRunner to handle test result navigation
    if (testRunner != null) {
      testRunner.keyPressed();
    }
  } catch (Exception e) {
    // Handle any unexpected exceptions
    if (testRunner != null && testRunner.debugSystem != null) {
      testRunner.handleError(e, "keyPressed");
    } else {
      // Fallback error handling if testRunner not initialized
      println("ERROR in keyPressed(): " + e.getMessage());
      e.printStackTrace();
    }
  }
}

void keyReleased() {
  if (gameState == STATE_GAME) {
    if (key == accessManager.getJumpKey()) {
      game.player.releaseJump();
    } else if (key == accessManager.getSlideKey() || keyCode == DOWN) {
      game.player.stopSliding();
    }
  }
}

void mousePressed() {
  try {
    // First check if log viewer is being shown - this takes highest priority
    if (testRunner != null && testRunner.showingLogViewer) {
      testRunner.mousePressed();
      println("DEBUG: Mouse press sent to TestRunner for log viewer");
      return; // Exit early to prevent any other processing
    }
    
    // Then check if test results are being shown
    if (testRunner != null && testRunner.showTestResults) {
      testRunner.mousePressed();
      println("DEBUG: Mouse press sent to TestRunner");
      return; // Exit early to prevent any other processing
    }
    
    // Don't process mouse clicks if keyboard-only mode is enabled
    if (accessManager.keyboardOnly) return;
    
    // Check if mouse is in the game window
    if (mouseX < 0 || mouseX > width || mouseY < 0 || mouseY > height) return;
    
    // Process game-specific mouse events
    if (gameState == STATE_GAME) {
      game.mousePressed();
      return;
    }
    
    // Special handling for intro video state
    if (gameState == STATE_INTRO_VIDEO) {
      // Skip intro video if it's playing
      if (!videoIntroMenu.videoFinished && !videoIntroMenu.videoSkipped) {
        videoIntroMenu.videoSkipped = true;
        videoIntroMenu.introVideo.stop();
        videoIntroMenu.startButtonReveal();
        videoIntroMenu.currentRevealingButton = 1; // Trigger first button to appear
      }
      // If video is done and buttons are revealed, handle clicks on the buttons
      else if (videoIntroMenu.buttonsRevealed) {
        // Check each button
        for (int i = 0; i < menu.mainMenuButtons.size(); i++) {
          Button button = menu.mainMenuButtons.get(i);
          if (button.isMouseOver()) {
            // Transition to main menu and activate this button
            gameState = STATE_MAIN_MENU;
            selectedMenuItem = i;
            menu.updateSelectedItem(gameState, selectedMenuItem);
            soundManager.playButtonSound();
            activateSelectedMenuItem();
            return;
          }
        }
      }
      return;
    }
    
    // Handle menu clicks
    switch(gameState) {
      case STATE_MAIN_MENU:
        menu.handleMainMenuClick();
        break;
      case STATE_INSTRUCTIONS:
        menu.handleInstructionsClick();
        break;
      case STATE_SETTINGS:
        menu.handleSettingsClick();
        break;
      case STATE_ACCESSIBILITY:
        menu.handleAccessibilityMenuClick();
        break;
      case STATE_PAUSED:
        menu.handlePauseMenuClick();
        break;
      case STATE_GAME_OVER:
        menu.handleGameOverClick();
        break;
    }
  } catch (Exception e) {
    // Handle any unexpected exceptions
    if (testRunner != null && testRunner.debugSystem != null) {
      testRunner.handleError(e, "mousePressed");
    } else {
      // Fallback error handling
      println("ERROR in mousePressed(): " + e.getMessage());
      e.printStackTrace();
    }
  }
}

// Handle keyboard navigation
void handleKeyboardNavigation() {
  // Skip if test results are being shown
  if (testRunner != null && testRunner.showTestResults) {
    return;
  }

  int oldSelection = selectedMenuItem;
  int menuItemCount = menu.getMenuItemCount(gameState);
  
  if (menuItemCount <= 0) return; // No menu items to navigate
  
  // Navigate through menu items
  if (gameState == STATE_MAIN_MENU) {
    // For main menu, use left/right navigation (horizontal layout)
    if (keyCode == LEFT || key == 'a' || key == 'A') {
      selectedMenuItem--;
      if (oldSelection != selectedMenuItem) {
        soundManager.playMenuSound();
      }
    } else if (keyCode == RIGHT || key == 'd' || key == 'D') {
      selectedMenuItem++;
      if (oldSelection != selectedMenuItem) {
        soundManager.playMenuSound();
      }
    } else if (keyCode == ENTER || keyCode == RETURN || key == ' ') {
      // Activate the currently selected item
      activateSelectedMenuItem();
      soundManager.playButtonSound();
    } else if (keyCode == TAB) {
      // Tab cycles through menu items
      selectedMenuItem++;
      if (oldSelection != selectedMenuItem) {
        soundManager.playMenuSound();
      }
    } else if (keyCode == ESC) {
      // ESC generally goes back to previous menu
      handleEscapeKey();
      key = 0; // Prevent Processing from exiting
    }
  } else {
    // For other menus, use up/down navigation (vertical layout)
    if (keyCode == UP || key == 'w' || key == 'W') {
      selectedMenuItem--;
      if (oldSelection != selectedMenuItem) {
        soundManager.playMenuSound();
      }
    } else if (keyCode == DOWN || key == 's' || key == 'S') {
      selectedMenuItem++;
      if (oldSelection != selectedMenuItem) {
        soundManager.playMenuSound();
      }
    } else if (keyCode == ENTER || keyCode == RETURN || key == ' ') {
      // Activate the currently selected item
      activateSelectedMenuItem();
      soundManager.playButtonSound();
    } else if (keyCode == TAB) {
      // Tab cycles through menu items
      selectedMenuItem++;
      if (oldSelection != selectedMenuItem) {
        soundManager.playMenuSound();
      }
    } else if (keyCode == ESC) {
      // ESC generally goes back to previous menu
      handleEscapeKey();
      key = 0; // Prevent Processing from exiting
    }
  }
  
  // Wrap around menu selection
  if (menuItemCount > 0) { // Protection against empty menus
    if (selectedMenuItem < 0) selectedMenuItem = menuItemCount - 1;
    if (selectedMenuItem >= menuItemCount) selectedMenuItem = 0;
  } else {
    selectedMenuItem = 0;
  }
  
  // Update menu's highlighted item
  menu.updateSelectedItem(gameState, selectedMenuItem);
}

// Activate the currently selected menu item
void activateSelectedMenuItem() {
  switch(gameState) {
    case STATE_MAIN_MENU:
      menu.activateMainMenuItem(selectedMenuItem);
      break;
    case STATE_INSTRUCTIONS:
      menu.activateInstructionsItem(selectedMenuItem);
      break;
    case STATE_SETTINGS:
      menu.activateSettingsItem(selectedMenuItem);
      break;
    case STATE_PAUSED:
      menu.activatePauseMenuItem(selectedMenuItem);
      break;
    case STATE_GAME_OVER:
      menu.activateGameOverItem(selectedMenuItem);
      break;
  }
}

// Handle ESC key for different menus
void handleEscapeKey() {
  switch(gameState) {
    case STATE_INSTRUCTIONS:
    case STATE_SETTINGS:
    case STATE_ACCESSIBILITY:
      gameState = STATE_MAIN_MENU;
      selectedMenuItem = 0;
      menu.updateSelectedItem(gameState, selectedMenuItem);
      break;
    case STATE_PAUSED:
      gameState = STATE_GAME;
      break;
    case STATE_GAME_OVER:
      gameState = STATE_MAIN_MENU;
      selectedMenuItem = 0;
      menu.updateSelectedItem(gameState, selectedMenuItem);
      break;
  }
}

// Display keyboard navigation helper
void displayKeyboardNavHelper() {
  pushStyle();
  fill(0, 0, 0, 150);
  rectMode(CORNER);
  rect(0, height - 30, width, 30);
  
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(accessManager.getAdjustedTextSize(12));
  
  if (gameState == STATE_MAIN_MENU) {
    // Horizontal navigation controls for main menu
    text("←→ o A/D: Navegar | ENTER o ESPACIO: Seleccionar | ESC: Atrás", width/2, height - 15);
  } else {
    // Vertical navigation controls for other menus
    text("↑↓ o W/S: Navegar | ENTER o ESPACIO: Seleccionar | ESC: Atrás", width/2, height - 15);
  }
  
  popStyle();
}

// New helper method to handle exceptions consistently
void handleException(Exception e, String context) {
  if (testRunner != null && testRunner.debugSystem != null) {
    testRunner.handleError(e, context);
  } else {
    println("ERROR in " + context + ": " + e.getMessage());
    e.printStackTrace();
  }
}

// Add mouseWheel event handler to handle scrolling in log viewer
void mouseWheel(MouseEvent event) {
  try {
    // Pass mouse wheel events to the test runner for log viewer scrolling
    if (testRunner != null && testRunner.showingLogViewer) {
      testRunner.mouseWheel(event);
      return;
    }
    
    // Handle other mouse wheel events here if needed
  } catch (Exception e) {
    // Handle any unexpected exceptions
    if (testRunner != null && testRunner.debugSystem != null) {
      testRunner.handleError(e, "mouseWheel");
    } else {
      // Fallback error handling
      println("ERROR in mouseWheel(): " + e.getMessage());
      e.printStackTrace();
    }
  }
}

// Clean up resources when the application exits
void exit() {
  // Stop and free the video resources
  if (videoIntroMenu != null) {
    videoIntroMenu.cleanup();
  }
  
  // Call Processing's default exit behavior
  super.exit();
}
