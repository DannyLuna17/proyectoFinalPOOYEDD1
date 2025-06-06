/**
 * InputHandler.pde
 * 
 * Maneja toda la entrada del usuario incluyendo teclado, ratón y controles de navegación.
 * Centraliza la gestión de entradas para hacer el código más fácil de mantener.
 */

class InputHandler {
  // Componentes
  Game game;
  Menu menu;
  AccessibilityManager accessManager;
  SoundManager soundManager;
  VideoIntroMenu videoIntroMenu;
  Leaderboard leaderboard;
  PlayerNameInput playerNameInput;
  GameManager gameManager; // Referencia al GameManager para acceder a xpSummaryScreen
  
  // Estado
  int gameState; // Referencia local al estado actual del juego
  GameStateManager stateManager; // Referencia al gestor de estados global
  
  // Navegación
  int selectedMenuItem;
  
  InputHandler(Game game, Menu menu, AccessibilityManager accessManager, SoundManager soundManager, VideoIntroMenu videoIntroMenu) {
    this.game = game;
    this.menu = menu;
    this.accessManager = accessManager;
    this.soundManager = soundManager;
    this.videoIntroMenu = videoIntroMenu;
    
    // Inicializar referencia al gestor de estados
    if (game != null) {
      this.stateManager = game.gameStateManager;
    }
    
    this.selectedMenuItem = 0;
  }
  
  void setGameState(int gameState) {
    this.gameState = gameState;
    // Actualizar el gestor de estados si está disponible
    if (stateManager != null) {
      stateManager.setState(gameState);
    }
  }
  
  int getGameState() {
    // Obtener el estado desde el gestor si está disponible, si no usar la copia local
    return stateManager != null ? stateManager.getState() : gameState;
  }
  
  void setSelectedMenuItem(int selectedMenuItem) {
    this.selectedMenuItem = selectedMenuItem;
  }
  
  void setGameManager(GameManager gameManager) {
    this.gameManager = gameManager;
  }
  
  // Manejar eventos de tecla presionada
  void handleKeyPressed() {
    // Manejar entrada de nombre si estamos en ese estado
    if (getGameState() == STATE_NAME_INPUT && playerNameInput != null) {
      playerNameInput.keyPressed();
      return;
    }
    
    // Manejar input en pantalla XP
    if (getGameState() == STATE_XP_SUMMARY && gameManager != null && gameManager.xpSummaryScreen != null) {
      gameManager.xpSummaryScreen.handleKeyPressed();
      if (keyCode == ESC) {
        handleEscapeKey();
        key = 0; 
      }
      return;
    }
    
    // Manejar navegación con teclado en pantallas de menú
    if (getGameState() != STATE_GAME) {
      handleMenuKeyboardNavigation();
    }
    
    // Procesar atajos de teclado
    handleKeyboardShortcuts();
    
    // Manejar entrada de juego si estamos en estado de juego
    if (getGameState() == STATE_GAME) {
      handleGameplayInput();
    }
  }
  
  // Manejar eventos de tecla liberada
  void handleKeyReleased() {
    if (getGameState() == STATE_GAME) {
      handleGameplayKeyReleased();
    }
  }
  
