// EcoRunner - juego endless runner sobre cambio climático
// Versión 1.3

import java.util.Arrays;
import java.util.Collections;

class Game {
  // Objetos principales del juego
  Player player;
  EcoSystem ecoSystem;
  Weather weatherSystem;
  
  // Gestores del juego
  PlatformManager platformManager;
  ObstacleManager obstacleManager;
  CollectibleManager collectibleManager;
  ScoreManager scoreManager;
  GameStateManager gameStateManager;
  
  // Soporte de accesibilidad
  AccessibilityManager accessManager;
  
  // Soporte de sonido
  SoundManager soundManager;
  
  // Parámetros del juego
  float scrollSpeed = 5;
  float baseObstacleSpeed = 5;
  float obstacleSpeed;
  float groundLevel;
  float[] backgroundX = new float[2]; // desplazamiento continuo
  
  // Cámara
  float cameraY = 0;
  float targetCameraY = 0;
  float cameraLerpFactor = 0.05; // Factor de suavizado de la cámara
  
  // Dificultad
  int difficultyLevel = 1;
  int lastDifficultyIncrease = 0;
  int scoreDifficultyThreshold = 1000; // Puntos para aumentar
  
  // Sistema de ajuste dinámico de dificultad
  int playerDeathCount = 0;        // Contador de muertes
  int playerCollisionCount = 0;    // Contador de colisiones
  int consecutiveCollisions = 0;   // Colisiones consecutivas
  int consecutiveSuccesses = 0;    // Éxitos continuos
  float ddaMultiplier = 1.0;       // Multiplicador de dificultad
  int ddaAnalysisInterval = 1800;  // Intervalo para ajustar (30 segundos)
  int ddaTimer = 0;                // Contador de frames
  
  // Mensajes educativos
  int messageCooldown = 0;         // Contador de mensajes
  int messageInterval = 600;       // 10 segundos entre mensajes
  ArrayList<String> shownMessages = new ArrayList<String>(); // Historial
  int maxRepeatedMessages = 5;     // Máximo antes de reiniciar
  
  // Logros
  int consecutiveObstaclesAvoided = 0;
  int maxConsecutiveObstaclesAvoided = 0;
  
  // Interfaz y tutorial
  boolean showTutorial = true;
  int tutorialTimer = 0;
  int tutorialDuration = 300; // 5 segundos
  ArrayList<String> tutorialMessages = new ArrayList<String>();
  int currentTutorialMessage = 0;
  
  // Estado
  boolean gameOver = false;
  boolean gameStarted = false;
  
  // Sistema de acciones temporizadas
  ArrayList<TimedAction> timedActions = new ArrayList<TimedAction>();
  
  // Constructor predeterminado
  Game() {
    // Inicializar gestor de accesibilidad
    accessManager = new AccessibilityManager();
    // Inicializar gestor de estado del juego
    gameStateManager = new GameStateManager();
    // Inicializar gestor de sonido con gestor de accesibilidad
    soundManager = new SoundManager(accessManager);
    reset();
  }
  
  // Constructor con gestores externos accessManager y soundManager
  Game(AccessibilityManager accessManager, SoundManager soundManager) {
    // Usar los gestores proporcionados
    this.accessManager = accessManager;
    this.soundManager = soundManager;
    // Inicializar gestor de estado del juego
    gameStateManager = new GameStateManager();
    reset();
  }
  
