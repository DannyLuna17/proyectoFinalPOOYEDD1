/**
 * Clase Menu - Maneja la UI y las diferentes pantallas
 * Menú principal, instrucciones, configuración, menú de pausa y pantallas de fin de juego
 */
class Menu {
  // Componentes del menú
  ArrayList<Button> mainMenuButtons;
  ArrayList<Button> instructionsButtons;
  ArrayList<Button> settingsButtons;
  ArrayList<Button> pauseMenuButtons;
  ArrayList<Button> gameOverButtons;
  
  // Propiedades visuales
  color backgroundColor;
  color overlayColor;
  PImage menuBackground;
  PImage logo;
  
  // Propiedades de animación
  float titleScale = 1.0;
  float titleScaleDirection = 0.0005;
  
  // Navegación del menú
  ArrayList<Button> currentActiveButtons; // Referencia a la lista de botones actualmente activa
  
  // Variables para navegación por teclado
  int currentSelectedButton = 0;
  int selectedMenuItem = 0; // Rastrea el elemento de menú seleccionado actualmente entre diferentes estados de menú
  ArrayList<Button> currentButtonList = new ArrayList<Button>();
  
  // Referencias externas
  AccessibilityManager accessManager;
  VideoIntroMenu videoIntroMenu;
  GameStateManager stateManager; // Referencia al gestor de estado del juego
  Game game; // Referencia a la instancia de Game
  SoundManager soundManager; // Referencia al SoundManager
  
  // Configuración
  boolean optionsSoundEnabled = true;
  boolean optionsMusicEnabled = true;
  
  Menu(AccessibilityManager accessManager) {
    this(accessManager, null);
  }
  
  Menu(AccessibilityManager accessManager, VideoIntroMenu videoIntroMenu) {
    this.accessManager = accessManager;
    this.videoIntroMenu = videoIntroMenu;
    
    // Inicializar listas de botones
    initializeButtons();
    
    // Establecer colores predeterminados
    backgroundColor = color(80, 150, 200);
    overlayColor = color(0, 0, 0, 150);
    
    // Establecer los botones activos como menú principal inicialmente
    currentActiveButtons = mainMenuButtons;
    
    // Cargar imágenes (marcadores de posición por ahora)
    // menuBackground = loadImage("background.png");
    // logo = loadImage("logo.png");
    
    // Actualizar texto de botones de configuración según ajustes de accesibilidad actuales
    updateSettingsButtonText();
  }
  
  // Constructor actualizado que acepta game y soundManager
  Menu(AccessibilityManager accessManager, VideoIntroMenu videoIntroMenu, Game game, SoundManager soundManager) {
    this.accessManager = accessManager;
    this.videoIntroMenu = videoIntroMenu;
    this.game = game;
    this.soundManager = soundManager;
    
    // Inicializar la referencia al gestor de estado desde el juego
    if (game != null) {
      this.stateManager = game.gameStateManager;
    }
    
    // Inicializar listas de botones
    initializeButtons();
    
    // Establecer colores predeterminados
    backgroundColor = color(80, 150, 200);
    overlayColor = color(0, 0, 0, 150);
    
    // Establecer los botones activos como menú principal inicialmente
    currentActiveButtons = mainMenuButtons;
    
    // Actualizar texto de botones de configuración según ajustes de accesibilidad actuales
    updateSettingsButtonText();
  }
  