  // Procesar atajos de teclado globales
  void handleKeyboardShortcuts() {
    if (key == 'r') {
      resetGameIfAvailable();
    } else if (key == 'a') {
      // Acceder a ajustes de accesibilidad desde cualquier pantalla
      if (getGameState() != STATE_SETTINGS && getGameState() != STATE_GAME) {
        stateManager.setState(STATE_SETTINGS);
        selectedMenuItem = 3; // Posicionar en la primera opción de accesibilidad
        menu.updateSelectedItem(getGameState(), selectedMenuItem);
      }
    } else if (key == 'c' || key == 'C') {
      // Atajo rápido para alternar el filtro de daltonismo
      // Funciona desde cualquier pantalla para mayor accesibilidad
      accessManager.toggleColorBlindMode();
      // Si estamos en el menú de configuración, actualizar el texto del botón
      if (getGameState() == STATE_SETTINGS) {
        menu.updateSettingsButtonText();
      }
      // Mostrar confirmación visual
      if (accessManager.visualCuesForAudio) {
        String status = accessManager.colorBlindMode ? "activado" : "desactivado";
        accessManager.displaySoundCue("Filtro daltonismo " + status, width/2, height/2);
      }
    } else if (key == 'h' || key == 'H') {
      // Atajo rápido para alternar el filtro de alto contraste
      // Funciona desde cualquier pantalla para mayor accesibilidad
      accessManager.toggleHighContrastMode();
      // Si estamos en el menú de configuración, actualizar el texto del botón
      if (getGameState() == STATE_SETTINGS) {
        menu.updateSettingsButtonText();
      }
      // Mostrar confirmación visual
      if (accessManager.visualCuesForAudio) {
        String status = accessManager.highContrastMode ? "activado" : "desactivado";
        accessManager.displaySoundCue("Alto contraste " + status, width/2, height/2);
      }
    } else if (keyCode == ESC) {
      handleEscapeKey();
      key = 0; // Evitar que Processing salga
    }
    
    // Permitir que la tecla "1" sea manejada por Game para activar cajas de colisión
    if (key == '1') {
      // Pasar el control al método keyPressed de Game
      if (game != null) {
        game.keyPressed();
      }
    }
  }
  
  // Manejar teclas de flecha y enter para navegación del menú
  void handleMenuKeyboardNavigation() {
    // Omitir si el modo solo ratón está activado
    if (accessManager.mouseOnly) return;
    
    int oldSelection = selectedMenuItem;
    int menuItemCount = menu.getMenuItemCount(getGameState());
    
    if (menuItemCount <= 0) return; // No hay elementos de menú para navegar
    
    if (getGameState() == STATE_MAIN_MENU) {
      handleHorizontalNavigation(oldSelection);
    } else {
      handleVerticalNavigation(oldSelection);
    }
    
    // Circular por la selección del menú
    if (menuItemCount > 0) { // Protección contra menús vacíos
      if (selectedMenuItem < 0) selectedMenuItem = menuItemCount - 1;
      if (selectedMenuItem >= menuItemCount) selectedMenuItem = 0;
    } else {
      selectedMenuItem = 0;
    }
    
    // Actualizar elemento resaltado del menú
    menu.updateSelectedItem(getGameState(), selectedMenuItem);
  }
  
  void handleHorizontalNavigation(int oldSelection) {
    if (keyCode == LEFT || key == 'a' || key == 'A') {
      selectedMenuItem--;
      playSelectionSoundIfChanged(oldSelection);
    } else if (keyCode == RIGHT || key == 'd' || key == 'D') {
      selectedMenuItem++;
      playSelectionSoundIfChanged(oldSelection);
    } else if (keyCode == ENTER || keyCode == RETURN || key == ' ') {
      activateSelectedMenuItem();
      soundManager.playButtonSound();
    } else if (keyCode == TAB) {
      selectedMenuItem++;
      playSelectionSoundIfChanged(oldSelection);
    } else if (keyCode == ESC) {
      handleEscapeKey();
      key = 0; // Evitar que Processing salga
    }
  }
  
  void handleVerticalNavigation(int oldSelection) {
    if (keyCode == UP || key == 'w' || key == 'W') {
      selectedMenuItem--;
      playSelectionSoundIfChanged(oldSelection);
    } else if (keyCode == DOWN || key == 's' || key == 'S') {
      selectedMenuItem++;
      playSelectionSoundIfChanged(oldSelection);
    } else if (keyCode == ENTER || keyCode == RETURN || key == ' ') {
      activateSelectedMenuItem();
      soundManager.playButtonSound();
    } else if (keyCode == TAB) {
      selectedMenuItem++;
      playSelectionSoundIfChanged(oldSelection);
    } else if (keyCode == ESC) {
      handleEscapeKey();
      key = 0; // Evitar que Processing salga
    }
  }
  
  void playSelectionSoundIfChanged(int oldSelection) {
    if (oldSelection != selectedMenuItem) {
      soundManager.playMenuSound();
    }
  }
  
