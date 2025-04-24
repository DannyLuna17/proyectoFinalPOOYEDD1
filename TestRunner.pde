/**
 * TestRunner.pde
 * Ejecutor de pruebas para el juego
 */
 
class TestRunner {
  // Referencia al framework de pruebas
  TestFramework testFramework;
  
  // Referencia al sistema de debug
  DebugSystem debugSystem;
  
  // Estado del modo prueba
  boolean testMode = false;
  boolean showTestResults = false;
  
  // Estado del visor de logs
  boolean showingLogViewer = false;
  
  // Atajos de teclado para pruebas
  final char TEST_TOGGLE_KEY = 't';
  final char DEBUG_TOGGLE_KEY = 'd';
  final char DEBUG_LOG_KEY = 'l';
  
  TestRunner(Game game) {
    debugSystem = new DebugSystem();
    testFramework = new TestFramework(game);
    
    debugSystem.logInfo("TestRunner inicializado");
  }
  
  void update() {
    // Actualizar sistema de debug
    debugSystem.update();
    
    // Actualizar framework de pruebas si se están ejecutando pruebas
    if (testMode) {
      testFramework.update();
      
      // Comprobar si las pruebas han terminado
      if (!testFramework.isRunningTests && showTestResults == false) {
        showTestResults = true;
      }
    }
    
    // Verificar si el framework ha solicitado cerrar los resultados
    if (showTestResults && testFramework.closeRequested) {
      showTestResults = false;
      testFramework.closeRequested = false;
      println("DEBUG: Resultados de prueba cerrados por clic en botón");
    }
  }
  
  void display() {
    // Mostrar info de debug si está habilitada
    debugSystem.display();
    
    // Mostrar indicador de modo prueba
    if (testMode) {
      displayTestModeIndicator();
    }
    
    // Mostrar resultados de pruebas si están disponibles y se solicitan
    if (showTestResults) {
      testFramework.displayResults();
    }
    
    // Mostrar visor de logs si se solicita
    if (showingLogViewer) {
      debugSystem.showLogViewer();
    }
  }
  
  void displayTestModeIndicator() {
    pushStyle();
    fill(0, 150);
    rect(10, height - 40, 180, 30);
    
    fill(255);
    textAlign(LEFT, CENTER);
    textSize(14);
    String status = testFramework.isRunningTests ? 
                  "Probando: " + testFramework.currentTestName : 
                  "Pruebas Completadas";
    text(status, 20, height - 25);
    popStyle();
  }
  
  void keyPressed() {
    // Cerrar visor de logs si está abierto
    if (showingLogViewer && (keyCode == ESC || key == 27)) {
      showingLogViewer = false;
      keyCode = 0;
      key = 0;
      println("DEBUG: Visor de logs cerrado con tecla ESC");
      return;
    }
    
    // Manejar scroll del visor de logs
    if (showingLogViewer) {
      debugSystem.handleLogViewerKeyPressed();
      return;
    }
    
    // Cerrar pantalla de resultados de pruebas
    if (showTestResults && (keyCode == ENTER || keyCode == RETURN)) {
      showTestResults = false;
      if (gameState == STATE_PAUSED) {
        gameState = STATE_MAIN_MENU;
      }
      keyCode = 0;
      key = 0;
      println("DEBUG: Resultados de prueba cerrados con tecla Enter");
      return;
    }
    
    // Alternar modo prueba
    if (key == TEST_TOGGLE_KEY && !testFramework.isRunningTests) {
      toggleTestMode();
    }
    
    // Alternar características del modo debug
    if (key == DEBUG_TOGGLE_KEY) {
      toggleDebugMode();
    }
    
    // Mostrar logs de debug
    if (key == DEBUG_LOG_KEY) {
      debugSystem.setLogLevel(debugSystem.LOG_DEBUG);
      if (debugSystem.logEntries.size() == 0) {
        debugSystem.logInfo("Visor de logs de debug activado");
        debugSystem.logDebug("No se encontraron entradas de log previas");
      }
      showingLogViewer = true;
      debugSystem.logScrollPosition = max(0, debugSystem.logEntries.size() - debugSystem.logEntriesPerPage);
    }
  }
  