  void initializeButtons() {
    // Calcular espaciado horizontal consistente para botones en una fila
    float buttonWidth = 220; // Un poco más ancho para acomodar la forma de píldora
    float buttonHeight = 60; // Un poco más alto para mejores proporciones
    float spacing = 25; // Espacio entre botones
    
    // Calcular el ancho total para 4 botones (3 espacios entre ellos)
    float totalWidth = (buttonWidth * 4) + (spacing * 3);
    // Posición para iniciar la fila (centrada correctamente)
    float startX = (width - totalWidth) / 2;
    
    float buttonY = height * 0.85; // Posicionar botones en la parte inferior de la pantalla
    
    // Botones del menú principal - en una fila horizontal con nuevo estilo (centrados correctamente)
    mainMenuButtons = new ArrayList<Button>();
    mainMenuButtons.add(new Button(startX + (buttonWidth/2), buttonY, buttonWidth, buttonHeight, "Play", accessManager));
    mainMenuButtons.add(new Button(startX + buttonWidth + spacing + (buttonWidth/2), buttonY, buttonWidth, buttonHeight, "Instructions", accessManager));
    mainMenuButtons.add(new Button(startX + 2 * (buttonWidth + spacing) + (buttonWidth/2), buttonY, buttonWidth, buttonHeight, "Settings", accessManager));
    mainMenuButtons.add(new Button(startX + 3 * (buttonWidth + spacing) + (buttonWidth/2), buttonY, buttonWidth, buttonHeight, "Exit", accessManager));
    
    // Botones de la pantalla de instrucciones
    instructionsButtons = new ArrayList<Button>();
    instructionsButtons.add(new Button(width/2, height - 50, 220, 60, "Back", accessManager));
    
    // Mayor espaciado vertical para botones de configuración
    float verticalSpacing = 80; // Aumentado desde implícitos 60 píxeles
    
    // Botones de la pantalla de configuración
    settingsButtons = new ArrayList<Button>();
    settingsButtons.add(new Button(width/2, height/2 - 260, 220, 60, "Sound: ON", accessManager));
    settingsButtons.add(new Button(width/2, height/2 - 260 + verticalSpacing, 220, 60, "Music: ON", accessManager));
    
    // Título de la sección de accesibilidad - con más espacio antes
    settingsButtons.add(new Button(width/2, height/2 - 260 + (verticalSpacing * 2) + 20, 320, 60, "Accessibility Options", accessManager));
    
    // Opciones de accesibilidad (movidas desde accessibilityButtons) - con espaciado aumentado
    settingsButtons.add(new Button(width/2, height/2 - 260 + (verticalSpacing * 3) + 20, 320, 60, "High Contrast: OFF", accessManager));
    settingsButtons.add(new Button(width/2, height/2 - 260 + (verticalSpacing * 4) + 20, 320, 60, "Color Blind Mode: OFF", accessManager));
    // settingsButtons.add(new Button(width/2, height/2 - 260 + (verticalSpacing * 5) + 20, 320, 60, "Keyboard Navigation: OFF"));
    
    // Botón de regreso en la parte inferior
    settingsButtons.add(new Button(width/2, height - 50, 220, 60, "Back", accessManager));
    
    // Definir el espaciado vertical para los botones del menú de pausa
    float pauseButtonSpacing = 100; // Mayor espaciado vertical para mejor legibilidad
    
    // Botones del menú de pausa
    pauseMenuButtons = new ArrayList<Button>();
    pauseMenuButtons.add(new Button(width/2, height/2 - 120, 220, 60, "Resume", accessManager));
    pauseMenuButtons.add(new Button(width/2, height/2, 220, 60, "Restart", accessManager));
    pauseMenuButtons.add(new Button(width/2, height/2 + 120, 220, 60, "Main Menu", accessManager));
    
    // Botones de fin de juego - centrados verticalmente
    gameOverButtons = new ArrayList<Button>();
    gameOverButtons.add(new Button(width/2, height/2 + 60, 220, 60, "Restart", accessManager));
    gameOverButtons.add(new Button(width/2, height/2 + 140, 220, 60, "Main Menu", accessManager));
  }
  
  // Método auxiliar para obtener el estado actual del juego desde el gestor de estado
  int getGameState() {
    return stateManager != null ? stateManager.getState() : STATE_MAIN_MENU;
  }
  
  // Actualizar el elemento seleccionado actualmente en el menú apropiado
  void updateSelectedItem(int state, int selectedIndex) {
    // Obtener la lista correcta de botones para el estado actual
    ArrayList<Button> buttons = getButtonListForState(state);
    
    // Primero quitar todos los resaltados
    for (Button button : mainMenuButtons) {
      button.setHighlighted(false);
      button.applyKeyboardHoverEffect(false);
    }
    for (Button button : instructionsButtons) {
      button.setHighlighted(false);
      button.applyKeyboardHoverEffect(false);
    }
    for (Button button : settingsButtons) {
      button.setHighlighted(false);
      button.applyKeyboardHoverEffect(false);
    }
    for (Button button : pauseMenuButtons) {
      button.setHighlighted(false);
      button.applyKeyboardHoverEffect(false);
    }
    for (Button button : gameOverButtons) {
      button.setHighlighted(false);
      button.applyKeyboardHoverEffect(false);
    }
    
    // Establecer el resaltado para el botón seleccionado si es válido
    if (buttons != null && selectedIndex >= 0 && selectedIndex < buttons.size()) {
      Button selectedButton = buttons.get(selectedIndex);
      selectedButton.setHighlighted(true);
      // Aplicar efecto hover para navegación por teclado también
      selectedButton.applyKeyboardHoverEffect(true);
    }
    
    // Actualizar el índice del botón seleccionado actual
    this.currentSelectedButton = selectedIndex;
    
    // Almacenar referencia a los botones activos actuales
    currentActiveButtons = buttons;
  }
  
  // Sobrecarga: versión sin parámetros para usar con el estado actual
  void updateSelectedItem() {
    updateSelectedItem(getGameState(), currentSelectedButton);
  }
  