  void handleGameplayInput() {
    // Evitar manejar la tecla "1" aquí ya que es para cajas de colisión
    if (key == '1') {
      return;
    }
    
    if (key == accessManager.getJumpKey()) {
      game.player.jump();
    } else if (key == accessManager.getSlideKey()) {
      game.player.slide();
    } else if (keyCode == DOWN) {
      // Si está en el aire, activar fast fall
      if (game.player.isInAir()) {
        // Caída rápida
        game.player.startFastFall();
      } else if (game.player.isOnPlatform && game.player.currentPlatform != null) {
        // Si el jugador está parado en una plataforma y presiona abajo, baja por la plataforma al toque
        // Esto no aplica si está en el aire, solo cuando está bien parado sobre una plataforma
        game.player.dropThroughPlatform();
      }
    } else if (key == accessManager.pauseKey) {
      pauseGame();
    }
    
    // Pasar la tecla presionada al juego para manejar reinicio
    game.keyPressed();
    
    // Comprobar si el juego ha terminado
    if (game.gameOver) {
      transitionToGameOver();
    }
  }
  
  void handleGameplayKeyReleased() {
    if (key == accessManager.getJumpKey()) {
      game.player.releaseJump();
    } else if (key == accessManager.getSlideKey()) {
      game.player.stopSliding();
    }
  }
  
  void pauseGame() {
    stateManager.setState(STATE_PAUSED);
    soundManager.playMenuSound();
    selectedMenuItem = 0; // Resetear selección al primer elemento del menú de pausa
    menu.updateSelectedItem(getGameState(), selectedMenuItem);
  }
  
  void transitionToGameOver() {
    // Solo hacer transición si no estamos ya en estado de fin de juego
    if (getGameState() != STATE_GAME_OVER) {
      stateManager.setState(STATE_GAME_OVER);
      selectedMenuItem = 0; // Resetear selección al primer elemento del menú de fin de juego
      menu.updateSelectedItem(getGameState(), selectedMenuItem);
      
      // Reproducir sonido de fin de juego
      if (soundManager != null) {
        soundManager.playGameOverSound();
      }
    }
  }
  
  void handleMousePressed() {
    // Manejar entrada de ratón para menús
    if (accessManager.keyboardOnly) return; // Omitir si modo solo teclado
    
    if (getGameState() == STATE_NAME_INPUT && playerNameInput != null) {
      // Manejar clic en la entrada de nombre
      playerNameInput.mousePressed(mouseX, mouseY);
      return;
    }
    
    if (getGameState() == STATE_XP_SUMMARY && gameManager != null && gameManager.xpSummaryScreen != null) {
      // Manejar clics en la pantalla de resumen de XP
      gameManager.xpSummaryScreen.handleMousePressed();
      
      if (gameManager.xpSummaryScreen.checkContinueClick()) {
        // Si se hizo clic en continuar, ir al menú principal
        stateManager.setState(STATE_MAIN_MENU);
        selectedMenuItem = 0;
        menu.updateSelectedItem(getGameState(), selectedMenuItem);
        return;
      }
    }
    
    if (getGameState() == STATE_LEADERBOARD && leaderboard != null) {
      // Manejar interacciones del scrollbar 
      leaderboard.handleMousePressed();
      
      // Usar el nuevo método para verificar si se hizo clic en el botón volver
      if (leaderboard.checkBackButtonClick()) {
        // Comportamiento según desde dónde se abrió el leaderboard
        if (stateManager.isLeaderboardFromMainMenu()) {
          // Si fue abierto desde el menú principal, regresar directamente al menú sin mostrar XP
          stateManager.setState(STATE_MAIN_MENU);
        } else {
          // Si fue abierto después de una partida, mostrar pantalla de XP como antes
          if (game != null && game.gameOver && gameManager != null && gameManager.xpSummaryScreen != null) {
            // Configurar datos del XP antes de mostrar la pantalla de resumen
            gameManager.xpSummaryScreen.setXPData(
              game.lastRunXP, // XP total ganado en la partida 
              game.lastRunDistance, // Datos almacenados del juego
              game.lastRunCollectibles, // Datos almacenados del juego
              game.lastRunTimeSeconds, // Datos almacenados del juego
              game.lastRunAvgEcoHealth, // Datos almacenados del juego
              game.lastRunWasHit, // Datos almacenados del juego
              game.lastRunGoodEcoTime // Datos almacenados del juego
            );
            stateManager.setState(STATE_XP_SUMMARY);
          } else {
            // Fallback al menú principal si no hay datos de XP
            stateManager.setState(STATE_MAIN_MENU);
          }
        }
        selectedMenuItem = 0;
        menu.updateSelectedItem(getGameState(), selectedMenuItem);
        return;
      }
    }
    
    if (getGameState() == STATE_INTRO_VIDEO) {
      handleIntroVideoMouseClick();
    } else if (getGameState() != STATE_GAME) {
      // Manejar clics de ratón en botones y elementos de menú
      handleMenuMouseClick();
    } else if (getGameState() == STATE_GAME) {
      // Manejar clics de ratón en el juego
      handleGameMouseClick();
    }
  }
  