  void mousePressed() {
    // Cerrar visor de logs con clic del ratón si está abierto
    if (showingLogViewer) {
      showingLogViewer = false;
      println("DEBUG: Visor de logs cerrado por clic del ratón");
      return;
    }
    
    // Comprobar si se están mostrando resultados de prueba
    if (showTestResults) {
      // Definir dimensiones del botón (igual que en TestFramework.displayResults)
      float buttonX = width/2;
      float buttonY = height - 70;
      float buttonWidth = 120;
      float buttonHeight = 40;
      
      // Comprobar si se ha hecho clic en el botón
      boolean clickedOnButton = mouseX > buttonX - buttonWidth/2 && 
                              mouseX < buttonX + buttonWidth/2 && 
                              mouseY > buttonY - buttonHeight/2 && 
                              mouseY < buttonY + buttonHeight/2;
      
      // Definir límites del panel
      float panelLeft = 50;
      float panelTop = 50;
      float panelRight = width - 50;
      float panelBottom = height - 50;
      
      // Comprobar si se ha hecho clic fuera del panel
      boolean clickedOutsidePanel = mouseX < panelLeft || mouseX > panelRight || 
                                   mouseY < panelTop || mouseY > panelBottom;
      
      if (clickedOnButton || clickedOutsidePanel) {
        showTestResults = false;
        println("DEBUG: Resultados de prueba cerrados por clic");
        return;
      }
    }
  }
  
  // Manejar eventos de rueda del ratón para desplazar el visor de logs
  void mouseWheel(MouseEvent event) {
    if (showingLogViewer) {
      int delta = event.getCount();
      debugSystem.handleLogViewerMouseWheel(delta);
    }
  }
  
  void toggleTestMode() {
    testMode = !testMode;
    if (testMode) {
      debugSystem.logInfo("Modo prueba activado");
      // Set TestFramework's testMode to match
      testFramework.testMode = testMode;
      // Start running tests
      testFramework.runAllTests();
    } else {
      debugSystem.logInfo("Test mode deactivated");
      // Set TestFramework's testMode to match
      testFramework.testMode = testMode;
      showTestResults = false;
    }
  }
  
  void toggleDebugMode() {
    // Cycle through debug visualization options
    if (!debugSystem.showCollisionBoxes) {
      // Enable collision boxes
      debugSystem.toggleCollisionBoxes();
    } else if (!debugSystem.showPerformanceMetrics) {
      // Enable performance metrics, keep collision boxes
      debugSystem.togglePerformanceMetrics();
    } else if (!debugSystem.showEcoSystemDebug) {
      // Enable eco-system debug, keep others
      debugSystem.toggleEcoSystemDebug();
    } else if (!debugSystem.validationActive) {
      // Enable validation, keep all visuals
      debugSystem.toggleValidation();
    } else {
      // Turn everything off
      if (debugSystem.showCollisionBoxes) debugSystem.toggleCollisionBoxes();
      if (debugSystem.showPerformanceMetrics) debugSystem.togglePerformanceMetrics();
      if (debugSystem.showEcoSystemDebug) debugSystem.toggleEcoSystemDebug();
      if (debugSystem.validationActive) debugSystem.toggleValidation();
    }
  }
  
  // Handle errors gracefully
  void handleError(Exception e, String context) {
    debugSystem.logError("Error in " + context + ": " + e.getMessage());
    e.printStackTrace();
    
    // Display error overlay if in game state
    if (gameState == STATE_GAME) {
      debugSystem.displayErrorOverlay("Error: " + e.getMessage());
    }
  }
  
  // Run a specific test by name
  void runSpecificTest(String testName) {
    debugSystem.logInfo("Running specific test: " + testName);
    
    // Find the test method using reflection
    try {
      java.lang.reflect.Method method = testFramework.getClass().getMethod(testName);
      method.invoke(testFramework);
      showTestResults = true;
    } catch (Exception e) {
      debugSystem.logError("Failed to run test '" + testName + "': " + e.getMessage());
    }
  }
  
  // Log a game event for debugging
  void logGameEvent(String event, String details) {
    debugSystem.logInfo("GAME EVENT: " + event + " - " + details);
  }
} 