  void reset() {
    try {
      println("Iniciando reinicio del juego...");
      
      // Configuración base
      groundLevel = height * 0.8;
      
      // Inicializar jugador con manejo de errores
      try {
        player = new Player(width * 0.2, groundLevel, accessManager, soundManager);
        println("Jugador inicializado con éxito");
      } catch (Exception e) {
        println("ERROR al inicializar jugador: " + e.getMessage());
        e.printStackTrace();
        // Crear un jugador por defecto si falla la creación
        player = new Player(width * 0.2, groundLevel, null, null);
      }
      
      // Inicializar EcoSystem con manejo de errores
      try {
        ecoSystem = new EcoSystem(accessManager);
        println("Ecosistema inicializado con éxito");
      } catch (Exception e) {
        println("ERROR al inicializar ecosistema: " + e.getMessage());
        e.printStackTrace();
        // Crear ecosistema por defecto
        ecoSystem = new EcoSystem(null);
      }
      
      // Inicializar Weather con manejo de errores
      try {
        weatherSystem = new Weather();
        println("Sistema de clima inicializado con éxito");
      } catch (Exception e) {
        println("ERROR al inicializar clima: " + e.getMessage());
        e.printStackTrace();
        // Crear clima por defecto
        weatherSystem = new Weather();
      }
      
      // Inicializar gestores con manejo de errores
      try {
        platformManager = new PlatformManager(groundLevel, baseObstacleSpeed, accessManager);
        println("Gestor de plataformas inicializado con éxito");
      } catch (Exception e) {
        println("ERROR al inicializar gestor de plataformas: " + e.getMessage());
        e.printStackTrace();
        // Crear gestor de plataformas por defecto
        platformManager = new PlatformManager(groundLevel, baseObstacleSpeed, null);
      }
      
      try {
        obstacleManager = new ObstacleManager(groundLevel, baseObstacleSpeed, ecoSystem);
        println("Gestor de obstáculos inicializado con éxito");
      } catch (Exception e) {
        println("ERROR al inicializar gestor de obstáculos: " + e.getMessage());
        e.printStackTrace();
        // Crear gestor de obstáculos por defecto
        obstacleManager = new ObstacleManager(groundLevel, baseObstacleSpeed, null);
      }
      
      // Conectar el ObstacleManager con el PlatformManager para evitar solapamientos
      try {
        platformManager.setObstacleManager(obstacleManager);
        println("Conexión entre gestores para evitar solapamientos establecida con éxito");
      } catch (Exception e) {
        println("ERROR al conectar gestores: " + e.getMessage());
        e.printStackTrace();
      }
      
      try {
        collectibleManager = new CollectibleManager(groundLevel, ecoSystem, accessManager);
        println("Gestor de coleccionables inicializado con éxito");
      } catch (Exception e) {
        println("ERROR al inicializar gestor de coleccionables: " + e.getMessage());
        e.printStackTrace();
        // Crear gestor de coleccionables por defecto
        collectibleManager = new CollectibleManager(groundLevel, null, null);
      }
      
      try {
        scoreManager = new ScoreManager();
        println("Gestor de puntuación inicializado con éxito");
      } catch (Exception e) {
        println("ERROR al inicializar gestor de puntuación: " + e.getMessage());
        e.printStackTrace();
        // Crear gestor de puntuación por defecto
        scoreManager = new ScoreManager();
      }
      
      // Cámara
      cameraY = 0;
      targetCameraY = 0;
      
      // Fondo
      backgroundX[0] = 0;
      backgroundX[1] = width;
      
      // Dificultad
      difficultyLevel = 1;
      lastDifficultyIncrease = 0;
      obstacleSpeed = baseObstacleSpeed;
      
      // Reiniciar sistema DDA
      resetDDASystem();
      
      // Mensajes
      messageCooldown = messageInterval / 2; // Primera aparición más rápida
      
      // Limpiar mensajes mostrados de forma segura
      try {
        shownMessages.clear();
      } catch (Exception e) {
        println("ERROR al limpiar mensajes mostrados: " + e.getMessage());
        e.printStackTrace();
        shownMessages = new ArrayList<String>();
      }
      
      // Tutorial
      try {
        setupTutorialMessages();
        showTutorial = true;
        tutorialTimer = 0;
        currentTutorialMessage = 0;
      } catch (Exception e) {
        println("ERROR al configurar mensajes de tutorial: " + e.getMessage());
        e.printStackTrace();
        // Crear un mensaje de tutorial por defecto
        tutorialMessages = new ArrayList<String>();
        tutorialMessages.add("¡Usa ESPACIO para SALTAR!");
      }
      
      consecutiveObstaclesAvoided = 0;
      
      gameOver = false;
      gameStarted = true;
      
      println("Reinicio del juego completado con éxito");
    } catch (Exception e) {
      println("ERROR CRÍTICO en reinicio del juego: " + e.getMessage());
      e.printStackTrace();
      
      // Respaldo de emergencia - crear estado mínimo del juego
      try {
        // Inicialización básica para prevenir excepciones de puntero nulo
        if (player == null) player = new Player(width * 0.2, height * 0.8, null, null);
        if (ecoSystem == null) ecoSystem = new EcoSystem(null);
        if (weatherSystem == null) weatherSystem = new Weather();
        if (platformManager == null) platformManager = new PlatformManager(height * 0.8, 5, null);
        if (obstacleManager == null) obstacleManager = new ObstacleManager(height * 0.8, 5, null);
        if (collectibleManager == null) collectibleManager = new CollectibleManager(height * 0.8, null, null);
        
        // Conectar gestores incluso en el respaldo de emergencia
        try {
          platformManager.setObstacleManager(obstacleManager);
        } catch (Exception connectionError) {
          println("ERROR al conectar gestores en respaldo de emergencia: " + connectionError.getMessage());
        }
        
        if (scoreManager == null) scoreManager = new ScoreManager();
        if (tutorialMessages == null) tutorialMessages = new ArrayList<String>();
        if (shownMessages == null) shownMessages = new ArrayList<String>();
        
        gameOver = false;
        gameStarted = true;
      } catch (Exception fallbackError) {
        println("ERROR FATAL: No se pudo crear respaldo de emergencia: " + fallbackError.getMessage());
        fallbackError.printStackTrace();
      }
    }
  }
  