  void handleMouseWheel(MouseEvent event) {
    // Manejar desplazamiento en la tabla de clasificación
    if (getGameState() == STATE_LEADERBOARD && leaderboard != null) {
      float delta = event.getCount();
      leaderboard.handleMouseWheel(delta);
      return;
    }
    
    if (getGameState() != STATE_GAME) {
      int delta = event.getCount();
      // Desplazar elementos del menú
      if (delta < 0) {
        selectedMenuItem--;
      } else {
        selectedMenuItem++;
      }
      // Circular
      int menuItemCount = menu.getMenuItemCount(getGameState());
      if (menuItemCount > 0) {
        if (selectedMenuItem < 0) selectedMenuItem = menuItemCount - 1;
        if (selectedMenuItem >= menuItemCount) selectedMenuItem = 0;
      }
      
      menu.updateSelectedItem(getGameState(), selectedMenuItem);
      soundManager.playMenuSound();
    }
  }
  
  void handleIntroVideoMouseClick() {
    videoIntroMenu.handleMousePressed();
  }
  
  void handleMenuMouseClick() {
    // Según el estado actual, llamar al manejador de clics de menú apropiado
    int currentState = getGameState();
    switch(currentState) {
      case STATE_MAIN_MENU:
        menu.handleMainMenuClick();
        break;
      case STATE_INSTRUCTIONS:
        menu.handleInstructionsClick();
        break;
      case STATE_SETTINGS:
        menu.handleSettingsClick();
        break;
      case STATE_PAUSED:
        menu.handlePauseMenuClick();
        break;
      case STATE_GAME_OVER:
        menu.handleGameOverClick();
        break;
      case STATE_ACCESSIBILITY:
        menu.handleAccessibilityMenuClick();
        break;
      case STATE_LEADERBOARD:
        // Manejado directamente en handleMousePressed
        break;
    }
  }
  
  void handleGameMouseClick() {
    // Si el juego soporta controles por ratón, procesarlos aquí
    // Por ejemplo: game.handleMouseClick();
  }
  
  void activateSelectedMenuItem() {
    if (getGameState() == STATE_MAIN_MENU) {
      handleMainMenuSelection();
    } else if (getGameState() == STATE_INSTRUCTIONS) {
      // Volver al menú principal
      stateManager.setState(STATE_MAIN_MENU);
    } else if (getGameState() == STATE_SETTINGS) {
      handleSettingsMenuSelection();
    } else if (getGameState() == STATE_PAUSED) {
      handlePauseMenuSelection();
    } else if (getGameState() == STATE_GAME_OVER) {
      handleGameOverMenuSelection();
    }
  }
  
  void handleMainMenuSelection() {
    if (selectedMenuItem == 0) {
      stateManager.setState(STATE_GAME);
      game.reset();
    } else if (selectedMenuItem == 1) {
      stateManager.setState(STATE_INSTRUCTIONS);
    } else if (selectedMenuItem == 2) {
      // Botón de Leaderboard - abrir desde menú principal con método específico
      stateManager.openLeaderboardFromMenu();
    } else if (selectedMenuItem == 3) {
      stateManager.setState(STATE_SETTINGS);
    } else if (selectedMenuItem == 4) {
      exit(); // Salir del juego
    }
  }
  
  void handleSettingsMenuSelection() {
    // Aplicar ajustes según selectedMenuItem
    if (selectedMenuItem == menu.getMenuItemCount(getGameState()) - 1) {
      // El último elemento suele ser "Volver"
      stateManager.setState(STATE_MAIN_MENU);
    } else {
      // Alternar o ajustar configuración
      menu.activateSettingsItem(selectedMenuItem);
    }
  }
  