  // Obtener la lista de botones apropiada para un estado del juego
  ArrayList<Button> getButtonListForState(int state) {
    switch(state) {
      case STATE_MAIN_MENU: return mainMenuButtons;
      case STATE_INSTRUCTIONS: return instructionsButtons;
      case STATE_SETTINGS: return settingsButtons;
      case STATE_PAUSED: return pauseMenuButtons;
      case STATE_GAME_OVER: return gameOverButtons;
      default: return null;
    }
  }
  
  // Actualizar texto de botones de accesibilidad para reflejar configuración actual
  void updateAccessibilityButtonText() {
    // Encontrar y actualizar botones de opciones de accesibilidad
    for (Button button : settingsButtons) {
      // Actualizar toggle de Alto Contraste
      if (button.text.startsWith("High Contrast:")) {
        button.text = "High Contrast: " + (accessManager.highContrastMode ? "ON" : "OFF");
      }
      // Actualizar toggle de Modo Daltónico
      else if (button.text.startsWith("Color Blind Mode:")) {
        button.text = "Color Blind Mode: " + (accessManager.colorBlindMode ? "ON" : "OFF");
      }
      // Actualizar toggle de Navegación por Teclado
      else if (button.text.startsWith("Keyboard Navigation:")) {
        button.text = "Keyboard Navigation: " + (accessManager.keyboardOnly ? "ON" : "OFF");
      }
    }
  }
  
  // Pantalla del Menú Principal - refactorizada para eliminar dibujo de título y actualizar diseño de botones
  void displayMainMenu() {
    // Resetear configuración de dibujo
    pushStyle();
    rectMode(CENTER);
    
    // Mostrar la imagen de fondo del menú desde videoIntroMenu (sin dibujo de título)
    if (videoIntroMenu != null && videoIntroMenu.finalBackground != null) {
      // Mostrar el fondo final del menú (que ya contiene el título)
      image(videoIntroMenu.finalBackground, 0, 0, width, height);
    } else {
      // Fondo alternativo de color si la imagen no está disponible
      color bgColor = accessManager.getBackgroundColor(backgroundColor);
      background(bgColor);
    }
    
    // Dibujar botones con animación apropiada si se están revelando
    if (videoIntroMenu != null && videoIntroMenu.isComplete()) {
      // Si la intro de video está completa, mostrar botones normalmente
      for (Button button : mainMenuButtons) {
        button.display();
      }
    } else if (videoIntroMenu != null) {
      // Dejar que la intro de video maneje las animaciones de botones
      videoIntroMenu.displayAnimatedButtons();
    } else {
      // Alternativa para cuando videoIntroMenu es null - fade in simple
      float fadeInProgress = min(frameCount / 60.0, 1.0); // Fade in simple de 1 segundo
      for (int i = 0; i < mainMenuButtons.size(); i++) {
        Button button = mainMenuButtons.get(i);
        // Añadir un ligero retraso para cada botón
        float buttonDelay = i * 0.035;
        float buttonProgress = constrain(fadeInProgress - buttonDelay, 0, 1);
        
        if (buttonProgress > 0) {
          // Aplicar efectos de fade-in y escala similares a VideoIntroMenu
          pushMatrix();
          translate(button.x, button.y);
          
          // Aplicar animación de escala
          float scale = buttonProgress;
          scale(scale);
          
          // Obtener los colores del botón con ajustes de accesibilidad
          color baseColor = accessManager.adjustButtonColor(button.baseColor);
          color hoverColor = accessManager.adjustButtonHoverColor(button.hoverColor);
          color textColor = accessManager.adjustTextColor(button.textColor);
          
          // Establecer opacidad según progreso
          float opacity = buttonProgress * 255;
          
          // Dibujar sombra
          if (!accessManager.highContrastMode && !accessManager.reduceAnimations) {
            noStroke();
            fill(0, opacity * 0.3);
            rect(2, 3, button.width, button.height, button.height/2);
          }
          
          // Dibujar fondo del botón con forma de píldora
          if (accessManager.highContrastMode) {
            stroke(255, opacity);
            strokeWeight(3);
          } else {
            stroke(80, 100, 120, opacity);
            strokeWeight(1);
          }
          
          // Establecer color de relleno con opacidad de animación
          fill(red(baseColor), green(baseColor), blue(baseColor), opacity);
          rect(0, 0, button.width, button.height, button.height/2);
          
          // Dibujar texto con sombra
          textAlign(CENTER, CENTER);
          textSize(accessManager.getAdjustedTextSize(20));
          
          // Añadir sombra de texto
          if (!accessManager.highContrastMode && opacity > 150) {
            fill(0, opacity * 0.2);
            text(button.text, 1, 1);
          }
          
          // Dibujar texto principal
          fill(red(textColor), green(textColor), blue(textColor), opacity);
          text(button.text, 0, 0);
          
          popMatrix();
        }
      }
    }
    
    // Aviso de copyright en la parte inferior
    textSize(accessManager.getAdjustedTextSize(12));
    fill(accessManager.getTextColor(color(50, 50, 50)));
    textAlign(CENTER, BOTTOM);
    text("© 2025 EcoRunner Team", width/2, height - 20);
    
    popStyle();
  }
  
