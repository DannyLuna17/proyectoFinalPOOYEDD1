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
  
  // Sistema de progresión del jugador para engagement a largo plazo
  PlayerProgression playerProgression;
  
  // Sistema de debug
  DebugSystem debugSystem;
  boolean showCollisionBoxes = false;  // Flag para mostrar cajas de colisión
  
  // Soporte de accesibilidad
  AccessibilityManager accessManager;
  
  // Soporte de sonido
  SoundManager soundManager;
  
  // Soporte de assets
  AssetManager assetManager;
  
  // Efectos visuales
  AvalancheEffect avalancheEffect;  // efecto visual de avalancha en segundo plano
  
  // Imagen de fondo
  PImage backgroundImage;
  PImage scaledBackground; // Imagen redimensionada
  float bgX = 0; // Posición de desplazamiento
  int scaledBgWidth; // Ancho redimensionado
  
  // Variables para transición nocturna
  PImage scaledNightBackground; // Imagen nocturna escalada
  int scoreForNightTransition = 500; // Puntaje para empezar la transición (ajustable!)
  float nightTransitionProgress = 0.0; // Progreso de la transición (0.0 a 1.0)
  float nightTransitionSpeed = 0.001; // Velocidad de la transición
  boolean nightTransitionStarted = false; // Si la transición ya empezó
  
  // Parámetros del juego
  float scrollSpeed = 5;
  float baseObstacleSpeed = 5;
  float obstacleSpeed;
  float groundLevel;
  float[] backgroundX = new float[2]; // desplazamiento continuo
  
  // Variables para progresión de velocidad
  float baseScrollSpeed = 5;           // Velocidad inicial de scroll del mundo
  float maxScrollSpeed = 12;           // Velocidad máxima de scroll que puede alcanzar
  float maxObstacleSpeedIncrease = 8;  // Incremento máximo para obstacleSpeed
  float speedProgressionRate = 0.02;   // Qué tan rápido aumenta la velocidad
  float currentSpeedMultiplier = 1.0;  // Multiplicador actual de velocidad
  
  // Distancia para progresión suave de velocidad
  float distanceForMaxSpeed = 3000;    // Distancia en unidades para alcanzar velocidad máxima
  
  // Cámara
  float cameraY = 0;
  float targetCameraY = 0;
  float cameraLerpFactor = 0.05; // Factor de suavizado de la cámara
  float cameraMaxDelta = 0.0;   // Máxima distancia de movimiento por frame
  
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
  Stack<String> shownMessages = new Stack<String>(); // Historial de mensajes usando una pila
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
  boolean tutorialShownInSession = false; // Variable para mantener el estado entre reinicios
  
  // Estado
  boolean gameOver = false;
  boolean gameStarted = false;
  
  // Tiempo de juego
  int playTimeFrames = 0;
  int playTimeSeconds = 0;
  
  // Datos del resumen de XP (para mostrar después del leaderboard)
  int lastRunXP = 0;
  float lastRunDistance = 0;
  int lastRunCollectibles = 0;
  int lastRunTimeSeconds = 0;
  float lastRunAvgEcoHealth = 0;
  boolean lastRunWasHit = false;
  float lastRunGoodEcoTime = 0;
  
  // Sistema de acciones temporizadas
  Stack<TimedAction> timedActions = new Stack<TimedAction>(); // Pila para acciones temporizadas - las últimas en añadirse se procesan primero
  
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
  
  // Constructor con gestores externos accessManager, soundManager y assetManager
  Game(AccessibilityManager accessManager, SoundManager soundManager, AssetManager assetManager) {
    // Usar los gestores proporcionados
    this.accessManager = accessManager;
    this.soundManager = soundManager;
    
    // Usar el gestor de assets
    this.assetManager = assetManager;
    
    // Inicializar gestor de estado del juego
    gameStateManager = new GameStateManager();
    reset();
  }
  
  void reset() {
    try {
      println("Iniciando reinicio del juego...");
      
      // Guardar estado del tutorial antes del reinicio
      boolean tutorialAlreadyShown = tutorialShownInSession;
      
      // Resetear tiempo de juego
      playTimeFrames = 0;
      playTimeSeconds = 0;
      
      // Configuración base
      groundLevel = height * 0.8;

      // Inicializar imagen de fondo optimizada (solo si no está ya inicializada)
      if (scaledBackground == null) {
        initBackground();
      }
      
      // Inicializar jugador con manejo de errores
      try {
        if (assetManager != null) {
          player = new Player(width * 0.2, groundLevel , accessManager, soundManager, assetManager);
        } else {
          player = new Player(width * 0.2, groundLevel, accessManager, soundManager);
        }
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
        if (ecoSystem != null) {
          weatherSystem = new Weather(assetManager);
        } else {
          // Modo de desarrollo - sin ecosistema
          weatherSystem = new Weather(assetManager);
        }
      } catch (Exception e) {
        println("Error inicializando sistema de clima: " + e.getMessage());
        weatherSystem = null;
      }
      
      // Inicializar efecto de avalancha
      try {
        if (assetManager != null) {
          avalancheEffect = new AvalancheEffect(assetManager, groundLevel, accessManager);
          println("Efecto de avalancha inicializado con éxito");
        } else {
          println("No se puede inicializar el efecto de avalancha: AssetManager no disponible");
          avalancheEffect = null;
        }
      } catch (Exception e) {
        println("ERROR al inicializar efecto de avalancha: " + e.getMessage());
        e.printStackTrace();
        avalancheEffect = null;
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
        if (assetManager != null) {
          obstacleManager = new ObstacleManager(groundLevel, baseObstacleSpeed, ecoSystem, assetManager);
        } else {
          obstacleManager = new ObstacleManager(groundLevel, baseObstacleSpeed, ecoSystem);
        }
        println("Gestor de obstáculos inicializado con éxito");
      } catch (Exception e) {
        println("ERROR al inicializar gestor de obstáculos: " + e.getMessage());
        e.printStackTrace();
        // Crear gestor de obstáculos por defecto
        if (assetManager != null) {
          obstacleManager = new ObstacleManager(groundLevel, baseObstacleSpeed, null, assetManager);
        } else {
          obstacleManager = new ObstacleManager(groundLevel, baseObstacleSpeed, null);
        }
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
        if (assetManager != null) {
          collectibleManager = new CollectibleManager(height * 0.8, obstacleSpeed, ecoSystem, accessManager, assetManager);
        } else {
          collectibleManager = new CollectibleManager(height * 0.8, obstacleSpeed, ecoSystem, accessManager);
        }
        
        // Establecer la referencia del CollectibleManager en el jugador
        player.setCollectibleManager(collectibleManager);
        
        println("Gestor de coleccionables inicializado con éxito");
      } catch (Exception e) {
        println("ERROR al inicializar gestor de coleccionables: " + e.getMessage());
        e.printStackTrace();
        // Crear gestor de coleccionables por defecto
        collectibleManager = new CollectibleManager(height * 0.8, obstacleSpeed, ecoSystem, accessManager);
        
        // Intentar establecer la referencia incluso en caso de error
        try {
          player.setCollectibleManager(collectibleManager);
        } catch (Exception refError) {
          println("ERROR al establecer referencia de collectibleManager: " + refError.getMessage());
        }
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
      
      // Inicializar sistema de progresión del jugador
      try {
        playerProgression = new PlayerProgression(accessManager);
        println("Sistema de progresión del jugador inicializado con éxito");
      } catch (Exception e) {
        println("ERROR al inicializar sistema de progresión: " + e.getMessage());
        e.printStackTrace();
        // Crear sistema de progresión por defecto
        playerProgression = new PlayerProgression();
      }
      
      // Conectar el sistema de progresión con el gestor de coleccionables para XP en tiempo real
      try {
        if (collectibleManager != null && playerProgression != null) {
          collectibleManager.setPlayerProgression(playerProgression);
          println("Sistema de progresión conectado con gestor de coleccionables para XP en tiempo real");
        }
      } catch (Exception e) {
        println("ERROR al conectar sistema de progresión con coleccionables: " + e.getMessage());
        e.printStackTrace();
      }
      
      // Cámara
      cameraY = 0;
      targetCameraY = 0;
      
      // Fondo
      backgroundX[0] = 0;
      backgroundX[1] = width;
      
      // Resetear variables de transición nocturna
      nightTransitionProgress = 0.0;
      nightTransitionStarted = false;
      
      // Dificultad
      difficultyLevel = 1;
      lastDifficultyIncrease = 0;
      obstacleSpeed = baseObstacleSpeed;
      
      // Reiniciar variables de progresión de velocidad
      scrollSpeed = baseScrollSpeed;
      currentSpeedMultiplier = 1.0;
      
      // Reiniciar sistema DDA
      resetDDASystem();
      
      // Mensajes
      messageCooldown = messageInterval / 2; // Primera aparición más rápida
      
      // Limpiar mensajes mostrados de forma segura
      try {
        shownMessages.clear();
      } catch (Exception e) {
        println("ERROR al limpiar mensajes mostrados: " + e.getMessage());
        shownMessages = new Stack<String>();
      }
      
      // Tutorial
      try {
        setupTutorialMessages();
        // Solo mostrar el tutorial si no se ha mostrado anteriormente en esta sesión
        showTutorial = !tutorialAlreadyShown;
        tutorialShownInSession = tutorialAlreadyShown; // Mantener el valor anterior
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
      
      // Inicializar sistema de debug
      try {
        debugSystem = new DebugSystem(gameStateManager, this);
        println("Sistema de debug inicializado con éxito");
      } catch (Exception e) {
        println("ERROR al inicializar sistema de debug: " + e.getMessage());
        e.printStackTrace();
      }
      
      println("Reinicio del juego completado con éxito");
    } catch (Exception e) {
      println("ERROR CRÍTICO en reinicio del juego: " + e.getMessage());
      e.printStackTrace();
      
      // Respaldo de emergencia - crear estado mínimo del juego
      try {
        // Inicialización básica para prevenir excepciones de puntero nulo
        if (player == null) {
          if (assetManager != null) {
            player = new Player(width * 0.2, height * 0.8, null, null, assetManager);
          } else {
            player = new Player(width * 0.2, height * 0.8, null, null);
          }
        }
        if (ecoSystem == null) ecoSystem = new EcoSystem(null);
        if (weatherSystem == null) weatherSystem = new Weather(assetManager);
        if (platformManager == null) platformManager = new PlatformManager(height * 0.8, 5, null);
        if (obstacleManager == null) {
          if (assetManager != null) {
            obstacleManager = new ObstacleManager(height * 0.8, 5, null, assetManager);
          } else {
            obstacleManager = new ObstacleManager(height * 0.8, 5, null);
          }
        }
        if (collectibleManager == null) {
          if (assetManager != null) {
            collectibleManager = new CollectibleManager(height * 0.8, obstacleSpeed, ecoSystem, accessManager, assetManager);
          } else {
            collectibleManager = new CollectibleManager(height * 0.8, obstacleSpeed, ecoSystem, accessManager);
          }
          
          // Establecer referencia en el respaldo de emergencia
          try {
            if (player != null && collectibleManager != null) {
              player.setCollectibleManager(collectibleManager);
            }
          } catch (Exception refError) {
            println("ERROR al establecer referencia en respaldo de emergencia: " + refError.getMessage());
          }
        }
        
        // Conectar gestores incluso en el respaldo de emergencia
        try {
          platformManager.setObstacleManager(obstacleManager);
        } catch (Exception connectionError) {
          println("ERROR al conectar gestores en respaldo de emergencia: " + connectionError.getMessage());
        }
        
        if (scoreManager == null) scoreManager = new ScoreManager();
        if (playerProgression == null) playerProgression = new PlayerProgression();
        if (tutorialMessages == null) tutorialMessages = new ArrayList<String>();
        if (shownMessages == null) shownMessages = new Stack<String>();
        
        // Conectar sistema de progresión con coleccionables incluso en respaldo de emergencia
        try {
          if (collectibleManager != null && playerProgression != null) {
            collectibleManager.setPlayerProgression(playerProgression);
          }
        } catch (Exception connectionError) {
          println("ERROR al conectar progresión con coleccionables en respaldo de emergencia: " + connectionError.getMessage());
        }
        
        gameOver = false;
        gameStarted = true;
      } catch (Exception fallbackError) {
        println("ERROR FATAL: No se pudo crear respaldo de emergencia: " + fallbackError.getMessage());
        fallbackError.printStackTrace();
      }
    }
  }
  
  // Método para inicializar el fondo de manera optimizada
  void initBackground() {
    try {
      // Usar el AssetManager si está disponible, de lo contrario cargar directamente
      if (assetManager != null) {
        // Obtener la imagen desde el AssetManager
        backgroundImage = assetManager.getBackgroundImage();
        
        // Escalar el fondo a través del AssetManager
        assetManager.scaleBackground(round(8000 * (height / 1920.0)), height);
        
        // Obtener la versión escalada
        scaledBackground = assetManager.getScaledBackground();
        
        // También obtener el fondo nocturno escalado
        scaledNightBackground = assetManager.getScaledNightBackground();
        
        // Guardar ancho escalado
        if (scaledBackground != null) {
          scaledBgWidth = scaledBackground.width;
          println("Fondo cargado desde AssetManager y escalado: " + scaledBgWidth + "x" + height);
        }
        
        // Verificar que el fondo nocturno también se cargó
        if (scaledNightBackground != null) {
          println("Fondo nocturno cargado y escalado correctamente");
        }
      } else {
        // Cargar la imagen original
        backgroundImage = loadImage("assets/fondo1.png");
        
        if (backgroundImage != null) {
          println("Cargando imagen de fondo...");
          
          // Reducir la resolución para mejor rendimiento
          float scale = height / 1920.0; // La altura original es 1920
          int targetWidth = round(8000 * scale); // El ancho original es 8000
          
          // Redimensionar la imagen original para usar menos memoria
          backgroundImage.resize(targetWidth, height);
          
          // Guardamos el ancho para cálculos de desplazamiento
          scaledBgWidth = targetWidth;
          
          // Asignamos directamente sin crear una nueva imagen
          scaledBackground = backgroundImage;
          
          println("Imagen de fondo optimizada correctamente: " + targetWidth + "x" + height);
        } else {
          println("No se pudo cargar la imagen de fondo");
        }
      }
    } catch (Exception e) {
      println("ERROR al optimizar la imagen de fondo: " + e.getMessage());
      e.printStackTrace();
      // En caso de error, intentamos crear un fondo simple
      try {
        scaledBackground = createImage(width*2, height, RGB);
        scaledBackground.loadPixels();
        // Llenar con color de cielo
        for (int i = 0; i < scaledBackground.pixels.length; i++) {
          scaledBackground.pixels[i] = color(135, 206, 235);
        }
        scaledBackground.updatePixels();
        scaledBgWidth = width*2;
        println("Creado fondo alternativo por error en carga de imagen");
      } catch (Exception ex) {
        println("ERROR al crear fondo alternativo: " + ex.getMessage());
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
    
    // Actualizar tiempo de juego si el juego está activo
    if (gameStarted && !gameOver) {
      playTimeFrames++;
      if (playTimeFrames % 60 == 0) {
        playTimeSeconds++;
      }
    }
    
    try {
      // Actualizar eco-sistema
      ecoSystem.update();
      
      // Actualizar clima
      weatherSystem.update(ecoSystem);
      
      // Actualizar apariencia del jugador
      player.updateEnvironmentalAppearance(ecoSystem);
      
      // Actualizar efecto de avalancha
      if (avalancheEffect != null) {
        avalancheEffect.update();
      }
      
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
      
      // Actualizar progresión de velocidad basada en distancia
      updateSpeedProgression();
      
      // Actualizar sistema de ajuste dinámico de dificultad
      updateDDASystem();
      
      // Actualizar sistema de progresión del jugador
      if (playerProgression != null) {
        playerProgression.update();
        
        // Actualizar estadísticas de la partida actual
        float distanceTraveled = (float)playTimeSeconds * (scrollSpeed + obstacleSpeed) / 10.0; // Aproximación de distancia
        playerProgression.updateRunStats(
          distanceTraveled,
          scoreManager.collectiblesCollected,
          playTimeSeconds,
          ecoSystem.ecoHealth,
          player.health < 3 // Si el jugador ha perdido vida, significa que fue golpeado
        );
      }
      
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
      
      // Actualizar sistema de debug si las cajas de colisión están activas
      if (debugSystem != null && showCollisionBoxes) {
        debugSystem.update();
      }
    } catch (Exception e) {
      println("ERROR en actualización del juego: " + e.getMessage());
      e.printStackTrace();
    }
  }
  
  void applyWeatherEffectsToPlayer() {
    // Aplicar efectos del clima al movimiento del jugador de forma más eficiente
    // Los modificadores del clima ahora actúan como multiplicadores, no reemplazos absolutos
    
    // Obtener modificadores del sistema de clima
    float jumpModifier = weatherSystem.getJumpModifier();
    float speedModifier = weatherSystem.getSpeedModifier();
    
    // Guardar los valores originales si no están guardados (primera vez)
    if (!player.hasWeatherEffectsApplied) {
      player.originalJumpForce = player.jumpForce;
      player.originalMaxJumpForce = player.maxJumpForce;
      player.originalGravity = player.gravity;
      player.hasWeatherEffectsApplied = true;
    }
    
    // Aplicar modificadores del clima a ambos valores de salto manteniendo su relación
    player.jumpForce = player.originalJumpForce * (1 + jumpModifier);
    player.maxJumpForce = player.originalMaxJumpForce * (1 + jumpModifier);
    
    // Aplicar modificador de velocidad como antes
    player.speedMultiplier = 1.0 + speedModifier;
  }
  
  void updateCamera() {
    // Si el jugador está en una plataforma
    if (player.isOnPlatform && player.currentPlatform != null) {
      targetCameraY = max(0, player.currentPlatform.y - height * 0.6);
    } else {
      // Gradualmente volver la cámara al nivel del suelo cuando el jugador no está en plataforma
      targetCameraY = 0;
    }
    
    // Calcular la distancia actual a la posición objetivo
    float cameraDistance = abs(targetCameraY - cameraY);
    
    // Usar lerp adaptativo: más rápido para distancias grandes, más suave para ajustes pequeños
    float adaptiveLerpFactor = min(0.2, cameraLerpFactor * (1 + cameraDistance * 0.01));
    
    // Aplicar el lerp con el factor adaptativo
    float newCameraY = lerp(cameraY, targetCameraY, adaptiveLerpFactor);
    
    // Limitar el cambio máximo de posición de la cámara por frame
    float deltaY = newCameraY - cameraY;
    if (abs(deltaY) > cameraMaxDelta) {
      deltaY = cameraMaxDelta * (deltaY > 0 ? 1 : -1);
      newCameraY = cameraY + deltaY;
    }
    
    cameraY = newCameraY;
  }
  
  void scrollBackground() {
    // Actualizar posición de desplazamiento
    bgX = (bgX + scrollSpeed * 0.5) % scaledBgWidth;
  }
  
  void checkCollisions() {
    // Comprobar colisión con obstáculos
    for (Obstacle obstacle : obstacleManager.getObstacles()) {
      // Actualizar las nubes tóxicas con la referencia al jugador
      if (obstacle instanceof ToxicCloudObstacle) {
        // Pasar la referencia al jugador para que la nube lo siga
        ToxicCloudObstacle toxicCloud = (ToxicCloudObstacle) obstacle;
        toxicCloud.setTargetPlayer(player);
      }
      
      if (obstacle.checkCollision(player)) {
        handleObstacleCollision(obstacle);
      }
    }
  }
  
  void handleObstacleCollision(Obstacle obstacle) {
    if (!player.isInvincible) {
      // Aplicar escudo si el jugador tiene uno
      if (player.hasShield) {
        // El escudo absorbe completamente el daño
        player.deactivateShield();
        // Activar invencibilidad temporal para que el jugador pueda salir del obstáculo
        player.isInvincible = true;
        player.invincibilityTimer = 0;
        collectibleManager.addFloatingText("¡Escudo absorbió el impacto!", player.x, player.y - 40, color(100, 255, 100));
        // No hay daño cuando hay escudo activo
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
      
      // Limitar el nivel máximo de dificultad para evitar que el juego sea imposible
      int maxDifficultyLevel = 15;
      if (difficultyLevel > maxDifficultyLevel) {
        difficultyLevel = maxDifficultyLevel;
      }
      
      // Calcular factor de dificultad con una curva logarítmica para suavizar el aumento
      // Esto hará que la dificultad aumente más rápido al principio y más lento en niveles altos
      float difficultyFactor = log(difficultyLevel + 1) / log(maxDifficultyLevel + 1);
      
      // Aumentar velocidad de obstáculos de forma más gradual
      obstacleSpeed = baseObstacleSpeed + 3.0 * difficultyFactor;
      
      // Ajustar intervalo de obstáculos con un mínimo más alto para garantizar espacio entre obstáculos
      // A medida que aumenta la velocidad, también aumentamos el intervalo mínimo para dar tiempo de reacción
      float minInterval = 60 + (difficultyLevel * 2); // Intervalo mínimo aumenta con la dificultad
      float newInterval = max(minInterval, obstacleManager.obstacleInterval - 3);
      obstacleManager.obstacleInterval = newInterval;
      
      // Comunicar nivel de dificultad al gestor de obstáculos
      obstacleManager.setScoreBasedDifficultyLevel(difficultyLevel);
      
      // Mostrar mensaje de aumento de dificultad
      collectibleManager.addFloatingText("¡Nivel " + difficultyLevel + "!", width/2, height/2 - 50, color(255, 200, 0));
    }
  }
  
  // Método para manejar el aumento progresivo de velocidad del juego
  void updateSpeedProgression() {
    // Calcular la distancia total recorrida basada en el tiempo y velocidad actual
    float currentDistance = (float)playTimeSeconds * (scrollSpeed + obstacleSpeed) / 10.0;
    
    // Calcular el progreso de velocidad usando una curva suave
    float progressRatio = min(currentDistance / distanceForMaxSpeed, 1.0);
    
    // Usa una curva de aceleración suave
    float smoothProgress = (sin((progressRatio * PI) - (PI/2)) + 1) / 2;
    
    // Actualizar el multiplicador de velocidad
    currentSpeedMultiplier = 1.0 + (smoothProgress * speedProgressionRate * currentDistance / 100);
    
    // Aplica el aumento progresivo a la velocidad de scroll
    float newScrollSpeed = baseScrollSpeed + (maxScrollSpeed - baseScrollSpeed) * smoothProgress;
    scrollSpeed = newScrollSpeed;
    
    // También aplicar un aumento adicional a la velocidad de obstáculos
    float additionalObstacleSpeed = maxObstacleSpeedIncrease * smoothProgress;
    
    // Combina con el sistema de dificultad existente
    float baseDifficultySpeed = baseObstacleSpeed;
    if (difficultyLevel > 1) {
      int maxDifficultyLevel = 15;
      float difficultyFactor = log(difficultyLevel + 1) / log(maxDifficultyLevel + 1);
      baseDifficultySpeed = baseObstacleSpeed + 3.0 * difficultyFactor;
    }
    
    // La velocidad final de obstáculos combina dificultad por puntos + progresión por distancia
    obstacleSpeed = baseDifficultySpeed + additionalObstacleSpeed;
    
    // Mostrar mensaje visual ocasional sobre el aumento de velocidad
    if (currentDistance > 0 && ((int)currentDistance) % 500 == 0 && frameCount % 60 == 0) {
      if (smoothProgress > 0.1) {
        collectibleManager.addFloatingText("¡Velocidad aumentando!", player.x + 100, player.y - 80, color(100, 255, 200));
      }
    }
  }
  
  void updateDDASystem() {
    ddaTimer++;
    
    if (ddaTimer >= ddaAnalysisInterval) {
      // Guardar las velocidades base antes de aplicar modificadores 
      float currentBaseObstacleSpeed = obstacleSpeed;
      
      // Analizar rendimiento del jugador y ajustar dificultad
      if (consecutiveCollisions > 3) {
        // Demasiado difícil, hacerlo más fácil
        ddaMultiplier = max(0.75, ddaMultiplier - 0.15);
        
        // Aplicar modificadores para no interferir con progresión
        obstacleSpeed = currentBaseObstacleSpeed * ddaMultiplier;
        
        // Aumentar el intervalo entre obstáculos para dar más respiro al jugador
        obstacleManager.obstacleInterval = min(obstacleManager.obstacleInterval + 15, 180);
        
        if (consecutiveCollisions > 5) {
          
          // Crear un boost temporal de salto más efectivo pero que preserve la mecánica original
          float tempJumpBoost = 1.1;  // 10% más de potencia de salto temporalmente
          float tempGravityReduction = 0.95;  // 5% menos de gravedad temporalmente
          
          // Aplicar los modificadores de manera segura a través de los valores originales
          if (player.hasWeatherEffectsApplied) {
            player.jumpForce = player.originalJumpForce * tempJumpBoost * (1 + weatherSystem.getJumpModifier());
            player.maxJumpForce = player.originalMaxJumpForce * tempJumpBoost * (1 + weatherSystem.getJumpModifier());
            player.gravity = player.originalGravity * tempGravityReduction;
          } else {
            // Si no hay efectos climáticos, aplicar directamente pero de forma temporal
            player.jumpForce *= tempJumpBoost;
            player.maxJumpForce *= tempJumpBoost;
            player.gravity *= tempGravityReduction;
          }
          
          // Añadir mensaje sutil de asistencia
          collectibleManager.addFloatingText("¡Viento a favor!", player.x, player.y - 60, color(100, 200, 255));
        }
      } else if (consecutiveSuccesses > 5) {
        // Demasiado fácil, hacerlo más difícil
        ddaMultiplier = min(1.15, ddaMultiplier + 0.05);
        
        // Aplicar modificadores 
        obstacleSpeed = currentBaseObstacleSpeed * ddaMultiplier;
        
        // Reducir el intervalo con un límite más conservador según el nivel de dificultad
        float minIntervalBasedOnDifficulty = 60 + (difficultyLevel * 1.5);
        obstacleManager.obstacleInterval = max(obstacleManager.obstacleInterval - 5, minIntervalBasedOnDifficulty);
      }
      
      // Reiniciar contadores
      ddaTimer = 0;
      
      // Suavizar reinicio de contadores para evitar cambios bruscos
      if (consecutiveCollisions > 0) consecutiveCollisions--;
      if (consecutiveSuccesses > 0) consecutiveSuccesses--;
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
          // Marcar que el tutorial ya se mostró en esta sesión
          tutorialShownInSession = true;
        }
      }
    }
  }
  
  void updateTimedActions() {
    // Procesar acciones temporizadas usando la pila (LIFO - las últimas añadidas se procesan primero)
    Stack<TimedAction> tempStack = new Stack<TimedAction>(); // Pila temporal para mantener las acciones que no están completas
    
    // Procesar todas las acciones de la pila principal
    while (!timedActions.isEmpty()) {
      TimedAction action = timedActions.pop(); // Sacar la acción más reciente
      action.update();
      
      if (action.isComplete()) {
        action.execute(); // Ejecutar la acción si está completa
      } else {
        tempStack.push(action); // Guardar en pila temporal si no está completa
      }
    }
    
    // Restaurar las acciones no completadas a la pila principal
    while (!tempStack.isEmpty()) {
      timedActions.push(tempStack.pop());
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
    
    // Guardar datos del resumen de XP ANTES de calcular y resetear
    if (playerProgression != null) {
      lastRunDistance = playerProgression.distanceTraveled;
      lastRunCollectibles = playerProgression.collectiblesGathered;
      lastRunTimeSeconds = playerProgression.timeInSeconds;
      lastRunAvgEcoHealth = playerProgression.avgEcosystemHealth;
      lastRunWasHit = playerProgression.wasHitDuringRun;
      lastRunGoodEcoTime = playerProgression.timeInGoodEcoState;
      
      // Ahora calcular y otorgar XP al final de la partida
      int xpEarned = playerProgression.calculateEndOfRunXP();
      
      // Usar el XP total calculado (incluye todo el XP de la partida)
      lastRunXP = xpEarned;
      
      // Guardar la progresión después de cada partida
      playerProgression.saveProgression();
      
    }
    
    // Transición automática al estado de game over
    if (gameStateManager != null) {
      // Verificar si hay una puntuación suficiente para entrar en la tabla
      if (scoreManager.getScore() > 0) {
        // Cambiar al estado de entrada de nombre
        gameStateManager.setState(STATE_NAME_INPUT);
      } else {
        // Si no hay puntuación, ir directo a game over
        gameStateManager.setState(STATE_GAME_OVER);
      }
      
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
    
    // Activar/desactivar cajas de colisión directamente con la tecla "1"
    if (key == '1') {
      toggleCollisionBoxes();
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
    
    // Dibujar efecto de avalancha (detrás de todos los elementos del juego)
    displayAvalancheEffect();
    
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
    
    // Mostrar información de debug si las cajas de colisión están activas
    if (debugSystem != null && showCollisionBoxes) {
      debugSystem.display();
    }
  }
  
  void displayBackground() {
    // Chequear si debemos empezar la transición nocturna
    if (!nightTransitionStarted && scoreManager.getScore() >= scoreForNightTransition) {
      nightTransitionStarted = true;
      collectibleManager.addFloatingText("¡La noche se acerca!", width/2, height/2, color(150, 150, 255));
    }
    
    // Actualizar el progreso de la transición si ya empezó
    if (nightTransitionStarted && nightTransitionProgress < 1.0) {
      nightTransitionProgress += nightTransitionSpeed;
      nightTransitionProgress = constrain(nightTransitionProgress, 0.0, 1.0);
    }
    
    // Dibujar fondo desplazable con transición
    if (scaledBackground != null) {
      // Primero dibujamos el fondo normal (de día)
      if (nightTransitionProgress < 1.0) {
        // Solo dibujamos las partes visibles de la imagen
        int visibleWidth = min(width, scaledBgWidth - int(bgX));
        
        if (visibleWidth > 0) {
          copy(scaledBackground, 
               int(bgX), 0, visibleWidth, height, 
               0, 0, visibleWidth, height);
        }
        
        // Si necesitamos mostrar más contenido (cuando la posición está cerca del final)
        if (visibleWidth < width) {
          copy(scaledBackground, 
               0, 0, width - visibleWidth, height, 
               visibleWidth, 0, width - visibleWidth, height);
        }
      }
      
      // Ahora dibujamos el fondo nocturno con transición
      if (nightTransitionProgress > 0.0 && scaledNightBackground != null) {
        // Calculamos cuánto del fondo nocturno mostrar (de derecha a izquierda)
        int nightWidth = int(width * nightTransitionProgress);
        int nightStartX = width - nightWidth;
        
        // Usamos tint para hacer una transición más suave
        pushStyle();
        tint(255); // Sin transparencia, queremos el efecto de "barrido"
        
        // Dibujamos la porción nocturna del fondo
        // Necesitamos calcular qué parte del fondo nocturno mostrar considerando el scroll
        int srcX = int(bgX + nightStartX) % scaledBgWidth;
        int srcWidth = nightWidth;
        
        // Si la sección cruza el borde de la imagen, la dividimos
        if (srcX + srcWidth > scaledBgWidth) {
          // Primera parte (final de la imagen)
          int firstPartWidth = scaledBgWidth - srcX;
          copy(scaledNightBackground,
               srcX, 0, firstPartWidth, height,
               nightStartX, 0, firstPartWidth, height);
          
          // Segunda parte (inicio de la imagen)
          int secondPartWidth = srcWidth - firstPartWidth;
          copy(scaledNightBackground,
               0, 0, secondPartWidth, height,
               nightStartX + firstPartWidth, 0, secondPartWidth, height);
        } else {
          // La sección no cruza el borde, copiar directamente
          copy(scaledNightBackground,
               srcX, 0, srcWidth, height,
               nightStartX, 0, srcWidth, height);
        }
        
        // Dibujamos una línea suave de transición entre día y noche
        // pa' que se vea más cool el cambio
        for (int i = 0; i < 20; i++) {
          float alpha = map(i, 0, 19, 100, 0);
          stroke(150, 150, 200, alpha);
          line(nightStartX - i, 0, nightStartX - i, height);
        }
        
        popStyle();
      }
    } else {
      // Fondo de respaldo cuando la imagen no está disponible
      fill(135, 206, 235); // Azul cielo
      rect(0, 0, width, groundLevel);
    }
    
    // Dibujar suelo
    displayGround();
  }
  
  PImage getBackgroundImage() {
    // Ya no necesitamos cargar la imagen cada vez
    return scaledBackground;
  }
  
  void displayGround() {
    // Dibujar suelo usando la imagen de piso
    PImage pisoImg = assetManager.getFloorImage();
    if (pisoImg != null) {
      // Calcular cuántas veces necesitamos repetir la imagen para cubrir el ancho de la pantalla
      // Añadimos un tile extra para evitar brechas en los bordes
      int numTiles = ceil(width / (float)pisoImg.width) + 2;
      
      // Desplazamiento para efecto de movimiento
      int offsetX = (int)(bgX % pisoImg.width);
      
      // Ajuste final: Fheartposicionamos la imagen para que el césped coincida exactamente con groundLevel
      float pisoY = groundLevel + 150;
      
      // Altura suficiente para cubrir toda la pantalla más extra
      int floorHeight = height - (int)pisoY + 230;
      
      // Superposición entre baldosas para evitar brechas visibles
      // Esto asegura una transición perfecta entre tiles
      float overlapAmount = 1.5; // Cantidad de píxeles de superposición
      
      // Comenzamos un tile antes para manejar el desplazamiento
      // Esto evita espacios vacíos en el borde izquierdo cuando la imagen se desplaza
      for (int i = -1; i < numTiles; i++) {
        // Dibujar la imagen del piso con un ligero solapamiento
        // Aumentamos ligeramente el ancho para evitar las líneas entre tiles
        image(pisoImg, 
              i * (pisoImg.width - overlapAmount) - offsetX, pisoY, 
              pisoImg.width + overlapAmount, floorHeight);
      }
    } else {
      // Como respaldo, usar el rectángulo si la imagen no está disponible
      fill(100, 70, 40);
      rect(0, groundLevel, width, height - groundLevel + 300);
    }
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
    // Usar el método del CollectibleManager para mostrar textos flotantes
    collectibleManager.displayFloatingTexts();
  }
  
  void displayAvalancheEffect() {
    // Dibujar el efecto de avalancha si está disponible
    if (avalancheEffect != null) {
      avalancheEffect.display();
    }
  }
  
  void displayUI() {
    // Mostrar salud
    displayHealthBar();
    
    // Mostrar sistema de progresión del jugador
    if (playerProgression != null) {
      playerProgression.display();
    }
    
    // Mostrar puntuación
    scoreManager.display();
    
    // Mostrar salud del ecosistema
    displayEcosystemStatus();
    
    // Mostrar cronómetro del juego junto a la barra del ecosistema
    displayGameTimer();
    
    // Mostrar power-ups activos
    displayActivePowerUps();
    
    // Mostrar tutorial si está activo
    if (showTutorial) {
      displayTutorial();
    }
    
    // Mostrar framerate en esquina superior izquierda
    displayFramerate();
  }
  
  // Mostrar la barra de salud con todos los corazones del jugador
  // Ahora muestra hasta 5 corazones visibles, y si el jugador tiene más,
  // se indica con un número como "+2". Así podemos ver todas las vidas extra
  // que conseguimos al recoger corazones durante el juego.
  void displayHealthBar() {
    // Dibujar corazones para representar la salud
    pushStyle();
    
    // Configuración para dibujar corazones
    int heartSize = 65;         
    int heartSpacing = 20;      
    int startX = 35;            
    int startY = 35;            
    int panelPadding = 20;      
    float cornerRadius = 12;    
    
    // Color base para corazones llenos 
    color heartColor = color(255, 50, 50);
    // Color para corazones vacíos 
    color emptyHeartColor = color(80, 80, 80);
    // Color del borde negro para todos los corazones
    color outlineColor = color(0);
    
    // Configurar el número máximo de corazones a mostrar en pantalla
    int maxVisibleHearts = 3; // Máximo de corazones visibles
    
    // Determinar cuántos corazones mostrar en total y cuántos están llenos/vacíos
    int totalHeartsToShow;
    int filledHearts;
    int emptyHearts;
    boolean showMoreIndicator = player.health > maxVisibleHearts;
    
    if (player.health <= maxVisibleHearts) {
      // Si el jugador tiene 5 o menos corazones, mostrar siempre 5 en total
      totalHeartsToShow = maxVisibleHearts;
      filledHearts = player.health;
      emptyHearts = maxVisibleHearts - player.health;
    } else {
      // Si tiene más de 5, mostrar solo 5 llenos y usar el indicador "+X"
      totalHeartsToShow = maxVisibleHearts;
      filledHearts = maxVisibleHearts;
      emptyHearts = 0;
    }
    
    // Calcular dimensiones del panel
    int panelWidth = (heartSize + heartSpacing) * totalHeartsToShow + panelPadding * 2;
    int panelHeight = heartSize + panelPadding * 2;
    
    // Añadir espacio para el indicador "+X" si es necesario
    if (showMoreIndicator) panelWidth += 60; 
    
    // Dibujar corazones llenos primero (los que representan la vida actual)
    for (int i = 0; i < filledHearts; i++) {
      // Posición del corazón actual
      int heartX = startX + i * (heartSize + heartSpacing);
      int heartY = startY;
      
      // Dibujar corazón lleno con borde negro
      drawHeart(heartX, heartY, heartSize, heartColor, outlineColor, true);
    }
    
    // Dibujar corazones vacíos después (para mostrar la vida perdida)
    for (int i = 0; i < emptyHearts; i++) {
      // Posición del corazón vacío (continúa después de los llenos)
      int heartX = startX + (filledHearts + i) * (heartSize + heartSpacing);
      int heartY = startY;
      
      // Dibujar corazón vacío con borde negro pero sin relleno
      drawHeart(heartX, heartY, heartSize, emptyHeartColor, outlineColor, false);
    }
    
    // Si hay más corazones de los que podemos mostrar, añadir un indicador más grande
    if (showMoreIndicator) {
      textAlign(LEFT, CENTER);
      fill(0);
      textSize(40); 
      text("+" + (player.health - maxVisibleHearts), 
           startX + (heartSize + heartSpacing) * maxVisibleHearts, 
           startY + heartSize/3);
    }
    
    popStyle();
    
  }
  
  // Función para dibujar un corazón con opciones de relleno y borde
  void drawHeart(int x, int y, int size, color fillColor, color borderColor, boolean filled) {
    // Dibuja un corazón centrado en (x, y) con tamaño 'size'
    pushMatrix();
    translate(x + size/2, y + size/2);
    
    // Configurar el borde negro primero
    stroke(borderColor);
    strokeWeight(2.5); 
    
    if (filled) {
      // Corazón lleno - usar el color de relleno especificado
      fill(fillColor);
    } else {
      // Corazón vacío - mostrar relleno gris claro
      fill(150, 150, 150);
    }
    
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
    // Variables para una UI más consistente y accesible
    int barWidth = 450;        
    int barHeight = 60;        
    int topPosition = 25;      
    float cornerRadius = 15;   
    int iconSize = 40;        
    
    // Calcular posición central
    int centerX = width / 2 - barWidth / 2;
    
    // Barra de salud del ecosistema
    float ecosystemHealth = 1.0 - ecoSystem.getPollutionLevel();
    
    // Fondo oscuro para la barra
    fill(0, 0, 0, 200);
    rect(centerX, topPosition, barWidth, barHeight, cornerRadius);
    
    // Color basado en la salud del ecosistema
    if (ecosystemHealth > 0.6) {
      fill(0, 255, 80); 
    } else if (ecosystemHealth > 0.3) {
      fill(255, 230, 0); 
    } else {
      fill(255, 60, 60); 
    }
    
    // Cantidad de barra del ecosistema llena
    float ecoWidth = map(ecosystemHealth, 0, 1, 0, barWidth - 4);
    if (ecoWidth > 0) {
      float rightRadius = min(cornerRadius - 2, ecoWidth / 2);
      if (ecoWidth < barWidth - 4) {
        rect(centerX + 2, topPosition + 2, ecoWidth, barHeight - 4, 0, rightRadius, rightRadius, 0);
      } else {
        rect(centerX + 2, topPosition + 2, ecoWidth, barHeight - 4, cornerRadius - 2);
      }
    }
    
    // Texto del ecosistema
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(28); 
    
    // Añadir icono o símbolo antes del texto
    String ecosystemText = "ECOSISTEMA";
    
    // Dibujamos un pequeño icono de hoja o árbol antes del texto
    pushMatrix();
    translate(centerX + barWidth/2 - textWidth(ecosystemText)/2 - iconSize - 8, topPosition + barHeight/2);
    noStroke();
    fill(255);
    beginShape();
    vertex(0, 0);
    bezierVertex(iconSize/2, -iconSize/2, iconSize, 0, iconSize/2, iconSize/2);
    endShape(CLOSE);
    popMatrix();
    
    // Mostrar el texto centrado
    text(ecosystemText, centerX + barWidth/2 + iconSize/2, topPosition + barHeight/2);
    
    // Porcentaje numérico para mayor claridad
    textAlign(RIGHT, CENTER);
    textSize(26); 
    text(int(ecosystemHealth * 100) + "%", centerX + barWidth - 15, topPosition + barHeight/2);
    
  }
  
  // Mostrar el cronómetro del juego junto a la barra del ecosistema
  void displayGameTimer() {
    pushStyle();
    
    // Variables para posicionar el cronómetro junto a la barra del ecosistema
    int barWidth = 450;        
    int timerWidth = 180;      
    int timerHeight = 60;      
    int topPosition = 25;      
    float cornerRadius = 15;   
    
    // Posicionar el cronómetro a la derecha de la barra del ecosistema
    int centerX = width / 2 - barWidth / 2;  
    int timerX = centerX + barWidth + 20;    
    int timerY = topPosition;                
    
    // Panel de fondo para el cronómetro con el mismo estilo que la barra del ecosistema
    fill(0, 0, 0, 200);
    stroke(accessManager.getUIBorderColor(color(100, 150, 255)));
    strokeWeight(3); 
    rect(timerX, timerY, timerWidth, timerHeight, cornerRadius);
    
    // Calcular minutos y segundos desde playTimeSeconds
    int minutes = playTimeSeconds / 60;
    int seconds = playTimeSeconds % 60;
    
    // Formatear el tiempo como MM:SS (siempre con dos dígitos)
    String timeText = String.format("%02d:%02d", minutes, seconds);
    
    // Configurar tamaño del texto primero para calcular posiciones correctas
    textSize(accessManager.getAdjustedTextSize(32)); 
    
    int iconSize = 28;  
    int spacing = 15;   
    
    // Calcular el ancho total (icono + espacio + texto) para centrar todo el conjunto
    float textWidth = textWidth(timeText);
    float totalWidth = iconSize + spacing + textWidth;
    
    // Posición inicial centrada en el panel
    float startX = timerX + (timerWidth - totalWidth) / 2;
    
    // Posiciones finales alineadas
    int iconX = (int)startX + iconSize/2;  // Centro del icono
    int iconY = timerY + timerHeight/2;    
    float textX = startX + iconSize + spacing + textWidth/2;  
    int textY = timerY + timerHeight/2 - 2;    
    
    // Dibujar el icono del reloj
    pushMatrix();
    translate(iconX, iconY);
    noStroke();
    
    // Fondo del reloj
    fill(accessManager.getTextColor(color(220, 220, 220)));
    ellipse(0, 0, iconSize, iconSize);
    
    // Borde del reloj
    stroke(accessManager.getTextColor(color(100, 100, 100)));
    strokeWeight(3); 
    noFill();
    ellipse(0, 0, iconSize, iconSize);
    
    // Manecillas del reloj
    stroke(accessManager.getTextColor(color(80, 80, 80)));
    strokeWeight(3); 
    line(0, 0, 0, -iconSize/3);
    line(0, 0, iconSize/4, -iconSize/4);
    
    // Punto central del reloj
    fill(accessManager.getTextColor(color(80, 80, 80)));
    noStroke();
    ellipse(0, 0, 4, 4); 
    
    popMatrix();
    
    // Mostrar el cronómetro con un color que cambia según el tiempo transcurrido
    color timeColor = accessManager.getTextColor(color(255, 255, 255)); 
    
    // Cambiar color después de ciertos hitos de tiempo para hacer el cronómetro más interesante
    if (playTimeSeconds >= 300) {      
      timeColor = accessManager.getTextColor(color(255, 215, 0));
    } else if (playTimeSeconds >= 120) { 
      timeColor = accessManager.getTextColor(color(100, 255, 100));
    } else if (playTimeSeconds >= 60) { 
      timeColor = accessManager.getTextColor(color(100, 200, 255));
    }
    
    // Dibujar el texto del tiempo perfectamente alineado con el icono
    fill(timeColor);
    textAlign(CENTER, CENTER);
    text(timeText, textX, textY);
    
    popStyle();
  }
  
  void displayTutorial() {
    // Variables para una UI más consistente y accesible
    int barWidth = 520;       
    int barHeight = 80;       
    int topPosition = 100;    
    
    // Caja de tutorial
    fill(0, 0, 0, 220); 
    rect(width/2 - barWidth/2, topPosition, barWidth, barHeight, 15); 
    
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(22); 
    text(tutorialMessages.get(currentTutorialMessage), width/2, topPosition + barHeight/2 - 8);
    
    for (int i = 0; i < tutorialMessages.size(); i++) {
      if (i == currentTutorialMessage) {
        fill(255); 
      } else {
        fill(150); 
      }
      ellipse(width/2 - 40 + i * 28, topPosition + barHeight - 18, 12, 12);
    }
    
  }
  
  void displayActivePowerUps() {
    // Mostrar todos los power-ups activos
    for (PowerUp powerUp : collectibleManager.getActivePowerUps()) {
      powerUp.display();
    }
  }
  
  // Mostrar el framerate actual en la esquina superior izquierda
  void displayFramerate() {
    pushStyle();
    int fpsWidth = 110;       
    int fpsHeight = 50;       
    int leftMargin = 35;      
    int topPosition = 120;    
    float cornerRadius = 12;  
    
    // Panel para el FPS
    fill(0, 0, 0, 200); 
    stroke(255, 255, 255, 100); 
    strokeWeight(2);
    rect(leftMargin, topPosition, fpsWidth, fpsHeight, cornerRadius);
    
    // Mostrar el texto con color adaptativo según el rendimiento
    int fps = round(frameRate);
    
    // Color basado en el rendimiento (mantenemos la lógica original pero con mejor contraste)
    if (fps >= 55) {
      fill(0, 255, 80); 
    } else if (fps >= 30) {
      fill(255, 230, 0); 
    } else {
      fill(255, 60, 60); 
    }
    
    textAlign(CENTER, CENTER);
    textSize(24); 
    text("FPS: " + fps, leftMargin + fpsWidth/2, topPosition + fpsHeight/2);
    popStyle();
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
  
  // Método para limpiar el estado del juego cuando se vuelve al menú
  void cleanupForMenuTransition() {
    // Asegurarse de que el estado del juego sea apropiado para el menú principal
    gameOver = false;
    gameStarted = false;
    
    // Limpiar coleccionables y obstáculos activos
    if (collectibleManager != null) {
      collectibleManager.clearAll();
    }
    
    if (obstacleManager != null) {
      obstacleManager.clearAll();
    }
    
    if (platformManager != null) {
      platformManager.clearAllPlatforms();
    }
    
    // Asegurarse de que el jugador esté en posición inicial
    if (player != null) {
      player.reset();
    }
    
    // Restaurar cámara a posición inicial
    cameraY = 0;
    targetCameraY = 0;
    
    // Restaurar variables de dificultad
    difficultyLevel = 1;
    ddaMultiplier = 1.0;
  }
  
  // Mostrar mensaje educativo aleatorio
  void showEducationalMessage() {
    if (messageCooldown > 0) return;
    
    // Lista de mensajes educativos
    String[] messages = {
      "Reciclar ayuda a reducir la contaminación",
      "Usar menos plástico mejora la salud de los océanos",
      "El cambio climático afecta a todos los seres vivos",
      "Plantar árboles ayuda a combatir la contaminación",
      "El transporte público reduce emisiones de CO2"
    };
    
    // Seleccionar un mensaje aleatorio que no se haya mostrado recientemente
    String selectedMessage = "";
    int attempts = 0;
    boolean messageFound = false;
    
    while (!messageFound && attempts < 10) {
      int index = floor(random(messages.length));
      selectedMessage = messages[index];
      
      // Comprobar si el mensaje ya está en las últimas mostradas
      boolean alreadyShown = false;
      
      // Crear una copia temporal de la pila para no alterarla
      Stack<String> tempStack = new Stack<String>();
      int checkedMessages = 0;
      
      // Revisar solo los últimos mensajes (hasta maxRepeatedMessages)
      while (!shownMessages.isEmpty() && checkedMessages < maxRepeatedMessages) {
        String message = shownMessages.pop();
        tempStack.push(message);
        
        if (message.equals(selectedMessage)) {
          alreadyShown = true;
        }
        
        checkedMessages++;
      }
      
      // Restaurar los mensajes a la pila original
      while (!tempStack.isEmpty()) {
        shownMessages.push(tempStack.pop());
      }
      
      // Si el mensaje no se ha mostrado recientemente, usarlo
      if (!alreadyShown) {
        messageFound = true;
      }
      
      attempts++;
    }
    
    // Si después de varios intentos no encontramos un mensaje nuevo, simplemente mostrar uno aleatorio
    if (!messageFound) {
      int index = floor(random(messages.length));
      selectedMessage = messages[index];
    }
    
    // Mostrar el mensaje seleccionado
    collectibleManager.addFloatingText(selectedMessage, width/2, height/2 - 100, color(50, 200, 50));
    soundManager.playCollectSound();
    
    // Registrar el mensaje mostrado
    shownMessages.push(selectedMessage);
    
    // Limitar la lista de mensajes mostrados
    while (shownMessages.size() > 20) {
      // Para mantener la historia limitada a 20, creamos una pila temporal
      Stack<String> tempStack = new Stack<String>();
      
      // Guarda solo los últimos 19 mensajes
      int messagesToKeep = 19;
      int removed = 0;
      
      while (!shownMessages.isEmpty()) {
        String message = shownMessages.pop();
        
        // Solo guardar los mensajes más recientes
        if (removed < messagesToKeep) {
          tempStack.push(message);
        }
        removed++;
      }
      
      // Restaurar los mensajes a mantener
      while (!tempStack.isEmpty()) {
        shownMessages.push(tempStack.pop());
      }
      
      break; // Salir del bucle después de ajustar el tamaño
    }
    
    // Reiniciar temporizador de enfriamiento
    messageCooldown = messageInterval;
  }
  
  // Método para alternar modo de cajas de colisión
  void toggleCollisionBoxes() {
    if (debugSystem != null) {
      showCollisionBoxes = !showCollisionBoxes;
      if (showCollisionBoxes) {
        debugSystem.enableCollisionBoxes();
        debugSystem.logInfo("Cajas de colisión activadas");
      } else {
        debugSystem.disableCollisionBoxes();
        debugSystem.logInfo("Cajas de colisión desactivadas");
      }
    }
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