/**
 * PlayerNameInput.pde
 * 
 * Gestiona la entrada del nombre del jugador después de finalizar una partida
 * para guardar en la tabla de clasificación.
 */
class PlayerNameInput {
  // Propiedades de entrada de texto
  String playerName = "";
  int maxNameLength = 14;
  boolean inputActive = true;
  int cursorBlinkTimer = 0;
  boolean showCursor = true;
  
  // Referencias a otras clases
  AccessibilityManager accessManager;
  GameStateManager stateManager;
  Leaderboard leaderboard;
  GameManager gameManager; // Referencia para acceder a XP Summary
  
  // Botón para continuar 
  Button continueButton;
  Button skipButton; 
  
  // Datos del juego finalizado
  int finalScore;
  int playTimeInSeconds;
  
  PlayerNameInput(AccessibilityManager accessManager, GameStateManager stateManager, Leaderboard leaderboard) {
    this.accessManager = accessManager;
    this.stateManager = stateManager;
    this.leaderboard = leaderboard;
    this.gameManager = null; 
    this.finalScore = 0;
    this.playTimeInSeconds = 0;
    
    // Inicializar botón de continuar con el mismo estilo que los botones del menú
    continueButton = new Button(width/2 + 95, height/2 + (height * 0.35)/2 - 35, 180, 45, "CONTINUAR", 
                               color(80, 150, 80), accessManager);
    
    // Inicializar botón de saltar al XP
    skipButton = new Button(width/2 - 95, height/2 + (height * 0.35)/2 - 35, 180, 45, "SALTAR", 
                           color(150, 100, 50), accessManager);
  }
  
  // Establecer datos del juego finalizado
  void setGameData(int score, int playTime) {
    this.finalScore = score;
    this.playTimeInSeconds = playTime;
  }
  
  // Establecer referencia al GameManager
  void setGameManager(GameManager gm) {
    this.gameManager = gm;
  }
  
  // Procesar entrada de teclado
  void keyPressed() {
    if (!inputActive) return;
    
    if (keyCode == ESC) {
      // Regresar al menú principal cuando se presiona escape
      stateManager.setState(STATE_MAIN_MENU);
      reset();
      key = 0; // Evitar que Processing salga
      return;
    } else if (key == BACKSPACE && playerName.length() > 0) {
      // Eliminar último carácter
      playerName = playerName.substring(0, playerName.length() - 1);
    } else if (key == ENTER || key == RETURN) {
      // Finalizar entrada solo si hay texto
      if (playerName.length() > 0) {
        submitName();
      }
    } else if (key >= ' ' && key <= 'z' && playerName.length() < maxNameLength) {
      // Añadir carácter (solo letras, números y espacios)
      if (Character.isLetterOrDigit(key) || key == ' ') {
        playerName += key;
      }
    }
  }
  
  // Enviar el nombre y guardar la puntuación
  void submitName() {
    if (playerName.trim().length() > 0) {
      // Añadir el record a la tabla de clasificación
      leaderboard.addRecordFromGame(playerName, finalScore, playTimeInSeconds);
      
      // Abrir leaderboard después de partida - usa método específico para marcar el origen correcto
      stateManager.openLeaderboardFromGame();
      
      // Reiniciar para futuros usos
      reset();
    }
  }
  
  // Método para saltar directamente a la pantalla XP
  void skipToXP() {
    // Configurar datos XP si tenemos acceso al GameManager
    if (gameManager != null && gameManager.xpSummaryScreen != null && gameManager.game != null) {
      Game game = gameManager.game;
      gameManager.xpSummaryScreen.setXPData(
        game.lastRunXP,
        game.lastRunDistance,
        game.lastRunCollectibles,
        game.lastRunTimeSeconds,
        game.lastRunAvgEcoHealth,
        game.lastRunWasHit,
        game.lastRunGoodEcoTime
      );
    }
    
    // Ir directamente al estado de resumen XP sin guardar en leaderboard
    stateManager.setState(STATE_XP_SUMMARY);
    
    // Reiniciar para futuros usos
    reset();
  }
  
  // Reiniciar para futuros usos
  void reset() {
    playerName = "";
    inputActive = true;
  }
  
  // Actualizar (para efectos visuales como parpadeo del cursor)
  void update() {
    cursorBlinkTimer++;
    if (cursorBlinkTimer > 30) {
      showCursor = !showCursor;
      cursorBlinkTimer = 0;
    }
  }
  