  // Aplicar ajustes de accesibilidad al botón
  void applyAccessibilityToButton(Button button) {
    // El nuevo diseño de botón maneja la accesibilidad internamente
    // durante la visualización. Solo necesita actualizar el color hover
    button.updateHoverColor();
  }
  
  // Pantalla de Instrucciones
  void displayInstructions() {
    pushStyle();
    rectMode(CORNER);
    
    // Obtener el color de fondo apropiado
    color bgColor = accessManager.getBackgroundColor(backgroundColor);
    background(bgColor);
    
    // Título
    textAlign(CENTER, CENTER);
    textSize(accessManager.getAdjustedTextSize(40));
    fill(accessManager.getTextColor(color(0, 100, 0)));
    text("Instrucciones", width/2, 50);
    
    // Texto de instrucciones
    textAlign(LEFT);
    textSize(accessManager.getAdjustedTextSize(16));
    fill(accessManager.getTextColor(color(50, 50, 50)));
    float textX = width/6;
    float textY = 100;
    float lineHeight = accessManager.getAdjustedTextSize(30);
    
    text("CONTROLES:", textX, textY);
    textY += lineHeight;
    
    // Mostrar instrucciones de control apropiadas según configuración
    if (accessManager.alternativeControls) {
      text("• J KEY - Saltar obstáculos", textX, textY);
      textY += lineHeight;
      text("• S KEY - Deslizarse bajo obstáculos altos", textX, textY);
    } else {
      text("• SPACEBAR - Saltar obstáculos", textX, textY);
      textY += lineHeight;
      text("• DOWN ARROW - Deslizarse bajo obstáculos altos", textX, textY);
    }
    textY += lineHeight;
    text("• P - Pausar juego", textX, textY);
    textY += lineHeight * 1.5;
    
    text("OBJETIVOS:", textX, textY);
    textY += lineHeight;
    text("• Recoge los objetos ecológicos (verdes) para mejorar la salud ambiental", textX, textY);
    textY += lineHeight;
    text("• Evita los objetos contaminantes (rojo oscuro) para mantener el estado ambiental", textX, textY);
    textY += lineHeight;
    text("• ¡El estado del medio ambiente afecta la dificultad y la puntuación del juego!", textX, textY);
    textY += lineHeight * 1.5;

    // Dibujar ilustraciones simples
    drawControlsIllustration(width * 3/4, 150);
    drawItemsIllustration(width * 3/4, 300);
    
    // Dibujar botón de regreso con ajustes de accesibilidad
    for (Button button : instructionsButtons) {
      applyAccessibilityToButton(button);
      button.display();
    }
    
    popStyle();
  }
  
  // Pantalla de Configuración
  void displaySettings() {
    pushStyle();
    rectMode(CORNER);
    
    // Obtener el color de fondo apropiado
    color bgColor = accessManager.getBackgroundColor(backgroundColor);
    background(bgColor);
    
    // Título
    textAlign(CENTER, CENTER);
    textSize(accessManager.getAdjustedTextSize(40));
    fill(accessManager.getTextColor(color(0, 100, 0)));
    text("Configuración", width/2, 50);
    
    // Dibujar botones de configuración con ajustes de accesibilidad
    for (int i = 0; i < settingsButtons.size(); i++) {
      Button button = settingsButtons.get(i);
      
      // Si este es el botón de título "Accessibility Options", estilizarlo diferente
      if (button.text.equals("Accessibility Options")) {
        // Solo dibujar el texto como encabezado de sección
        pushStyle();
        textAlign(CENTER, CENTER);
        textSize(accessManager.getAdjustedTextSize(30));
        fill(accessManager.getTextColor(color(100, 0, 100)));
        text("Accessibility Options", width/2, button.y);
        
        // Dibujar línea separadora
        stroke(accessManager.getTextColor(color(150, 150, 150)));
        strokeWeight(2);
        line(width/4, button.y + 30, width*3/4, button.y + 30);
        popStyle();
      } else {
        // Botón regular
        applyAccessibilityToButton(button);
        button.display();
      }
    }
    
    // Mostrar explicación para la opción de accesibilidad seleccionada actualmente
    if (selectedMenuItem >= 3 && selectedMenuItem < settingsButtons.size() - 1) {
      displayAccessibilityExplanation(selectedMenuItem);
    }
    
    popStyle();
  }
  
  // Pantalla del Menú de Accesibilidad - redirige a configuración
  void displayAccessibilityMenu() {
    // Este método se mantiene para compatibilidad con versiones anteriores
    // Ahora simplemente redirige al menú de configuración
    stateManager.setState(STATE_SETTINGS);
    // Posicionar cursor en el primer ajuste de accesibilidad
    selectedMenuItem = 3; 
    updateSelectedItem();
    displaySettings();
  }
  