  void setupTutorialMessages() {
    tutorialMessages = new ArrayList<String>();
    tutorialMessages.add("¡Usa ESPACIO para SALTAR entre plataformas!");
    tutorialMessages.add("¡Las plataformas VERDES tienen un REBOTE especial!");
    tutorialMessages.add("¡Usa S para DESLIZARTE y caer de las plataformas!");
    tutorialMessages.add("¡Recolecta objetos en plataformas para más PUNTOS!");
  }
  
  void resetDDASystem() {
    playerDeathCount = 0;
    playerCollisionCount = 0;
    consecutiveCollisions = 0;
    consecutiveSuccesses = 0;
    ddaMultiplier = 1.0;
    ddaTimer = 0;
  }
  
  void update() {
    if (gameOver || isPaused()) {
      // Incluso en Game Over, procesamos acciones temporizadas
      updateTimedActions();
      return;
    }
    
    try {
      // Actualizar eco-sistema
      ecoSystem.update();
      
      // Actualizar clima
      weatherSystem.update(ecoSystem);
      
      // Actualizar apariencia del jugador
      player.updateEnvironmentalAppearance(ecoSystem);
      
      // Aplicar efectos del clima
      applyWeatherEffectsToPlayer();
      
      // Actualizar jugador
      player.update();
      
      // Actualizar cámara para seguir al jugador
      updateCamera();
      
      // Fondo
      scrollBackground();
      
      // Actualizar plataformas
      platformManager.setObstacleSpeed(obstacleSpeed);
      platformManager.update();
      
      // Colisión de plataforma
      player.checkPlatformCollision(platformManager.getPlatforms());
      
      // Actualizar obstáculos
      obstacleManager.setObstacleSpeed(obstacleSpeed);
      obstacleManager.update();
      
      // Actualizar coleccionables
      collectibleManager.update(obstacleSpeed, platformManager.getPlatforms());
      
      // Comprobar colisiones
      checkCollisions();
      
      // Comprobar recolección
      collectibleManager.checkCollection(player);
      
      // Actualizar tutorial
      updateTutorial();
      
      // Actualizar puntuación
      scoreManager.update(player);
      
      // Actualizar dificultad
      updateDifficulty();
      
      // Actualizar sistema de ajuste dinámico de dificultad
      updateDDASystem();
      
      // Actualizar contador de mensajes
      if (messageCooldown > 0) {
        messageCooldown--;
      }
      
      // Aplicar consecuencias ambientales
      applyEnvironmentalConsequences();
      
      // Game over
      if (player.isDead()) {
        triggerGameOver();
      }
      
      // Validar estado
        validateGameState();
    } catch (Exception e) {
      println("ERROR en actualización del juego: " + e.getMessage());
        e.printStackTrace();
      }
    }
  
  void applyWeatherEffectsToPlayer() {
    // Aplicar efectos del clima al movimiento del jugador
    player.jumpForce = player.maxJumpForce * (1 + weatherSystem.getJumpModifier());
    player.speedMultiplier = 1.0 + weatherSystem.getSpeedModifier();
  }
  
  void updateCamera() {
    // Si el jugador está en una plataforma
    if (player.isOnPlatform && player.currentPlatform != null) {
      targetCameraY = max(0, player.currentPlatform.y - height * 0.6);
    } else {
      // Gradualmente volver la cámara al nivel del suelo cuando el jugador no está en plataforma
      targetCameraY = 0;
    }
    
    // Suavizar posición de la cámara con lerp
    cameraY = lerp(cameraY, targetCameraY, cameraLerpFactor);
  }
  