  // Dibujar la interfaz de entrada de nombre
  void display() {
    pushStyle();
    
    // Fondo semi-transparente (permitiendo ver el juego detrás)
    color bgColor = accessManager.getBackgroundColor(color(0, 0, 0, 120));
    fill(bgColor);
    rect(0, 0, width, height);
    
    // Panel central (más pequeño como un popup)
    rectMode(CENTER);
    // Usando un color con alpha para que se vea el fondo pero sea legible el texto
    color panelColor = accessManager.getBackgroundColor(color(50, 50, 50, 220));
    fill(panelColor);
    stroke(accessManager.getTextColor(color(180, 180, 180, 200)));
    strokeWeight(2);
    
    // Tamaño del popup
    float popupWidth = width * 0.5;
    float popupHeight = height * 0.35;
    rect(width/2, height/2, popupWidth, popupHeight, 15);
    
    // Título con color más vibrante para destacar
    textAlign(CENTER, CENTER);
    textSize(accessManager.getAdjustedTextSize(32));
    fill(accessManager.getTextColor(color(255, 255, 150)));
    text("¡NUEVO RECORD!", width/2, height/2 - popupHeight/2 + 40);
    
    // Mostrar puntaje final
    textSize(accessManager.getAdjustedTextSize(24));
    fill(accessManager.getTextColor(color(255)));
    text("Puntuación: " + finalScore, width/2, height/2 - popupHeight/2 + 80);
    
    // Instrucción
    textSize(accessManager.getAdjustedTextSize(20));
    fill(accessManager.getTextColor(color(200, 200, 200)));
    text("Ingresa tu nombre:", width/2, height/2);
    
    // Campo de entrada de texto - con borde para hacerlo más visible
    rectMode(CENTER);
    fill(accessManager.getBackgroundColor(color(30, 30, 30, 230)));
    stroke(accessManager.getTextColor(color(120, 120, 120)));
    strokeWeight(1);
    float inputWidth = popupWidth * 0.7;
    rect(width/2, height/2 + 40, inputWidth, 45, 5);
    
    // Texto ingresado
    textAlign(LEFT, CENTER);
    textSize(accessManager.getAdjustedTextSize(22));
    fill(accessManager.getTextColor(color(255)));
    noStroke();
    
    // Texto con margen izquierdo
    float textX = width/2 - inputWidth/2 + 10;
    text(playerName + (showCursor && inputActive ? "|" : ""), textX, height/2 + 40);
    
    // Nota sobre longitud máxima
    textAlign(CENTER, CENTER);
    textSize(accessManager.getAdjustedTextSize(14));
    fill(accessManager.getTextColor(color(150, 150, 150)));
    text("(Máximo " + maxNameLength + " caracteres)", width/2, height/2 + 70);
    
    // Actualizar posición y estado habilitado/deshabilitado
    continueButton.x = width/2 + 95;
    continueButton.y = height/2 + popupHeight/2 - 50;
    
    // Actualizar posición del botón saltar
    skipButton.x = width/2 - 95;
    skipButton.y = height/2 + popupHeight/2 - 50;
    
    // Desactivar visualmente el botón si no hay texto
    // Esto da feedback visual al usuario - muy importante para la experiencia de usuario
    boolean buttonEnabled = playerName.trim().length() > 0;
    if (!buttonEnabled) {
      // Usar un color más gris para indicar que está deshabilitado
      continueButton.baseColor = color(100, 100, 100);
    } else {
      // Usar color verde para indicar que está habilitado
      continueButton.baseColor = color(80, 150, 80);
    }
    continueButton.updateHoverColor();
    continueButton.display();
    
    // El botón saltar siempre está habilitado
    skipButton.baseColor = color(150, 100, 50);
    skipButton.updateHoverColor();
    skipButton.display();
    
    popStyle();
  }
  
  // Verificar si se hizo clic en el botón continuar
  boolean checkButtonClick(int mouseX, int mouseY) {
    // Solo permitir clic si hay texto
    if (playerName.trim().length() > 0) {
      return continueButton.isClicked();
    }
    return false;
  }
  
  // Verificar si se hizo clic en el botón saltar
  boolean checkSkipButtonClick(int mouseX, int mouseY) {
    return skipButton.isClicked();
  }
  
  // Procesar clic de mouse
  void mousePressed(int mouseX, int mouseY) {
    if (checkButtonClick(mouseX, mouseY)) {
      submitName();
    } else if (checkSkipButtonClick(mouseX, mouseY)) {
      skipToXP();
    }
  }
} 