  // Mostrar explicación para la opción de accesibilidad
  void displayAccessibilityExplanation(int optionIndex) {
    // Mapear el índice a la opción de accesibilidad real basada en el diseño del menú de configuración
    // settingsButtons[0] = Sound, settingsButtons[1] = Music, settingsButtons[2] = Accessibility Title
    // settingsButtons[3] = High Contrast, settingsButtons[4] = Color Blind, settingsButtons[5] = Keyboard Nav  
    int accessibilityOption = optionIndex - 3; // Ajustar por la posición en el menú de configuración
    
    if (accessibilityOption < 0 || accessibilityOption >= 3) return; // Solo 3 opciones de accesibilidad ahora
    
    pushStyle();
    rectMode(CORNER);
    color boxColor = accessManager.highContrastMode ? color(50, 50, 50, 200) : color(0, 0, 0, 150);
    fill(boxColor);
    rect(20, height - 100, width - 40, 40);
    
    textAlign(LEFT, CENTER);
    textSize(accessManager.getAdjustedTextSize(14));
    fill(accessManager.getTextColor(color(255)));
    
    String explanation = "";
    switch(accessibilityOption) {
      case 0: 
        explanation = "Modo de Alto Contraste: Mejora la visibilidad usando colores con mayor contraste";
        break;
      case 1:
        explanation = "Modo Daltónico: Usa una paleta de colores diseñada para deficiencias en la visión de colores";
        break;
      case 2:
        explanation = "Navegación por Teclado: Navega por todos los menús usando el teclado (flechas, tab, enter)";
        break;
    }
    
    text(explanation, 30, height - 80);
    popStyle();
  }
  
  // Pantalla del Menú de Pausa
  void displayPauseMenu() {
    pushStyle();
    rectMode(CORNER);
    
    // Superposición semi-transparente con color apropiado
    fill(accessManager.highContrastMode ? color(0, 0, 0, 200) : overlayColor);
    rect(0, 0, width, height);
    
    // Panel de fondo para el contenido del menú de pausa
    rectMode(CENTER);
    if (accessManager.highContrastMode) {
      fill(0);
      stroke(255, 255, 0);
      strokeWeight(3);
      rect(width/2, height/2, 340, 400, 15);
    } else {
      noStroke();
      fill(0, 0, 0, 150);
      rect(width/2, height/2, 340, 400, 15);
    }
    
    // Título
    textAlign(CENTER, CENTER);
    textSize(accessManager.getAdjustedTextSize(40));
    fill(accessManager.getTextColor(color(255)));
    text("Paused Game", width/2, height/2 - 220);
    
    // Línea divisoria bajo el título
    if (accessManager.highContrastMode) {
      stroke(255, 255, 0);
      strokeWeight(2);
    } else {
      stroke(200, 200, 200, 180);
      strokeWeight(1);
    }
    line(width/2 - 150, height/2 - 180, width/2 + 150, height/2 - 180);
    
    // Dibujar botones del menú de pausa con ajustes de accesibilidad
    for (Button button : pauseMenuButtons) {
      applyAccessibilityToButton(button);
      button.display();
    }
    
    popStyle();
  }
  
  // Pantalla de Opciones de Fin de Juego
  void displayGameOverOptions() {
    pushStyle();
    rectMode(CORNER);
    
    // UI adicional de fin de juego (la superposición principal la dibuja la clase Game)
    
    // Panel de fondo para la pantalla de game over (centrado verticalmente)
    rectMode(CENTER);
    if (accessManager.highContrastMode) {
      fill(0);
      stroke(255, 255, 0);
      strokeWeight(3);
      rect(width/2, height/2, 400, 400, 15);
    } else {
      noStroke();
      fill(0, 0, 0, 150);
      rect(width/2, height/2, 400, 400, 15);
    }
    
    // Título Game Over (centrado)
    textAlign(CENTER, CENTER);
    textSize(accessManager.getAdjustedTextSize(50));
    fill(accessManager.getTextColor(color(255, 50, 50)));
    text("Game Over", width/2, height/2 - 100);
    
    // Línea divisoria decorativa (centrada)
    if (accessManager.highContrastMode) {
      stroke(255, 255, 0);
      strokeWeight(2);
    } else {
      stroke(200, 200, 200, 180);
      strokeWeight(1);
    }
    line(width/2 - 150, height/2 - 20, width/2 + 150, height/2 - 20);
    
    // Dibujar botones de fin de juego con ajustes de accesibilidad
    for (Button button : gameOverButtons) {
      applyAccessibilityToButton(button);
      button.display();
    }
    
    popStyle();
  }
  
