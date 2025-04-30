/**
 * DebugSystem.pde
 * Sistema para debug del juego
 */
 
class DebugSystem {
  // Niveles de log
  final int LOG_ERROR = 0;
  final int LOG_WARNING = 1;
  final int LOG_INFO = 2;
  final int LOG_DEBUG = 3;
  
  // Teclas
  final int PAGE_UP = 33;
  final int PAGE_DOWN = 34;
  final int HOME = 36;
  final int END = 35;
  
  // Nivel actual
  int currentLogLevel = LOG_WARNING;
  
  // Logs
  ArrayList<LogEntry> logEntries = new ArrayList<LogEntry>();
  int maxLogEntries = 1000;
  
  // Scroll del visor
  int logScrollPosition = 0;
  int logEntriesPerPage = 18;
  
  // Validación
  boolean validationActive = false;
  
  // Visualización
  boolean showCollisionBoxes = false;
  boolean showPerformanceMetrics = false;
  boolean showEcoSystemDebug = false;
  
  // Rendimiento
  float[] frameTimes = new float[60]; 
  int frameTimeIndex = 0;
  int frameCount = 0;
  
  // FPS
  float lastFrameTime = 0;
  float smoothedFrameRate = 60;
  
  // Referencias a componentes del juego
  GameStateManager gameStateManager;
  Game game;
  
