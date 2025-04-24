/**
 * DebugSystem.pde
 * Sistema para manejo de errores y depuración del juego
 */
 
class DebugSystem {
  // Niveles de log
  final int LOG_ERROR = 0;
  final int LOG_WARNING = 1;
  final int LOG_INFO = 2;
  final int LOG_DEBUG = 3;
  
  // Constantes de teclas
  final int PAGE_UP = 33;
  final int PAGE_DOWN = 34;
  final int HOME = 36;
  final int END = 35;
  
  // Nivel actual (solo se mostrarán mensajes de este nivel o mayor prioridad)
  int currentLogLevel = LOG_WARNING;
  
  // Almacenamiento de logs
  ArrayList<LogEntry> logEntries = new ArrayList<LogEntry>();
  int maxLogEntries = 1000;
  
  // Posición scroll del visor de logs
  int logScrollPosition = 0;
  int logEntriesPerPage = 18; // Entradas visibles a la vez
  
  // Validación de estado del juego
  boolean validationActive = false;
  
  // Visualización de debug
  boolean showCollisionBoxes = false;
  boolean showPerformanceMetrics = false;
  boolean showEcoSystemDebug = false;
  
  // Rendimiento
  float[] frameTimes = new float[60]; 
  int frameTimeIndex = 0;
  int frameCount = 0;
  
  // Cálculo de FPS
  float lastFrameTime = 0;
  float smoothedFrameRate = 60;
  
  DebugSystem() {
    logInfo("Sistema de debug iniciado");
  }
  
  // Métodos de logging
  void logError(String message) {
    if (currentLogLevel >= LOG_ERROR) {
      addLogEntry(new LogEntry(LOG_ERROR, message));
      println("[ERROR] " + message);
      printCurrentStack();
    }
  }
  
  void logWarning(String message) {
    if (currentLogLevel >= LOG_WARNING) {
      addLogEntry(new LogEntry(LOG_WARNING, message));
      println("[WARNING] " + message);
    }
  }
  
  void logInfo(String message) {
    if (currentLogLevel >= LOG_INFO) {
      addLogEntry(new LogEntry(LOG_INFO, message));
      println("[INFO] " + message);
    }
  }
  
  void logDebug(String message) {
    if (currentLogLevel >= LOG_DEBUG) {
      addLogEntry(new LogEntry(LOG_DEBUG, message));
      println("[DEBUG] " + message);
    }
  }
  
  // Añadir entrada al log
  void addLogEntry(LogEntry entry) {
    logEntries.add(entry);
    // Eliminar entradas más antiguas si se supera el máximo
    while (logEntries.size() > maxLogEntries) {
      logEntries.remove(0);
    }
  }
  