  void scrollBackground() {
    // Actualizar posiciones de fondo
    backgroundX[0] -= scrollSpeed * 0.5;
    backgroundX[1] -= scrollSpeed * 0.5;
    
    // Ciclar fondos para desplazamiento continuo
    if (backgroundX[0] <= -width) {
      backgroundX[0] = width;
    }
    if (backgroundX[1] <= -width) {
      backgroundX[1] = width;
    }
  }
  
  void checkCollisions() {
    // Comprobar colisión con obstáculos
    for (Obstacle obstacle : obstacleManager.getObstacles()) {
      if (obstacle.checkCollision(player)) {
        handleObstacleCollision(obstacle);
      }
    }
  }
  
  void handleObstacleCollision(Obstacle obstacle) {
    if (!player.isInvincible) {
      // Aplicar escudo si el jugador tiene uno
      if (player.hasShield) {
        player.deactivateShield();
        collectibleManager.addFloatingText("¡Escudo absorbió el impacto!", player.x, player.y - 40, color(100, 255, 100));
    } else {
        // Daño normal por colisión
        player.health -= obstacle.getDamage();
        player.isInvincible = true;
        player.invincibilityTimer = 0;
        playerCollisionCount++;
        consecutiveCollisions++;
        consecutiveSuccesses = 0;
        
        // Registrar colisión en el gestor de puntuación
        scoreManager.recordCollision();
        
        // Mostrar texto de daño
        collectibleManager.addFloatingText("-" + obstacle.getDamage(), player.x, player.y - 40, color(255, 0, 0));
      }
    }
  }
  
  void updateDifficulty() {
    // Aumentar dificultad basada en puntuación
    int currentScore = scoreManager.getScore();
    if (currentScore - lastDifficultyIncrease >= scoreDifficultyThreshold) {
      difficultyLevel++;
      lastDifficultyIncrease = currentScore;
      
      // Aumentar velocidad de obstáculos
      obstacleSpeed = baseObstacleSpeed + (difficultyLevel - 1) * 0.5;
      
      // Ajustar intervalo de obstáculos
      float newInterval = max(40, obstacleManager.obstacleInterval - 5);
      obstacleManager.obstacleInterval = newInterval;
      
      // Mostrar mensaje de aumento de dificultad
      collectibleManager.addFloatingText("¡Nivel " + difficultyLevel + "!", width/2, height/2 - 50, color(255, 200, 0));
    }
  }
  
  void updateDDASystem() {
    ddaTimer++;
    
    if (ddaTimer >= ddaAnalysisInterval) {
      // Analizar rendimiento del jugador y ajustar dificultad
      if (consecutiveCollisions > 3) {
        // Demasiado difícil, hacerlo más fácil
        ddaMultiplier = max(0.8, ddaMultiplier - 0.1);
        
        // Aplicar modificadores
        obstacleSpeed *= ddaMultiplier;
        
        // Asistencia secreta
        if (consecutiveCollisions > 5) {
          player.jumpForce *= 1.1; // Mejores saltos
          player.gravity *= 0.95;  // Caída más lenta
        }
      } else if (consecutiveSuccesses > 5) {
        // Demasiado fácil, hacerlo más difícil
        ddaMultiplier = min(1.2, ddaMultiplier + 0.1);
        
        // Aplicar modificadores
        obstacleSpeed *= ddaMultiplier;
        obstacleManager.obstacleInterval = max(obstacleManager.obstacleInterval - 5, 40);
      }
      
      // Reiniciar contadores
      ddaTimer = 0;
    }
  }
  
  void updateTutorial() {
    if (showTutorial) {
      tutorialTimer++;
      
      if (tutorialTimer >= tutorialDuration) {
        tutorialTimer = 0;
        currentTutorialMessage = (currentTutorialMessage + 1) % tutorialMessages.size();
        
        // Ocultar tutorial después de mostrar todos los mensajes
        if (currentTutorialMessage == 0) {
          showTutorial = false;
        }
      }
    }
  }
  
  void updateTimedActions() {
    // Procesar acciones temporizadas
    for (int i = timedActions.size() - 1; i >= 0; i--) {
      TimedAction action = timedActions.get(i);
      action.update();
      
      if (action.isComplete()) {
        action.execute();
        timedActions.remove(i);
      }
    }
  }
  