  DebugSystem(GameStateManager gameStateManager, Game game) {
    this.gameStateManager = gameStateManager;
    this.game = game;
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
  
  // Añadir entrada
  void addLogEntry(LogEntry entry) {
    logEntries.add(entry);
    // Eliminar entradas antiguas
    while (logEntries.size() > maxLogEntries) {
      logEntries.remove(0);
    }
  }
  
  // Imprimir stack trace
  void printCurrentStack() {
    try {
      throw new Exception("Stack trace");
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
  
  // Cerrar archivo de log y realizar la limpieza necesaria
  void closeLogFile() {
    logInfo("Cerrando archivo de log de depuración");
    // Si tuviéramos un manejador de archivo real, lo cerraríamos aquí
    // Como los logs actualmente solo se almacenan en memoria y se imprimen en consola,
    // solo añadimos una entrada final en el log
    addLogEntry(new LogEntry(LOG_INFO, "Log de depuración cerrado"));
    println("[INFO] Log de depuración cerrado");
  }
  
  // Actualizar cada frame
  void update() {
    // Métricas de tiempo
    float currentTime = millis();
    if (lastFrameTime > 0) {
      float frameTime = currentTime - lastFrameTime;
      frameTimes[frameTimeIndex] = frameTime;
      frameTimeIndex = (frameTimeIndex + 1) % frameTimes.length;
      
      // FPS suavizado
      float totalTime = 0;
      for (float time : frameTimes) {
        if (time > 0) totalTime += time;
      }
      
      // Tiempo medio de frame
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
    
    // Validación
    if (validationActive && frameCount % 60 == 0) { // Una vez por segundo
      validateGameState();
    }
  }
  
  // Mostrar info
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
  
  // FPS y rendimiento
  void displayPerformanceMetrics() {
    fill(0, 150);
    rect(10, 10, 120, 60);
    
    fill(255);
    textAlign(LEFT);
    textSize(14);
    text("FPS: " + nf(smoothedFrameRate, 0, 1), 20, 30);
    text("Memoria: " + (Runtime.getRuntime().totalMemory() - Runtime.getRuntime().freeMemory()) / (1024*1024) + " MB", 20, 50);
  }
  
  // Cajas de colisión
  void displayCollisionBoxes() {
    if (gameStateManager.getState() != STATE_GAME) return;
    
    noFill();
    strokeWeight(2);
    
    // Jugador
    stroke(255, 0, 0);
    if (game.player.isSliding) {
      // Hitbox al deslizarse
      ellipse(game.player.x, game.player.y + game.player.size/4, game.player.size * 1.2, game.player.size/2);
    } else {
      // Hitbox normal
      ellipse(game.player.x, game.player.y - game.player.size/2, game.player.size, game.player.size);
    }
    
    // Obstáculos
    stroke(0, 0, 255);
    for (Obstacle obstacle : game.obstacleManager.getObstacles()) {
      rect(obstacle.x - obstacle.w/2, obstacle.getTop(), obstacle.w, obstacle.getHeight());
    }
    
    // Coleccionables
    stroke(0, 255, 0);
    for (Collectible collectible : game.collectibleManager.getCollectibles()) {
      ellipse(collectible.x, collectible.y, collectible.size, collectible.size);
    }
  }
  
  // Debug del eco-sistema
  void displayEcoSystemDebug() {
    if (gameStateManager.getState() != STATE_GAME) return;
    
    EcoSystem eco = game.ecoSystem;
    
    fill(0, 150);
    rect(width - 200, 10, 190, 100);
    
    fill(255);
    textAlign(LEFT);
    textSize(12);
    text("Salud Eco: " + nf(eco.ecoHealth, 0, 1), width - 190, 30);
    text("Estado: " + getEcoStateName(eco), width - 190, 50);
    text("Contaminación: " + (eco.pollutionEffect ? "Sí (" + nf(eco.pollutionDensity, 0, 2) + ")" : "No"), width - 190, 70);
    text("Efecto Activo: " + (eco.hasActiveEffect ? eco.activeEffectName : "Ninguno"), width - 190, 90);
  }
  
  // Obtener nombre del estado del ecosistema
  String getEcoStateName(EcoSystem eco) {
    if (eco.isInGoodState()) return "BUENO";
    if (eco.isInWarningState()) return "ALERTA";
    if (eco.isInCriticalState()) return "CRÍTICO";
    return "NORMAL";
  }
  
  // Mostrar overlay de error en tiempo de ejecución (para errores graves)
  void displayErrorOverlay(String errorMessage) {
    pushStyle();
    // Fondo semi-transparente
    fill(0, 200);
    rect(0, 0, width, height);
    
    // Caja de error
    fill(40);
    stroke(255, 0, 0);
    strokeWeight(3);
    rect(width/2 - 250, height/2 - 100, 500, 200);
    
    // Título del error
    fill(255, 0, 0);
    textAlign(CENTER);
    textSize(24);
    text("Error en Ejecución", width/2, height/2 - 70);
    
    // Mensaje de error
    fill(255);
    textAlign(CENTER);
    textSize(16);
    text(errorMessage, width/2, height/2);
    
    // Instrucciones de recuperación
    fill(200);
    textSize(14);
    text("Presiona ESC para volver al menú principal", width/2, height/2 + 70);
    popStyle();
  }
  
  // Validación del estado del juego - comprobar si hay estado inconsistente
  void validateGameState() {
    if (gameStateManager.getState() != STATE_GAME) return;
    
    try {
      // Comprobar si el jugador está en un estado válido
      validatePlayerState();
      
      // Comprobar si el ecosistema está en un estado válido
      validateEcoSystemState();
      
      // Comprobar si los obstáculos están en un estado válido
      validateObstacles();
      
      // Comprobar si los coleccionables están en un estado válido
      validateCollectibles();
    } catch (Exception e) {
      logError("Falló la validación del estado del juego: " + e.getMessage());
    }
  }
  
  // Validar estado del jugador
  void validatePlayerState() {
    Player player = game.player;
    
    // Asegurar que la posición del jugador está dentro de límites razonables
    if (Float.isNaN(player.x) || Float.isNaN(player.y)) {
      logError("La posición del jugador contiene valores NaN");
      fixPlayerPosition();
    }
    
    // Asegurar que el jugador no está por debajo del nivel del suelo
    if (player.y > player.groundY + 50) {
      logWarning("Jugador por debajo del nivel del suelo, reposicionando");
      player.y = player.groundY;
    }
    
    // Comprobar valores de salud válidos
    if (player.health < 0 || player.health > 3) {
      logWarning("Salud de jugador inválida: " + player.health);
      player.health = constrain(player.health, 0, 3);
    }
    
    // Comprobar estado de salto inconsistente
    if (player.isJumping && player.y >= player.groundY) {
      logWarning("Estado de salto inconsistente, jugador en suelo pero isJumping = true");
      player.isJumping = false;
    }
  }
  
  // Validar estado del ecosistema
  void validateEcoSystemState() {
    EcoSystem eco = game.ecoSystem;
    
    // Asegurar que la salud está dentro de los límites
    if (eco.ecoHealth < eco.minEcoHealth || eco.ecoHealth > eco.maxEcoHealth) {
      logWarning("Salud del ecosistema fuera de límites: " + eco.ecoHealth);
      eco.ecoHealth = constrain(eco.ecoHealth, eco.minEcoHealth, eco.maxEcoHealth);
    }
    
    // Comprobar la consistencia de los indicadores de estado
    boolean goodState = eco.isInGoodState();
    boolean warningState = eco.isInWarningState();
    boolean criticalState = eco.isInCriticalState();
    
    // Solo un estado debe ser verdadero a la vez
    if ((goodState && warningState) || (goodState && criticalState) || (warningState && criticalState)) {
      logWarning("Indicadores de estado del ecosistema inconsistentes");
    }
  }
  
  // Validar obstáculos
  void validateObstacles() {
    // Buscar obstáculos inválidos
    ArrayList<Obstacle> obstacles = game.obstacleManager.getObstacles();
    for (int i = obstacles.size() - 1; i >= 0; i--) {
      Obstacle obstacle = obstacles.get(i);
      
      // Comprobar posición válida
      if (Float.isNaN(obstacle.x) || Float.isNaN(obstacle.y)) {
        logWarning("Obstáculo tiene posición NaN, eliminando");
        obstacles.remove(i);
        continue;
      }
      
      // Comprobar obstáculos fuera de pantalla
      if (obstacle.x < -500) {
        logWarning("Obstáculo muy lejos de la pantalla, eliminando");
        obstacles.remove(i);
      }
    }
  }
  
  // Validar coleccionables
  void validateCollectibles() {
    // Buscar coleccionables inválidos
    ArrayList<Collectible> collectibles = game.collectibleManager.getCollectibles();
    for (int i = collectibles.size() - 1; i >= 0; i--) {
      Collectible collectible = collectibles.get(i);
      
      // Comprobar posición válida
      if (Float.isNaN(collectible.x) || Float.isNaN(collectible.y)) {
        logWarning("Coleccionable tiene posición NaN, eliminando");
        collectibles.remove(i);
        continue;
      }
      
      // Comprobar coleccionables fuera de pantalla
      if (collectible.x < -500) {
        logWarning("Coleccionable muy lejos de la pantalla, eliminando");
        collectibles.remove(i);
      }
    }
  }
  
  // Métodos de recuperación de emergencia
  
  // Arreglar posición del jugador si es inválida
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
  
  // Mostrar visor de logs (para depuración en el juego)
  void showLogViewer() {
    pushStyle();
    // Fondo semi-transparente
    fill(0, 200);
    rect(0, 0, width, height);
    
    // Panel de logs
    fill(40);
    stroke(200);
    strokeWeight(2);
    float panelX = width/2 - 350;
    float panelY = height/2 - 200;
    float panelWidth = 700;
    float panelHeight = 400;
    rect(panelX, panelY, panelWidth, panelHeight);
    
    // Título
    fill(255);
    textAlign(CENTER);
    textSize(20);
    text("Log de Depuración", width/2, panelY + 30);
    
    // Calcular entradas totales y posición máxima de scroll
    int totalVisibleEntries = min(logEntriesPerPage, logEntries.size());
    int maxScrollPosition = max(0, logEntries.size() - logEntriesPerPage);
    
    // Limitar posición de scroll
    logScrollPosition = constrain(logScrollPosition, 0, maxScrollPosition);
    
    // Área de entradas de log con recorte
    pushMatrix();
    pushStyle();
    // Crear una región de recorte para las entradas de log
    float logAreaX = panelX + 10;
    float logAreaY = panelY + 60;
    float logAreaWidth = panelWidth - 40; // Dejar espacio para la barra de desplazamiento
    float logAreaHeight = panelHeight - 120;
    
    // Usar un rect de recorte para evitar que el texto se extienda fuera del panel
    clip(logAreaX, logAreaY, logAreaWidth, logAreaHeight);
    
    // Entradas de log
    textAlign(LEFT);
    textSize(12);
    int startIndex = logScrollPosition;
    int endIndex = min(startIndex + logEntriesPerPage, logEntries.size());
    
    float y = logAreaY;
    for (int i = startIndex; i < endIndex; i++) {
      LogEntry entry = logEntries.get(i);
      
      // Color según nivel de log
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
      
      // Formatear timestamp
      String timestamp = entry.getFormattedTimestamp();
      
      // Mostrar entrada de log con ajuste de palabras apropiado
      text(timestamp + " " + entry.getMessage(), logAreaX, y);
      y += 20;
    }
    
    // Finalizar recorte
    popStyle();
    popMatrix();
    
    // Dibujar barra de desplazamiento si es necesario
    if (logEntries.size() > logEntriesPerPage) {
      // Fondo de la barra de desplazamiento
      fill(60);
      float scrollbarX = panelX + panelWidth - 25;
      float scrollbarY = logAreaY;
      float scrollbarWidth = 15;
      float scrollbarHeight = logAreaHeight;
      rect(scrollbarX, scrollbarY, scrollbarWidth, scrollbarHeight);
      
      // Manejador de la barra de desplazamiento
      float handleHeight = (float)logEntriesPerPage / logEntries.size() * scrollbarHeight;
      handleHeight = max(20, handleHeight); // Tamaño mínimo del manejador
      
      float scrollRatio = (float)logScrollPosition / maxScrollPosition;
      float handleY = scrollbarY + scrollRatio * (scrollbarHeight - handleHeight);
      
      fill(150);
      rect(scrollbarX, handleY, scrollbarWidth, handleHeight);
    }
    
    // Instrucciones
    fill(200);
    textAlign(CENTER);
    textSize(14);
    text("Presiona ESC para cerrar | Re Pág/Av Pág para desplazarte | Rueda del ratón para desplazarte", width/2, panelY + panelHeight - 20);
    popStyle();
  }
  
  // Manejar entrada de teclado para el visor de logs
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
  
  // Manejar rueda del ratón para el visor de logs
  void handleLogViewerMouseWheel(int delta) {
    // delta es positivo cuando se desplaza hacia arriba, negativo cuando se desplaza hacia abajo
    logScrollPosition = constrain(logScrollPosition - delta, 0, max(0, logEntries.size() - logEntriesPerPage));
  }
  
  // Alternar visualizaciones de debug
  void toggleCollisionBoxes() {
    showCollisionBoxes = !showCollisionBoxes;
    logInfo("Cajas de colisión " + (showCollisionBoxes ? "activadas" : "desactivadas"));
  }
  
  void togglePerformanceMetrics() {
    showPerformanceMetrics = !showPerformanceMetrics;
    logInfo("Métricas de rendimiento " + (showPerformanceMetrics ? "activadas" : "desactivadas"));
  }
  
  void toggleEcoSystemDebug() {
    showEcoSystemDebug = !showEcoSystemDebug;
    logInfo("Debug del ecosistema " + (showEcoSystemDebug ? "activado" : "desactivado"));
  }
  
  void toggleValidation() {
    validationActive = !validationActive;
    logInfo("Validación del estado del juego " + (validationActive ? "activada" : "desactivada"));
  }
  
  // Establecer nivel de log
  void setLogLevel(int level) {
    currentLogLevel = constrain(level, LOG_ERROR, LOG_DEBUG);
    String[] levelNames = {"ERROR", "WARNING", "INFO", "DEBUG"};
    logInfo("Nivel de log establecido a " + levelNames[currentLogLevel]);
  }
  
  private String getTimestamp() {
    // Formatear marca de tiempo
    return nf(hour(), 2) + ":" + nf(minute(), 2) + ":" + nf(second(), 2);
  }
  
  String formatTimestamp(float millis) {
    // Formato: HH:MM:SS.mmm
    int hours = floor(millis / (1000 * 60 * 60));
    int minutes = floor((millis % (1000 * 60 * 60)) / (1000 * 60));
    int seconds = floor((millis % (1000 * 60)) / 1000);
    int ms = floor(millis % 1000);
    
    return nf(hours, 2) + ":" + nf(minutes, 2) + ":" + nf(seconds, 2) + "." + nf(ms, 3);
  }
}

// Estructura de datos para entradas de log
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
    // Formato: HH:MM:SS.mmm
    int seconds = (int)(timestamp / 1000) % 60;
    int minutes = (int)((timestamp / (1000 * 60)) % 60);
    int hours = (int)((timestamp / (1000 * 60 * 60)) % 24);
    int millis = (int)(timestamp % 1000);
    
    return String.format("%02d:%02d:%02d.%03d", hours, minutes, seconds, millis);
  }
} 