  // Ilustraciones simples de controles ajustadas para accesibilidad
  void drawControlsIllustration(float x, float y) {
    fill(accessManager.getForegroundColor(color(0)));
    stroke(accessManager.getForegroundColor(color(0)));
    rectMode(CENTER);
    
    // Barra SPACE o tecla J según controles alternativos
    rect(x, y, 100, 30, 5);
    fill(accessManager.getTextColor(color(255)));
    textAlign(CENTER, CENTER);
    textSize(accessManager.getAdjustedTextSize(14));
    text(accessManager.alternativeControls ? "J" : "SPACE", x, y);
    
    // Flecha abajo o tecla S según controles alternativos
    fill(accessManager.getForegroundColor(color(0)));
    rect(x, y + 40, 30, 30, 5);
    fill(accessManager.getTextColor(color(255)));
    text(accessManager.alternativeControls ? "S" : "↓", x, y + 40);
  }
  
  // Ilustraciones simples de objetos
  void drawItemsIllustration(float x, float y) {
    // Objeto eco verde
    fill(accessManager.getForegroundColor(color(30, 150, 30)));
    ellipse(x - 40, y, 30, 30);
    
    // Objeto contaminación rojo
    fill(accessManager.getForegroundColor(color(150, 30, 30)));
    ellipse(x + 40, y, 30, 30);
  }
  
  // Obtener el número de elementos de menú para el estado actual
  int getMenuItemCount(int state) {
    ArrayList<Button> buttonList = getButtonListForState(state);
    return buttonList != null ? buttonList.size() : 0;
  }
  
  void display() {
    // Resetear cualquier botón resaltado al cambiar de menús
    unhighlightAllButtons();
    
    int currentState = getGameState();
    switch(currentState) {
      case STATE_MAIN_MENU:
        displayMainMenu();
        break;
      case STATE_INSTRUCTIONS:
        displayInstructions();
        break;
      case STATE_SETTINGS:
        displaySettings();
        break;
      case STATE_ACCESSIBILITY:
        displayAccessibilityMenu();
        break;
      case STATE_PAUSED:
        displayPauseMenu();
        break;
      case STATE_GAME_OVER:
        displayGameOverOptions();
        break;
    }
    
    // Asegurarse de que un botón esté seleccionado si se usa navegación por teclado
    if (accessManager.keyboardOnly && currentButtonList.size() > 0) {
      currentSelectedButton = constrain(currentSelectedButton, 0, currentButtonList.size() - 1);
      currentButtonList.get(currentSelectedButton).setHighlighted(true);
    }
  }
  
  // Manejar entrada de teclado para navegación de menú
  void handleKeyPress(char key, int keyCode) {
    if (currentButtonList.size() == 0) return;
    
    // Si se presiona flecha arriba o 'w'
    if (keyCode == UP || key == 'w' || key == 'W') {
      unhighlightAllButtons();
      currentSelectedButton--;
      if (currentSelectedButton < 0) {
        currentSelectedButton = currentButtonList.size() - 1;
      }
      // Aplicar efectos de resaltado y hover
      Button selectedButton = currentButtonList.get(currentSelectedButton);
      selectedButton.setHighlighted(true);
      // También simular efecto hover con teclado
      selectedButton.applyKeyboardHoverEffect(true);
    }
    
    // Si se presiona flecha abajo o 's'
    if (keyCode == DOWN || key == 's' || key == 'S') {
      unhighlightAllButtons();
      currentSelectedButton++;
      if (currentSelectedButton >= currentButtonList.size()) {
        currentSelectedButton = 0;
      }
      // Aplicar efectos de resaltado y hover
      Button selectedButton = currentButtonList.get(currentSelectedButton);
      selectedButton.setHighlighted(true);
      // También simular efecto hover con teclado
      selectedButton.applyKeyboardHoverEffect(true);
    }
    
    // Si se presiona flecha derecha o 'd' (para navegación horizontal)
    if ((keyCode == RIGHT || key == 'd' || key == 'D') && 
        (getGameState() == STATE_MAIN_MENU)) {
      unhighlightAllButtons();
      currentSelectedButton++;
      if (currentSelectedButton >= currentButtonList.size()) {
        currentSelectedButton = 0;
      }
      // Aplicar efectos de resaltado y hover
      Button selectedButton = currentButtonList.get(currentSelectedButton);
      selectedButton.setHighlighted(true);
      // También simular efecto hover con teclado
      selectedButton.applyKeyboardHoverEffect(true);
    }
    
    // Si se presiona flecha izquierda o 'a' (para navegación horizontal)
    if ((keyCode == LEFT || key == 'a' || key == 'A') && 
        (getGameState() == STATE_MAIN_MENU)) {
      unhighlightAllButtons();
      currentSelectedButton--;
      if (currentSelectedButton < 0) {
        currentSelectedButton = currentButtonList.size() - 1;
      }
      // Aplicar efectos de resaltado y hover
      Button selectedButton = currentButtonList.get(currentSelectedButton);
      selectedButton.setHighlighted(true);
      // También simular efecto hover con teclado
      selectedButton.applyKeyboardHoverEffect(true);
    }
    
    // Si se presiona enter o espacio
    if (keyCode == ENTER || keyCode == RETURN || key == ' ') {
      if (currentButtonList.size() > 0) {
        // Simular un clic en el botón seleccionado
        clickButton(currentButtonList.get(currentSelectedButton));
      }
    }
  }
  