  void handlePauseMenuSelection() {
    if (selectedMenuItem == 0) {
      stateManager.setState(STATE_GAME);
    } else if (selectedMenuItem == 1) {
      // Limpiar completamente el estado del juego antes de ir al menú principal
      game.cleanupForMenuTransition();
      
      // Forzar una limpieza completa del canvas para asegurar que no queden elementos residuales
      pushStyle();
      clear();
      background(0);
      popStyle();
      
      // Asegurar que el cursor del menú vuelva a su posición inicial
      selectedMenuItem = 0;
      
      // Cambiar al estado del menú principal
      stateManager.setState(STATE_MAIN_MENU);
    }
  }
  
  void handleGameOverMenuSelection() {
    if (selectedMenuItem == 0) {
      stateManager.setState(STATE_GAME);
      game.reset();
    } else if (selectedMenuItem == 1) {
      game.cleanupForMenuTransition();
      stateManager.setState(STATE_MAIN_MENU);
    }
  }
  
  void handleEscapeKey() {
    if (getGameState() == STATE_INTRO_VIDEO) {
      // Saltar introducción
      videoIntroMenu.skipVideo();
    } else if (getGameState() == STATE_GAME) {
      pauseGame();
    } else if (getGameState() == STATE_XP_SUMMARY) {
      // Desde la pantalla de resumen de XP, regresar al menú principal
      selectedMenuItem = 0;
      stateManager.setState(STATE_MAIN_MENU);
      menu.updateSelectedItem(getGameState(), selectedMenuItem);
    } else if (getGameState() == STATE_LEADERBOARD) {
      // Manejo especial para el leaderboard según su origen
      if (stateManager.isLeaderboardFromMainMenu()) {
        // Si fue abierto desde el menú principal, regresar directamente al menú
        stateManager.setState(STATE_MAIN_MENU);
      } else {
        // Si fue abierto después de una partida, mostrar pantalla de XP
        if (game != null && game.gameOver && gameManager != null && gameManager.xpSummaryScreen != null) {
          // Configurar datos del XP antes de mostrar la pantalla de resumen
          gameManager.xpSummaryScreen.setXPData(
            game.lastRunXP,
            game.lastRunDistance,
            game.lastRunCollectibles,
            game.lastRunTimeSeconds,
            game.lastRunAvgEcoHealth,
            game.lastRunWasHit,
            game.lastRunGoodEcoTime
          );
          stateManager.setState(STATE_XP_SUMMARY);
        } else {
          // Fallback al menú principal si no hay datos de XP
          stateManager.setState(STATE_MAIN_MENU);
        }
      }
      selectedMenuItem = 0;
      menu.updateSelectedItem(getGameState(), selectedMenuItem);
    } else if (getGameState() != STATE_MAIN_MENU) {
      // Volver al menú anterior para otros estados
      if (getGameState() == STATE_PAUSED) {
        // Si estamos en el menú de pausa, necesitamos limpiar los elementos del juego
        game.cleanupForMenuTransition();
        
        // Forzar una limpieza completa del canvas para evitar elementos residuales
        pushStyle();
        clear();
        background(0);
        popStyle();
        
        // Asegurar que el cursor del menú vuelva a su posición inicial
        selectedMenuItem = 0;
      }
      
      // Cambiar al estado del menú principal
      stateManager.setState(STATE_MAIN_MENU);
    }
  }
  
  void resetGameIfAvailable() {
    if (getGameState() == STATE_GAME || getGameState() == STATE_GAME_OVER) {
      game.reset();
      if (getGameState() == STATE_GAME_OVER) {
        stateManager.setState(STATE_GAME);
      }
    }
  }
  
  void checkGameOver() {
    if (getGameState() == STATE_GAME && game.gameOver) {
      transitionToGameOver();
    }
  }
  
  // Manejar arrastre del mouse para el scrollbar 
  void handleMouseDragged() {
    if (getGameState() == STATE_LEADERBOARD && leaderboard != null) {
      leaderboard.handleMouseDragged();
    }
  }
  
  // Manejar liberación del mouse para el scrollbar 
  void handleMouseReleased() {
    if (getGameState() == STATE_LEADERBOARD && leaderboard != null) {
      leaderboard.handleMouseReleased();
    }
  }
} 