  void applyEnvironmentalConsequences() {
    // Aplicar efectos del estado del ecosistema en el gameplay
    float ecosystemHealth = 1.0 - ecoSystem.getPollutionLevel();
    
    if (ecosystemHealth < 0.3) {
      // Efectos de estado crítico
      if (frameCount % 300 == 0) { // Cada 5 segundos en estado crítico
        player.health = max(1, player.health - 1);
        collectibleManager.addFloatingText("¡Peligro! Aire tóxico", player.x, player.y - 40, color(255, 50, 0));
      }
      
      // Efectos visuales hechos en render
    } 
    else if (ecosystemHealth < 0.6) {
      // Efectos de estado de advertencia
      if (frameCount % 600 == 0) { // Cada 10 segundos en estado de advertencia
        collectibleManager.addFloatingText("Contaminación peligrosa", player.x, player.y - 40, color(255, 150, 0));
      }
    }
  }
  
  void triggerGameOver() {
    gameOver = true;
    playerDeathCount++;
    
    // Transición automática al estado de game over
    if (gameStateManager != null) {
      gameStateManager.setState(STATE_GAME_OVER);
      // Reproducir sonido de game over si está disponible
      if (soundManager != null) {
        soundManager.playGameOverSound();
      }
    }
  }
  
  void validateGameState() {
    // Verificación de consistencia
    if (player.health <= 0 && !gameOver) {
      triggerGameOver();
    }
  }
  
  void keyPressed() {
    // Manejar entrada de teclas específica del juego (como reiniciar)
    if (key == 'r' || key == 'R') {
      if (gameOver) {
        reset();
      }
    }
  }
  
  void mousePressed() {
    // Manejar entrada del ratón específica del juego
  }
  
  void display() {
    // Guardar transformación actual
    pushMatrix();
    
    // Aplicar transformación de cámara
    translate(0, -cameraY);
    
    // Dibujar fondo
    displayBackground();
    
    // Efectos de clima en capa de fondo
    weatherSystem.displayBackgroundEffects();
    
    // Dibujar plataformas
    displayPlatforms();
    
    // Dibujar coleccionables
    displayCollectibles();
    
    // Dibujar obstáculos
    displayObstacles();
    
    // Dibujar jugador
    player.display();
    
    // Efectos de clima en capa frontal
    weatherSystem.display();
    
    // Dibujar textos flotantes
    displayFloatingTexts();
    
    // Restaurar transformación
    popMatrix();
    
    // Dibujar elementos de UI (no afectados por la cámara)
    displayUI();
  }
  
  void displayBackground() {
    // Dibujar fondo desplazable
    PImage bg = getBackgroundImage();
    if (bg != null) {
      image(bg, backgroundX[0], 0, width, height);
      image(bg, backgroundX[1], 0, width, height);
    } else {
      // Fondo de respaldo cuando la imagen no está disponible
      fill(135, 206, 235); // Azul cielo
      rect(0, 0, width, groundLevel);
    }
    
    // Dibujar suelo
    displayGround();
  }
  
  PImage getBackgroundImage() {
    // Por ahora, devolveremos null pero lo manejaremos correctamente en displayBackground
    return null;
  }
  
  void displayGround() {
    // Dibujar suelo con apariencia apropiada al entorno
    fill(100, 70, 40);
    rect(0, groundLevel, width, height - groundLevel);
    
    // Opcional: Dibujar detalles del suelo
  }
  
  void displayPlatforms() {
    for (Platform platform : platformManager.getPlatforms()) {
      platform.display();
    }
  }
  
  void displayObstacles() {
    for (Obstacle obstacle : obstacleManager.getObstacles()) {
      obstacle.display();
    }
  }
  
  void displayCollectibles() {
    for (Collectible collectible : collectibleManager.getCollectibles()) {
      collectible.display();
    }
  }
  
  void displayFloatingTexts() {
    for (FloatingText text : collectibleManager.getFloatingTexts()) {
      text.display();
    }
  }
  
  void displayUI() {
    // Mostrar salud
    displayHealthBar();
    
    // Mostrar puntuación
    scoreManager.display();
    
    // Mostrar salud del ecosistema
    displayEcosystemStatus();
    
    // Mostrar power-ups activos
    displayActivePowerUps();
    
    // Mostrar tutorial si está activo
    if (showTutorial) {
      displayTutorial();
    }
  }
  