  // Método auxiliar para quitar el resaltado de todos los botones
  void unhighlightAllButtons() {
    // Quitar todos los resaltados
    for (Button button : mainMenuButtons) {
      button.setHighlighted(false);
      button.applyKeyboardHoverEffect(false);
    }
    for (Button button : instructionsButtons) {
      button.setHighlighted(false);
      button.applyKeyboardHoverEffect(false);
    }
    for (Button button : settingsButtons) {
      button.setHighlighted(false);
      button.applyKeyboardHoverEffect(false);
    }
    for (Button button : pauseMenuButtons) {
      button.setHighlighted(false);
      button.applyKeyboardHoverEffect(false);
    }
    for (Button button : gameOverButtons) {
      button.setHighlighted(false);
      button.applyKeyboardHoverEffect(false);
    }
  }
  
  // Método auxiliar para hacer clic en un botón
  boolean clickButton(Button button) {
    if (button == null || stateManager == null) return false;
    
    // Primero, encontrar qué lista contiene este botón
    String buttonText = button.text;
    
    // Manejar botones del menú principal
    if (buttonText.equals("Play")) {
      stateManager.setState(STATE_GAME);
      game.reset();
    } else if (buttonText.equals("Instructions")) {
      stateManager.setState(STATE_INSTRUCTIONS);
      selectedMenuItem = 0;
    } else if (buttonText.equals("Settings")) {
      stateManager.setState(STATE_SETTINGS);
      selectedMenuItem = 0;
    } else if (buttonText.equals("Exit")) {
      exit();
    }
    // Manejar botones de instrucciones
    else if (buttonText.equals("Back")) {
      if (getGameState() == STATE_INSTRUCTIONS || getGameState() == STATE_SETTINGS || getGameState() == STATE_ACCESSIBILITY) {
        stateManager.setState(STATE_MAIN_MENU);
        selectedMenuItem = 0;
      }
    }
    // Manejar botones de configuración
    else if (buttonText.startsWith("Sound:")) {
      // Alternar sonido
      String newText = buttonText.contains("ON") ? "Sound: OFF" : "Sound: ON";
      for (Button b : settingsButtons) {
        if (b.text.startsWith("Sound:")) b.text = newText;
      }
      // TODO: Implementar alternancia real de sonido
    } else if (buttonText.startsWith("Music:")) {
      // Alternar música
      String newText = buttonText.contains("ON") ? "Music: OFF" : "Music: ON";
      for (Button b : settingsButtons) {
        if (b.text.startsWith("Music:")) b.text = newText;
      }
      // TODO: Implementar alternancia real de música
    } 
    // Manejar opciones de accesibilidad en menú de configuración
    else if (buttonText.startsWith("High Contrast:")) {
      accessManager.toggleHighContrastMode();
      updateAccessibilityButtonText();
    } else if (buttonText.startsWith("Color Blind Mode:")) {
      accessManager.toggleColorBlindMode();
      updateAccessibilityButtonText();
    } else if (buttonText.startsWith("Keyboard Navigation:")) {
      // Alternar navegación por teclado
      boolean oldValue = accessManager.keyboardOnly;
      accessManager.toggleKeyboardOnly();
      
      // Si acabamos de activar la navegación por teclado, asegurarse de que un botón esté resaltado
      if (!oldValue && accessManager.keyboardOnly) {
        // Asegurar que tenemos un botón resaltado
        updateSelectedItem();
      }
      
      updateAccessibilityButtonText();
    }
    // Manejar botones del menú de pausa
    else if (buttonText.equals("Resume")) {
      stateManager.setState(STATE_GAME);
    } else if (buttonText.equals("Restart")) {
      game.reset();
      stateManager.setState(STATE_GAME);
    } else if (buttonText.equals("Main Menu")) {
      stateManager.setState(STATE_MAIN_MENU);
      selectedMenuItem = 0;
    }
    
    // Reproducir efecto de sonido para activación de botón
    soundManager.playButtonSound();
    
    return true;
  }
  
  // Manejar clic en menú principal
  void handleMainMenuClick() {
    // Solo procesar clics si no estamos en modo solo-teclado
    if (!accessManager.keyboardOnly) {
      checkButtonClicks(mainMenuButtons);
    }
  }
  