  // Imprimir stack trace para identificar errores
  void printCurrentStack() {
    try {
      throw new Exception("Stack trace");
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
  
  // Update que se llama cada frame
  void update() {
    // Actualizar métricas de tiempo
    float currentTime = millis();
    if (lastFrameTime > 0) {
      float frameTime = currentTime - lastFrameTime;
      frameTimes[frameTimeIndex] = frameTime;
      frameTimeIndex = (frameTimeIndex + 1) % frameTimes.length;
      
      // Calcular FPS suavizado
      float totalTime = 0;
      for (float time : frameTimes) {
        if (time > 0) totalTime += time;
      }
      
      // Calcular tiempo medio de frame y convertir a FPS
      int validFrames = 0;
      for (float time : frameTimes) {
        if (time > 0) validFrames++;
      }
      
      if (validFrames > 0) {
        float avgFrameTime = totalTime / validFrames;
        if (avgFrameTime > 0) {
          smoothedFrameRate = 1000.0 / avgFrameTime;
        }
      }
    }
    lastFrameTime = currentTime;
    frameCount++;
    
    // Ejecutar validación si está activada
    if (validationActive && frameCount % 60 == 0) { // Una vez por segundo
      validateGameState();
    }
  }
  
  // Mostrar info de debug
  void display() {
    pushStyle();
    
    if (showPerformanceMetrics) {
      displayPerformanceMetrics();
    }
    
    if (showCollisionBoxes) {
      displayCollisionBoxes();
    }
    
    if (showEcoSystemDebug) {
      displayEcoSystemDebug();
    }
    
    popStyle();
  }
  
  // Mostrar FPS y datos de rendimiento
  void displayPerformanceMetrics() {
    fill(0, 150);
    rect(10, 10, 120, 60);
    
    fill(255);
    textAlign(LEFT);
    textSize(14);
    text("FPS: " + nf(smoothedFrameRate, 0, 1), 20, 30);
    text("Memory: " + (Runtime.getRuntime().totalMemory() - Runtime.getRuntime().freeMemory()) / (1024*1024) + " MB", 20, 50);
  }
  
  // Mostrar cajas de colisión para debug
  void displayCollisionBoxes() {
    if (gameState != STATE_GAME) return;
    
    noFill();
    strokeWeight(2);
    
    // Caja de colisión del jugador
    stroke(255, 0, 0);
    if (game.player.isSliding) {
      // Hitbox al deslizarse
      ellipse(game.player.x, game.player.y + game.player.size/4, game.player.size * 1.2, game.player.size/2);
    } else {
      // Hitbox normal
      ellipse(game.player.x, game.player.y - game.player.size/2, game.player.size, game.player.size);
    }
    
    // Cajas de colisión de obstáculos
    stroke(0, 0, 255);
    for (Obstacle obstacle : game.obstacles) {
      rect(obstacle.x - obstacle.w/2, obstacle.getTop(), obstacle.w, obstacle.getHeight());
    }
    
    // Cajas de colisión de coleccionables
    stroke(0, 255, 0);
    for (Collectible collectible : game.collectibles) {
      ellipse(collectible.x, collectible.y, collectible.size, collectible.size);
    }
  }
  
  // Display detailed eco-system debugging information
  void displayEcoSystemDebug() {
    if (gameState != STATE_GAME) return;
    
    EcoSystem eco = game.ecoSystem;
    
    fill(0, 150);
    rect(width - 200, 10, 190, 100);
    
    fill(255);
    textAlign(LEFT);
    textSize(12);
    text("Eco Health: " + nf(eco.ecoHealth, 0, 1), width - 190, 30);
    text("State: " + getEcoStateName(eco), width - 190, 50);
    text("Pollution: " + (eco.pollutionEffect ? "Yes (" + nf(eco.pollutionDensity, 0, 2) + ")" : "No"), width - 190, 70);
    text("Active Effect: " + (eco.hasActiveEffect ? eco.activeEffectName : "None"), width - 190, 90);
  }
  
  // Get eco-system state name
  String getEcoStateName(EcoSystem eco) {
    if (eco.isInGoodState()) return "GOOD";
    if (eco.isInWarningState()) return "WARNING";
    if (eco.isInCriticalState()) return "CRITICAL";
    return "NORMAL";
  }
  
  // Display runtime error overlay (for serious errors)
  void displayErrorOverlay(String errorMessage) {
    pushStyle();
    // Semi-transparent background
    fill(0, 200);
    rect(0, 0, width, height);
    
    // Error box
    fill(40);
    stroke(255, 0, 0);
    strokeWeight(3);
    rect(width/2 - 250, height/2 - 100, 500, 200);
    
    // Error title
    fill(255, 0, 0);
    textAlign(CENTER);
    textSize(24);
    text("Runtime Error", width/2, height/2 - 70);
    
    // Error message
    fill(255);
    textAlign(CENTER);
    textSize(16);
    text(errorMessage, width/2, height/2);
    
    // Recovery instructions
    fill(200);
    textSize(14);
    text("Press ESC to return to main menu", width/2, height/2 + 70);
    popStyle();
  }
  
  // Game state validation - check for inconsistent state
  void validateGameState() {
    if (gameState != STATE_GAME) return;
    
    try {
      // Check player is in valid state
      validatePlayerState();
      
      // Check eco-system is in valid state
      validateEcoSystemState();
      
      // Check obstacles are in valid state
      validateObstacles();
      
      // Check collectibles are in valid state
      validateCollectibles();
    } catch (Exception e) {
      logError("Game state validation failed: " + e.getMessage());
    }
  }
  
  // Validate player state
  void validatePlayerState() {
    Player player = game.player;
    
    // Ensure player position is within reasonable bounds
    if (Float.isNaN(player.x) || Float.isNaN(player.y)) {
      logError("Player position contains NaN values");
      fixPlayerPosition();
    }
    
    // Ensure player is not below ground level
    if (player.y > player.groundY + 50) {
      logWarning("Player below ground level, resetting position");
      player.y = player.groundY;
    }
    
    // Check for valid health values
    if (player.health < 0 || player.health > 3) {
      logWarning("Invalid player health: " + player.health);
      player.health = constrain(player.health, 0, 3);
    }
    
    // Check for inconsistent jump state
    if (player.isJumping && player.y >= player.groundY) {
      logWarning("Inconsistent jump state, player on ground but isJumping = true");
      player.isJumping = false;
    }
  }
  
  // Validate eco-system state
  void validateEcoSystemState() {
    EcoSystem eco = game.ecoSystem;
    
    // Ensure health is within bounds
    if (eco.ecoHealth < eco.minEcoHealth || eco.ecoHealth > eco.maxEcoHealth) {
      logWarning("Eco-system health out of bounds: " + eco.ecoHealth);
      eco.ecoHealth = constrain(eco.ecoHealth, eco.minEcoHealth, eco.maxEcoHealth);
    }
    
    // Check for consistent state flags
    boolean goodState = eco.isInGoodState();
    boolean warningState = eco.isInWarningState();
    boolean criticalState = eco.isInCriticalState();
    
    // Only one state should be true at a time
    if ((goodState && warningState) || (goodState && criticalState) || (warningState && criticalState)) {
      logWarning("Inconsistent eco-system state flags");
    }
  }
  
  // Validate obstacles
  void validateObstacles() {
    // Look for invalid obstacles
    for (int i = game.obstacles.size() - 1; i >= 0; i--) {
      Obstacle obstacle = game.obstacles.get(i);
      
      // Check for valid position
      if (Float.isNaN(obstacle.x) || Float.isNaN(obstacle.y)) {
        logWarning("Obstacle has NaN position, removing");
        game.obstacles.remove(i);
        continue;
      }
      
      // Check for obstacles off-screen
      if (obstacle.x < -500) {
        logWarning("Obstacle far off-screen, removing");
        game.obstacles.remove(i);
      }
    }
  }
  
  // Validate collectibles
  void validateCollectibles() {
    // Look for invalid collectibles
    for (int i = game.collectibles.size() - 1; i >= 0; i--) {
      Collectible collectible = game.collectibles.get(i);
      
      // Check for valid position
      if (Float.isNaN(collectible.x) || Float.isNaN(collectible.y)) {
        logWarning("Collectible has NaN position, removing");
        game.collectibles.remove(i);
        continue;
      }
      
      // Check for collectibles off-screen
      if (collectible.x < -500) {
        logWarning("Collectible far off-screen, removing");
        game.collectibles.remove(i);
      }
    }
  }
  
  // Emergency recovery methods
  
  // Fix player position if invalid
  void fixPlayerPosition() {
    Player player = game.player;
    if (Float.isNaN(player.x) || player.x < 0 || player.x > width) {
      player.x = width * 0.2;
    }
    if (Float.isNaN(player.y) || player.y < 0 || player.y > height * 2) {
      player.y = player.groundY;
    }
    player.vSpeed = 0;
  }
  
  // Show log viewer (for in-game debugging)
  void showLogViewer() {
    pushStyle();
    // Semi-transparent background
    fill(0, 200);
    rect(0, 0, width, height);
    
    // Log panel
    fill(40);
    stroke(200);
    strokeWeight(2);
    float panelX = width/2 - 350;
    float panelY = height/2 - 200;
    float panelWidth = 700;
    float panelHeight = 400;
    rect(panelX, panelY, panelWidth, panelHeight);
    
    // Title
    fill(255);
    textAlign(CENTER);
    textSize(20);
    text("Debug Log", width/2, panelY + 30);
    
    // Calculate total entries and maximum scroll position
    int totalVisibleEntries = min(logEntriesPerPage, logEntries.size());
    int maxScrollPosition = max(0, logEntries.size() - logEntriesPerPage);
    
    // Clamp scroll position
    logScrollPosition = constrain(logScrollPosition, 0, maxScrollPosition);
    
    // Log entries area with clipping
    pushMatrix();
    pushStyle();
    // Create a clipping region for the log entries
    float logAreaX = panelX + 10;
    float logAreaY = panelY + 60;
    float logAreaWidth = panelWidth - 40; // Make room for scrollbar
    float logAreaHeight = panelHeight - 120;
    
    // Use a clip rect to prevent text from extending outside the panel
    clip(logAreaX, logAreaY, logAreaWidth, logAreaHeight);
    
    // Log entries
    textAlign(LEFT);
    textSize(12);
    int startIndex = logScrollPosition;
    int endIndex = min(startIndex + logEntriesPerPage, logEntries.size());
    
    float y = logAreaY;
    for (int i = startIndex; i < endIndex; i++) {
      LogEntry entry = logEntries.get(i);
      
      // Color based on log level
      switch (entry.level) {
        case LOG_ERROR:
          fill(255, 0, 0);
          break;
        case LOG_WARNING:
          fill(255, 200, 0);
          break;
        case LOG_INFO:
          fill(0, 255, 0);
          break;
        case LOG_DEBUG:
          fill(200);
          break;
      }
      
      // Format timestamp
      String timestamp = entry.getFormattedTimestamp();
      
      // Display log entry with proper word wrap
      text(timestamp + " " + entry.getMessage(), logAreaX, y);
      y += 20;
    }
    
    // End clipping
    popStyle();
    popMatrix();
    
    // Draw scrollbar if needed
    if (logEntries.size() > logEntriesPerPage) {
      // Scrollbar background
      fill(60);
      float scrollbarX = panelX + panelWidth - 25;
      float scrollbarY = logAreaY;
      float scrollbarWidth = 15;
      float scrollbarHeight = logAreaHeight;
      rect(scrollbarX, scrollbarY, scrollbarWidth, scrollbarHeight);
      
      // Scrollbar handle
      float handleHeight = (float)logEntriesPerPage / logEntries.size() * scrollbarHeight;
      handleHeight = max(20, handleHeight); // Minimum handle size
      
      float scrollRatio = (float)logScrollPosition / maxScrollPosition;
      float handleY = scrollbarY + scrollRatio * (scrollbarHeight - handleHeight);
      
      fill(150);
      rect(scrollbarX, handleY, scrollbarWidth, handleHeight);
    }
    
    // Instructions
    fill(200);
    textAlign(CENTER);
    textSize(14);
    text("Press ESC to close | Page Up/Down to scroll | Mouse wheel to scroll", width/2, panelY + panelHeight - 20);
    popStyle();
  }
  
  // Handle keyboard input for log viewer
  void handleLogViewerKeyPressed() {
    if (keyCode == PAGE_UP) {
      logScrollPosition = max(0, logScrollPosition - 5);
    } else if (keyCode == PAGE_DOWN) {
      int maxScroll = max(0, logEntries.size() - logEntriesPerPage);
      logScrollPosition = min(maxScroll, logScrollPosition + 5);
    } else if (keyCode == UP) {
      logScrollPosition = max(0, logScrollPosition - 1);
    } else if (keyCode == DOWN) {
      int maxScroll = max(0, logEntries.size() - logEntriesPerPage);
      logScrollPosition = min(maxScroll, logScrollPosition + 1);
    } else if (keyCode == HOME) {
      logScrollPosition = 0;
    } else if (keyCode == END) {
      logScrollPosition = max(0, logEntries.size() - logEntriesPerPage);
    }
  }
  
  // Handle mouse wheel for log viewer
  void handleLogViewerMouseWheel(int delta) {
    // delta is positive when scrolling up, negative when scrolling down
    logScrollPosition = constrain(logScrollPosition - delta, 0, max(0, logEntries.size() - logEntriesPerPage));
  }
  
  // Toggle debug displays
  void toggleCollisionBoxes() {
    showCollisionBoxes = !showCollisionBoxes;
    logInfo("Collision boxes " + (showCollisionBoxes ? "enabled" : "disabled"));
  }
  
  void togglePerformanceMetrics() {
    showPerformanceMetrics = !showPerformanceMetrics;
    logInfo("Performance metrics " + (showPerformanceMetrics ? "enabled" : "disabled"));
  }
  
  void toggleEcoSystemDebug() {
    showEcoSystemDebug = !showEcoSystemDebug;
    logInfo("EcoSystem debug " + (showEcoSystemDebug ? "enabled" : "disabled"));
  }
  
  void toggleValidation() {
    validationActive = !validationActive;
    logInfo("Game state validation " + (validationActive ? "enabled" : "disabled"));
  }
  
  // Set log level
  void setLogLevel(int level) {
    currentLogLevel = constrain(level, LOG_ERROR, LOG_DEBUG);
    String[] levelNames = {"ERROR", "WARNING", "INFO", "DEBUG"};
    logInfo("Log level set to " + levelNames[currentLogLevel]);
  }
}

// Log entry data structure
class LogEntry {
  int level;
  String message;
  long timestamp;
  
  LogEntry(int level, String message) {
    this.level = level;
    this.message = message;
    this.timestamp = System.currentTimeMillis();
  }
  
  String getLevelName() {
    switch (level) {
      case 0: return "ERROR";
      case 1: return "WARNING";
      case 2: return "INFO";
      case 3: return "DEBUG";
      default: return "UNKNOWN";
    }
  }
  
  String getMessage() {
    return "[" + getLevelName() + "] " + message;
  }
  
  String getFormattedTimestamp() {
    // Format: HH:MM:SS.mmm
    int seconds = (int)(timestamp / 1000) % 60;
    int minutes = (int)((timestamp / (1000 * 60)) % 60);
    int hours = (int)((timestamp / (1000 * 60 * 60)) % 24);
    int millis = (int)(timestamp % 1000);
    
    return String.format("%02d:%02d:%02d.%03d", hours, minutes, seconds, millis);
  }
} 