  void displayHealthBar() {
    // Dibujar corazones para representar la salud
    pushStyle();
    
    // Configuración para dibujar corazones
    int heartSize = 30;
    int heartSpacing = 10;
    int startX = 20;
    int startY = 20;
    
    // Color base para corazones llenos
    color heartColor = color(255, 0, 0);
    // Color para corazones vacíos
    color emptyHeartColor = color(100, 0, 0);
    
    // Dibujar fondo para el área de los corazones
    fill(0, 0, 0, 150);
    // rect(startX - 5, startY - 5, (heartSize + heartSpacing) * 3 + 5, heartSize + 10);
    
    // Dibujar corazones
    for (int i = 0; i < 3; i++) {
      // Posición del corazón actual
      int heartX = startX + i * (heartSize + heartSpacing);
      int heartY = startY;
      
      // Dibujar corazón lleno o vacío según la salud del jugador
      if (i < player.health) {
        // Corazón lleno
        fill(heartColor);
      } else {
        // Corazón vacío
        fill(emptyHeartColor);
      }
      
      // Dibujar corazón
      drawHeart(heartX, heartY, heartSize);
    }
    
    popStyle();
  }
  
  // Función para dibujar un corazón
  void drawHeart(int x, int y, int size) {
    // Dibuja un corazón centrado en (x, y) con tamaño 'size'
    pushMatrix();
    translate(x + size/2, y + size/2);
    
    beginShape();
    // Un corazón hecho con vértices
    vertex(0, size/4);
    bezierVertex(0, 0, -size/2, 0, -size/2, -size/4);
    bezierVertex(-size/2, -size/2, 0, -size/2, 0, -size/4);
    bezierVertex(0, -size/2, size/2, -size/2, size/2, -size/4);
    bezierVertex(size/2, 0, 0, 0, 0, size/4);
    endShape(CLOSE);
    
    popMatrix();
  }
  
  void displayEcosystemStatus() {
    // Barra de salud del ecosistema
    float ecosystemHealth = 1.0 - ecoSystem.getPollutionLevel();
    
    fill(0, 0, 0, 150);
    rect(20, 50, 150, 20);
    
    // Color basado en la salud del ecosistema
    if (ecosystemHealth > 0.6) {
      fill(0, 255, 0);
    } else if (ecosystemHealth > 0.3) {
      fill(255, 255, 0);
    } else {
      fill(255, 0, 0);
    }
    
    // Cantidad de barra del ecosistema llena
    float ecoWidth = map(ecosystemHealth, 0, 1, 0, 150);
    rect(20, 50, ecoWidth, 20);
    
    // Texto del ecosistema
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(12);
    text("ECOSISTEMA", 20 + 150/2, 50 + 10);
  }
  
  void displayTutorial() {
    // Caja de tutorial
    fill(0, 0, 0, 200);
    rect(width/2 - 200, height - 100, 400, 60);
    
    // Texto de tutorial
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(16);
    text(tutorialMessages.get(currentTutorialMessage), width/2, height - 70);
    
    // Puntos de progreso
    for (int i = 0; i < tutorialMessages.size(); i++) {
      if (i == currentTutorialMessage) {
        fill(255);
    } else {
        fill(150);
      }
      ellipse(width/2 - 30 + i * 20, height - 60, 8, 8);
    }
  }
  
  void displayActivePowerUps() {
    // Mostrar todos los power-ups activos
    for (PowerUp powerUp : collectibleManager.getActivePowerUps()) {
      powerUp.display();
    }
  }
  
  // Getters de puntuación para acceso externo
  int getScore() {
    return scoreManager.getScore();
  }
  
  int getHighScore() {
    return scoreManager.getHighScore();
  }
  
  boolean hasNewHighScore() {
    return scoreManager.hasNewHighScore();
  }
  
  // Métodos auxiliares para el estado del juego
  boolean isPaused() {
    // Comprobar si el juego está pausado
    return gameStateManager != null && gameStateManager.getState() == STATE_PAUSED;
  }
}

// Clase auxiliar para acciones programadas
class TimedAction {
  int delay;
  int counter = 0;
  Runnable action;
  
  TimedAction(int delay, Runnable action) {
    this.delay = delay;
    this.action = action;
  }
  
  void update() {
    counter++;
  }
  
  boolean isComplete() {
    return counter >= delay;
  }
  
  void execute() {
    action.run();
  }
} 