  // Manejar clic en instrucciones
  void handleInstructionsClick() {
    // Solo procesar clics si no estamos en modo solo-teclado
    if (!accessManager.keyboardOnly) {
      checkButtonClicks(instructionsButtons);
    }
  }
  
  // Manejar clic en configuración
  void handleSettingsClick() {
    // Solo procesar clics si no estamos en modo solo-teclado
    if (!accessManager.keyboardOnly) {
      checkButtonClicks(settingsButtons);
    }
  }
  
  // Manejar clic en menú de pausa
  void handlePauseMenuClick() {
    // Solo procesar clics si no estamos en modo solo-teclado
    if (!accessManager.keyboardOnly) {
      checkButtonClicks(pauseMenuButtons);
    }
  }
  
  // Manejar clic en fin de juego
  void handleGameOverClick() {
    // Solo procesar clics si no estamos en modo solo-teclado
    if (!accessManager.keyboardOnly) {
      checkButtonClicks(gameOverButtons);
    }
  }
  
  // Manejar clic en menú de accesibilidad
  void handleAccessibilityMenuClick() {
    // Solo procesar clics si no estamos en modo solo-teclado
    if (!accessManager.keyboardOnly) {
      checkButtonClicks(settingsButtons);
    }
  }
  
  // Manejador genérico de clics en botones
  void checkButtonClicks(ArrayList<Button> buttons) {
    for (int i = 0; i < buttons.size(); i++) {
      Button button = buttons.get(i);
      if (button.isClicked()) {
        // Activar la acción del botón
        activateButton(button);
        return;
      }
    }
  }
  
  // Activar un botón (delega a clickButton)
  void activateButton(Button button) {
    if (button == null) return;
    
    // Realizar la acción del botón
    clickButton(button);
  }
  
  // Activar elementos de menú con teclado (usado desde el programa principal)
  void activateMainMenuItem(int index) {
    if (index >= 0 && index < mainMenuButtons.size()) {
      activateButton(mainMenuButtons.get(index));
    }
  }

  void activateInstructionsItem(int index) {
    if (index >= 0 && index < instructionsButtons.size()) {
      activateButton(instructionsButtons.get(index));
    }
  }

  void activateSettingsItem(int index) {
    if (index >= 0 && index < settingsButtons.size()) {
      activateButton(settingsButtons.get(index));
    }
  }

  void activateAccessibilityItem(int index) {
    // Esta función ya no se usa
  }

  void activatePauseMenuItem(int index) {
    if (index >= 0 && index < pauseMenuButtons.size()) {
      activateButton(pauseMenuButtons.get(index));
    }
  }

  void activateGameOverItem(int index) {
    if (index >= 0 && index < gameOverButtons.size()) {
      activateButton(gameOverButtons.get(index));
    }
  }
  
  // Limpia selección de teclado de todos los botones
  void clearKeyboardSelection() {
    // Solo deshabilitar selección de teclado si no estamos en modo solo-teclado
    if (!accessManager.keyboardOnly) {
      // Quitar resaltado de todos los botones
      unhighlightAllButtons();
      
      // Resetear el índice de selección actual
      currentSelectedButton = -1;
    }
  }
  
  // Actualizar texto de botones de configuración para reflejar configuración actual
  void updateSettingsButtonText() {
    // Encontrar y actualizar botones de opciones de accesibilidad
    for (Button button : settingsButtons) {
      // Actualizar toggle de Alto Contraste
      if (button.text.startsWith("High Contrast:")) {
        button.text = "High Contrast: " + (accessManager.highContrastMode ? "ON" : "OFF");
      }
      // Actualizar toggle de Modo Daltónico
      else if (button.text.startsWith("Color Blind Mode:")) {
        button.text = "Color Blind Mode: " + (accessManager.colorBlindMode ? "ON" : "OFF");
      }
      // Actualizar toggle de Navegación por Teclado
      else if (button.text.startsWith("Keyboard Navigation:")) {
        button.text = "Keyboard Navigation: " + (accessManager.keyboardOnly ? "ON" : "OFF");
      }
    }
  }

  // Activar el elemento de menú seleccionado actualmente
  void activateSelectedMenuItem() {
    switch(getGameState()) {
      case STATE_MAIN_MENU:
        this.activateMainMenuItem(selectedMenuItem);
        break;
      case STATE_INSTRUCTIONS:
        this.activateInstructionsItem(selectedMenuItem);
        break;
      case STATE_SETTINGS:
        this.activateSettingsItem(selectedMenuItem);
        break;
      case STATE_PAUSED:
        this.activatePauseMenuItem(selectedMenuItem);
        break;
      case STATE_GAME_OVER:
        this.activateGameOverItem(selectedMenuItem);
        break;
    }
  }
}  