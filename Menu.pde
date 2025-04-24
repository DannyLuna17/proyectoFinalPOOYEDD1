/**
 * Menu class - Handles the UI and different screens
 * Main menu, instructions, settings, pause menu and game over screens
 */
class Menu {
  // Menu components
  ArrayList<Button> mainMenuButtons;
  ArrayList<Button> instructionsButtons;
  ArrayList<Button> settingsButtons;
  ArrayList<Button> pauseMenuButtons;
  ArrayList<Button> gameOverButtons;
  
  // Visual properties
  color backgroundColor;
  color overlayColor;
  PImage menuBackground;
  PImage logo;
  
  // Animation properties
  float titleScale = 1.0;
  float titleScaleDirection = 0.0005;
  
  // Menu navigation
  ArrayList<Button> currentActiveButtons; // Reference to currently active button list
  
  // Variables for keyboard navigation
  int currentSelectedButton = 0;
  ArrayList<Button> currentButtonList = new ArrayList<Button>();
  
  Menu() {
    // Initialize button lists
    initializeButtons();
    
    // Set default colors
    backgroundColor = color(80, 150, 200);
    overlayColor = color(0, 0, 0, 150);
    
    // Set the current active buttons to main menu initially
    currentActiveButtons = mainMenuButtons;
    
    // Load images (placeholders for now)
    // menuBackground = loadImage("background.png");
    // logo = loadImage("logo.png");
    
    // Update settings button text based on current accessibility settings
    updateSettingsButtonText();
  }
  
  void initializeButtons() {
    // Calculate consistent horizontal spacing for buttons in a row
    float buttonWidth = 220; // Slightly wider to accommodate the pill shape
    float buttonHeight = 60; // Slightly taller for better proportions
    float spacing = 25; // Space between buttons
    
    // Calculate total width for 4 buttons (3 spaces between them)
    float totalWidth = (buttonWidth * 4) + (spacing * 3);
    // Position to start the row (centered properly)
    float startX = (width - totalWidth) / 2;
    
    float buttonY = height * 0.85; // Position buttons in the lower part of the screen
    
    // Main menu buttons - in a horizontal row with new styling (properly centered)
    mainMenuButtons = new ArrayList<Button>();
    mainMenuButtons.add(new Button(startX + (buttonWidth/2), buttonY, buttonWidth, buttonHeight, "Play"));
    mainMenuButtons.add(new Button(startX + buttonWidth + spacing + (buttonWidth/2), buttonY, buttonWidth, buttonHeight, "Instructions"));
    mainMenuButtons.add(new Button(startX + 2 * (buttonWidth + spacing) + (buttonWidth/2), buttonY, buttonWidth, buttonHeight, "Settings"));
    mainMenuButtons.add(new Button(startX + 3 * (buttonWidth + spacing) + (buttonWidth/2), buttonY, buttonWidth, buttonHeight, "Exit"));
    
    // Instructions screen buttons
    instructionsButtons = new ArrayList<Button>();
    instructionsButtons.add(new Button(width/2, height - 50, 220, 60, "Back"));
    
    // Increased vertical spacing for settings buttons
    float verticalSpacing = 80; // Increased from implicit 60 pixels
    
    // Settings screen buttons
    settingsButtons = new ArrayList<Button>();
    settingsButtons.add(new Button(width/2, height/2 - 260, 220, 60, "Sound: ON"));
    settingsButtons.add(new Button(width/2, height/2 - 260 + verticalSpacing, 220, 60, "Music: ON"));
    
    // Accessibility section title - with more space before it
    settingsButtons.add(new Button(width/2, height/2 - 260 + (verticalSpacing * 2) + 20, 320, 60, "Accessibility Options"));
    
    // Accessibility options (moved from accessibilityButtons) - with increased spacing
    settingsButtons.add(new Button(width/2, height/2 - 260 + (verticalSpacing * 3) + 20, 320, 60, "High Contrast: OFF"));
    settingsButtons.add(new Button(width/2, height/2 - 260 + (verticalSpacing * 4) + 20, 320, 60, "Color Blind Mode: OFF"));
    // settingsButtons.add(new Button(width/2, height/2 - 260 + (verticalSpacing * 5) + 20, 320, 60, "Keyboard Navigation: OFF"));
    
    // Back button at the bottom
    settingsButtons.add(new Button(width/2, height - 50, 220, 60, "Back"));
    
    // Pause menu buttons
    pauseMenuButtons = new ArrayList<Button>();
    pauseMenuButtons.add(new Button(width/2, height/2 - 40, 220, 60, "Resume"));
    pauseMenuButtons.add(new Button(width/2, height/2 + 20, 220, 60, "Restart"));
    pauseMenuButtons.add(new Button(width/2, height/2 + 80, 220, 60, "Main Menu"));
    
    // Game over buttons
    gameOverButtons = new ArrayList<Button>();
    gameOverButtons.add(new Button(width/2, height - 80, 220, 60, "Restart"));
    gameOverButtons.add(new Button(width/2, height - 20, 220, 60, "Main Menu"));
  }
  
  // Update the currently selected item in the appropriate menu
  void updateSelectedItem(int state, int selectedIndex) {
    // Get the correct button list for the current state
    ArrayList<Button> buttonList = getButtonListForState(state);
    
    // Clear all highlights first
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
    
    // Set the highlight for the selected button if valid
    if (buttonList != null && selectedIndex >= 0 && selectedIndex < buttonList.size()) {
      Button selectedButton = buttonList.get(selectedIndex);
      selectedButton.setHighlighted(true);
      // Apply hover effect for keyboard navigation too
      selectedButton.applyKeyboardHoverEffect(true);
    }
    
    // Store reference to current active buttons
    currentActiveButtons = buttonList;
  }
  
  // Get the appropriate button list for a game state
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
  
  // Update accessibility button text to reflect current settings
  void updateAccessibilityButtonText() {
    // This function is replaced by updateSettingsButtonText()
    // It remains here for backward compatibility with any existing calls
    updateSettingsButtonText();
  }
  
  // Main Menu Display - refactored to remove title drawing and update button layout
  void displayMainMenu() {
    // Reset drawing settings
    pushStyle();
    rectMode(CENTER);
    
    // Display the menu background image from videoIntroMenu (no title drawing)
    if (videoIntroMenu != null && videoIntroMenu.finalBackground != null) {
      // Display the menu final background (which already contains the title)
      image(videoIntroMenu.finalBackground, 0, 0, width, height);
    } else {
      // Fallback to color background if image is not available
      color bgColor = accessManager.getBackgroundColor(backgroundColor);
      background(bgColor);
    }
    
    // Draw buttons with proper animation if they're being revealed
    if (videoIntroMenu != null && videoIntroMenu.isComplete()) {
      // If video intro is complete, display buttons normally
      for (Button button : mainMenuButtons) {
        button.display();
      }
    } else if (videoIntroMenu != null) {
      // Let the video intro handle button animations
      videoIntroMenu.displayAnimatedButtons();
    } else {
      // Fallback for when videoIntroMenu is null - simple fade in
      float fadeInProgress = min(frameCount / 60.0, 1.0); // Simple 1-second fade in
      for (int i = 0; i < mainMenuButtons.size(); i++) {
        Button button = mainMenuButtons.get(i);
        // Add a slight delay for each button
        float buttonDelay = i * 0.035;
        float buttonProgress = constrain(fadeInProgress - buttonDelay, 0, 1);
        
        if (buttonProgress > 0) {
          // Apply fade-in and scale effects similar to VideoIntroMenu
          pushMatrix();
          translate(button.x, button.y);
          
          // Apply scale animation
          float scale = buttonProgress;
          scale(scale);
          
          // Get the button's colors with accessibility adjustments
          color baseColor = accessManager.adjustButtonColor(button.baseColor);
          color hoverColor = accessManager.adjustButtonHoverColor(button.hoverColor);
          color textColor = accessManager.adjustTextColor(button.textColor);
          
          // Set opacity based on progress
          float opacity = buttonProgress * 255;
          
          // Draw drop shadow
          if (!accessManager.highContrastMode && !accessManager.reduceAnimations) {
            noStroke();
            fill(0, opacity * 0.3);
            rect(2, 3, button.w, button.h, button.h/2);
          }
          
          // Draw button background with pill shape
          if (accessManager.highContrastMode) {
            stroke(255, opacity);
            strokeWeight(3);
          } else {
            stroke(80, 100, 120, opacity);
            strokeWeight(1);
          }
          
          // Set fill color with animation opacity
          fill(red(baseColor), green(baseColor), blue(baseColor), opacity);
          rect(0, 0, button.w, button.h, button.h/2);
          
          // Draw text with shadow
          textAlign(CENTER, CENTER);
          textSize(accessManager.getAdjustedTextSize(20));
          
          // Add text shadow 
          if (!accessManager.highContrastMode && opacity > 150) {
            fill(0, opacity * 0.2);
            text(button.text, 1, 1);
          }
          
          // Draw main text
          fill(red(textColor), green(textColor), blue(textColor), opacity);
          text(button.text, 0, 0);
          
          popMatrix();
        }
      }
    }
    
    // Copyright notice at the bottom
    textSize(accessManager.getAdjustedTextSize(12));
    fill(accessManager.getTextColor(color(50, 50, 50)));
    textAlign(CENTER, BOTTOM);
    text("© 2025 EcoRunner Team", width/2, height - 20);
    
    popStyle();
  }
  
  // Apply accessibility adjustments to button
  void applyAccessibilityToButton(Button button) {
    // The new button design handles accessibility internally
    // during display. Just need to update the hover color
    button.updateHoverColor();
  }
  
  // Instructions Screen Display
  void displayInstructions() {
    pushStyle();
    rectMode(CORNER);
    
    // Get the appropriate background color
    color bgColor = accessManager.getBackgroundColor(backgroundColor);
    background(bgColor);
    
    // Title
    textAlign(CENTER, CENTER);
    textSize(accessManager.getAdjustedTextSize(40));
    fill(accessManager.getTextColor(color(0, 100, 0)));
    text("Instructions", width/2, 50);
    
    // Instructions text
    textAlign(LEFT);
    textSize(accessManager.getAdjustedTextSize(16));
    fill(accessManager.getTextColor(color(50, 50, 50)));
    float textX = width/6;
    float textY = 100;
    float lineHeight = accessManager.getAdjustedTextSize(30);
    
    text("CONTROLS:", textX, textY);
    textY += lineHeight;
    
    // Show appropriate control instructions based on settings
    if (accessManager.alternativeControls) {
      text("• J KEY - Jump over obstacles", textX, textY);
      textY += lineHeight;
      text("• S KEY - Slide under tall obstacles", textX, textY);
    } else {
      text("• SPACEBAR - Jump over obstacles", textX, textY);
      textY += lineHeight;
      text("• DOWN ARROW - Slide under tall obstacles", textX, textY);
    }
    textY += lineHeight;
    text("• P - Pause game", textX, textY);
    textY += lineHeight * 1.5;
    
    text("OBJECTIVES:", textX, textY);
    textY += lineHeight;
    text("• Collect eco-friendly items (green) to improve environmental health", textX, textY);
    textY += lineHeight;
    text("• Avoid pollution items (dark red) to maintain environmental status", textX, textY);
    textY += lineHeight;
    text("• The state of the environment affects gameplay difficulty and scoring!", textX, textY);
    textY += lineHeight * 1.5;

    // Draw simple illustrations
    drawControlsIllustration(width * 3/4, 150);
    drawItemsIllustration(width * 3/4, 300);
    
    // Draw back button with accessibility adjustments
    for (Button button : instructionsButtons) {
      applyAccessibilityToButton(button);
      button.display();
    }
    
    popStyle();
  }
  
  // Settings Screen Display
  void displaySettings() {
    pushStyle();
    rectMode(CORNER);
    
    // Get the appropriate background color
    color bgColor = accessManager.getBackgroundColor(backgroundColor);
    background(bgColor);
    
    // Title
    textAlign(CENTER, CENTER);
    textSize(accessManager.getAdjustedTextSize(40));
    fill(accessManager.getTextColor(color(0, 100, 0)));
    text("Settings", width/2, 50);
    
    // Draw settings buttons with accessibility adjustments
    for (int i = 0; i < settingsButtons.size(); i++) {
      Button button = settingsButtons.get(i);
      
      // If this is the "Accessibility Options" title button, style it differently
      if (button.text.equals("Accessibility Options")) {
        // Just draw the text as a section header
        pushStyle();
        textAlign(CENTER, CENTER);
        textSize(accessManager.getAdjustedTextSize(30));
        fill(accessManager.getTextColor(color(100, 0, 100)));
        text("Accessibility Options", width/2, button.y);
        
        // Draw a separator line
        stroke(accessManager.getTextColor(color(150, 150, 150)));
        strokeWeight(2);
        line(width/4, button.y + 30, width*3/4, button.y + 30);
        popStyle();
      } else {
        // Regular button
        applyAccessibilityToButton(button);
        button.display();
      }
    }
    
    // Display explanation for the currently selected accessibility option
    if (selectedMenuItem >= 3 && selectedMenuItem < settingsButtons.size() - 1) {
      displayAccessibilityExplanation(selectedMenuItem);
    }
    
    popStyle();
  }
  
  // Accessibility Menu Display - redirects to settings
  void displayAccessibilityMenu() {
    // This method is kept for backward compatibility 
    // Now this simply redirects to the settings menu
    gameState = STATE_SETTINGS;
    // Position cursor at first accessibility setting
    selectedMenuItem = 3; 
    updateSelectedItem(gameState, selectedMenuItem);
    displaySettings();
  }
  
  // Display explanation for the accessibility option
  void displayAccessibilityExplanation(int optionIndex) {
    // Map the index to the actual accessibility option based on settings menu layout
    // settingsButtons[0] = Sound, settingsButtons[1] = Music, settingsButtons[2] = Accessibility Title
    // settingsButtons[3] = High Contrast, settingsButtons[4] = Color Blind, settingsButtons[5] = Keyboard Nav  
    int accessibilityOption = optionIndex - 3; // Adjust for the position in settings menu
    
    if (accessibilityOption < 0 || accessibilityOption >= 3) return; // Only 3 accessibility options now
    
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
        explanation = "High Contrast Mode: Improves visibility by using stronger color contrast";
        break;
      case 1:
        explanation = "Color Blind Mode: Uses a color palette designed for color vision deficiencies";
        break;
      case 2:
        explanation = "Keyboard Navigation: Navigate all menus using keyboard (arrow keys, tab, enter)";
        break;
    }
    
    text(explanation, 30, height - 80);
    popStyle();
  }
  
  // Pause Menu Display
  void displayPauseMenu() {
    pushStyle();
    rectMode(CORNER);
    
    // Semi-transparent overlay with appropriate color
    fill(accessManager.highContrastMode ? color(0, 0, 0, 200) : overlayColor);
    rect(0, 0, width, height);
    
    // Title
    textAlign(CENTER, CENTER);
    textSize(accessManager.getAdjustedTextSize(40));
    fill(accessManager.getTextColor(color(255)));
    text("Game Paused", width/2, 80);
    
    // Draw pause menu buttons with accessibility adjustments
    for (Button button : pauseMenuButtons) {
      applyAccessibilityToButton(button);
      button.display();
    }
    
    popStyle();
  }
  
  // Game Over Options Display
  void displayGameOverOptions() {
    pushStyle();
    rectMode(CORNER);
    
    // Additional game over UI (main overlay is drawn by Game class)
    // Draw game over buttons with accessibility adjustments
    for (Button button : gameOverButtons) {
      applyAccessibilityToButton(button);
      button.display();
    }
    
    popStyle();
  }
  
  // Simple control illustrations adjusted for accessibility
  void drawControlsIllustration(float x, float y) {
    fill(accessManager.getForegroundColor(color(0)));
    stroke(accessManager.getForegroundColor(color(0)));
    rectMode(CENTER);
    
    // SPACE bar or J key based on alternative controls
    rect(x, y, 100, 30, 5);
    fill(accessManager.getTextColor(color(255)));
    textAlign(CENTER, CENTER);
    textSize(accessManager.getAdjustedTextSize(14));
    text(accessManager.alternativeControls ? "J" : "SPACE", x, y);
    
    // Down arrow or S key based on alternative controls
    fill(accessManager.getForegroundColor(color(0)));
    rect(x, y + 40, 30, 30, 5);
    fill(accessManager.getTextColor(color(255)));
    text(accessManager.alternativeControls ? "S" : "↓", x, y + 40);
  }
  
  // Simple items illustrations
  void drawItemsIllustration(float x, float y) {
    // Green eco item
    fill(accessManager.getForegroundColor(color(30, 150, 30)));
    ellipse(x - 40, y, 30, 30);
    
    // Red pollution item
    fill(accessManager.getForegroundColor(color(150, 30, 30)));
    ellipse(x + 40, y, 30, 30);
  }
  
  // Get the number of menu items for the current state
  int getMenuItemCount(int state) {
    ArrayList<Button> buttonList = getButtonListForState(state);
    return buttonList != null ? buttonList.size() : 0;
  }
  
  void display() {
    // Reset any highlighted buttons when switching menus
    unhighlightAllButtons();
    
    switch(gameState) {
      case STATE_MAIN_MENU:
        displayMainMenu();
        currentButtonList = mainMenuButtons;
        break;
      case STATE_INSTRUCTIONS:
        displayInstructions();
        currentButtonList = instructionsButtons;
        break;
      case STATE_SETTINGS:
        displaySettings();
        currentButtonList = settingsButtons;
        break;
      case STATE_PAUSED:
        displayPauseMenu();
        currentButtonList = pauseMenuButtons;
        break;
      case STATE_GAME_OVER:
        displayGameOverOptions();
        currentButtonList = gameOverButtons;
        break;
      case STATE_ACCESSIBILITY:
        displayAccessibilityMenu();
        currentButtonList = settingsButtons;
        break;
    }
    
    // Make sure a button is selected if using keyboard navigation
    if (accessManager.keyboardOnly && currentButtonList.size() > 0) {
      currentSelectedButton = constrain(currentSelectedButton, 0, currentButtonList.size() - 1);
      currentButtonList.get(currentSelectedButton).setHighlighted(true);
    }
  }
  
  // Handle keyboard input for menu navigation
  void handleKeyPress(char key, int keyCode) {
    if (currentButtonList.size() == 0) return;
    
    // If up arrow or 'w' is pressed
    if (keyCode == UP || key == 'w' || key == 'W') {
      unhighlightAllButtons();
      currentSelectedButton--;
      if (currentSelectedButton < 0) {
        currentSelectedButton = currentButtonList.size() - 1;
      }
      // Apply both highlight and hover effects
      Button selectedButton = currentButtonList.get(currentSelectedButton);
      selectedButton.setHighlighted(true);
      // Also simulate hover effect with keyboard
      selectedButton.applyKeyboardHoverEffect(true);
    }
    
    // If down arrow or 's' is pressed
    if (keyCode == DOWN || key == 's' || key == 'S') {
      unhighlightAllButtons();
      currentSelectedButton++;
      if (currentSelectedButton >= currentButtonList.size()) {
        currentSelectedButton = 0;
      }
      // Apply both highlight and hover effects
      Button selectedButton = currentButtonList.get(currentSelectedButton);
      selectedButton.setHighlighted(true);
      // Also simulate hover effect with keyboard
      selectedButton.applyKeyboardHoverEffect(true);
    }
    
    // If right arrow or 'd' is pressed (for horizontal navigation)
    if ((keyCode == RIGHT || key == 'd' || key == 'D') && 
        (gameState == STATE_MAIN_MENU)) {
      unhighlightAllButtons();
      currentSelectedButton++;
      if (currentSelectedButton >= currentButtonList.size()) {
        currentSelectedButton = 0;
      }
      // Apply both highlight and hover effects
      Button selectedButton = currentButtonList.get(currentSelectedButton);
      selectedButton.setHighlighted(true);
      // Also simulate hover effect with keyboard
      selectedButton.applyKeyboardHoverEffect(true);
    }
    
    // If left arrow or 'a' is pressed (for horizontal navigation)
    if ((keyCode == LEFT || key == 'a' || key == 'A') && 
        (gameState == STATE_MAIN_MENU)) {
      unhighlightAllButtons();
      currentSelectedButton--;
      if (currentSelectedButton < 0) {
        currentSelectedButton = currentButtonList.size() - 1;
      }
      // Apply both highlight and hover effects
      Button selectedButton = currentButtonList.get(currentSelectedButton);
      selectedButton.setHighlighted(true);
      // Also simulate hover effect with keyboard
      selectedButton.applyKeyboardHoverEffect(true);
    }
    
    // If enter or space is pressed
    if (keyCode == ENTER || keyCode == RETURN || key == ' ') {
      if (currentButtonList.size() > 0) {
        // Simulate a click on the selected button
        clickButton(currentButtonList.get(currentSelectedButton));
      }
    }
  }
  
  // Helper method to unhighlight all buttons
  void unhighlightAllButtons() {
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
  
  // Helper method to click a button
  void clickButton(Button button) {
    if (button == null) return;
    
    // First, find which list contains this button
    String buttonText = button.text;
    
    // Handle main menu buttons
    if (buttonText.equals("Play")) {
      gameState = STATE_GAME;
      game.reset();
    } else if (buttonText.equals("Instructions")) {
      gameState = STATE_INSTRUCTIONS;
      selectedMenuItem = 0;
    } else if (buttonText.equals("Settings")) {
      gameState = STATE_SETTINGS;
      selectedMenuItem = 0;
    } else if (buttonText.equals("Exit")) {
      exit();
    }
    // Handle instructions buttons
    else if (buttonText.equals("Back")) {
      if (gameState == STATE_INSTRUCTIONS || gameState == STATE_SETTINGS || gameState == STATE_ACCESSIBILITY) {
        gameState = STATE_MAIN_MENU;
        selectedMenuItem = 0;
      }
    }
    // Handle settings buttons
    else if (buttonText.startsWith("Sound:")) {
      // Toggle sound
      String newText = buttonText.contains("ON") ? "Sound: OFF" : "Sound: ON";
      for (Button b : settingsButtons) {
        if (b.text.startsWith("Sound:")) b.text = newText;
      }
      // TODO: Implement actual sound toggling
    } else if (buttonText.startsWith("Music:")) {
      // Toggle music
      String newText = buttonText.contains("ON") ? "Music: OFF" : "Music: ON";
      for (Button b : settingsButtons) {
        if (b.text.startsWith("Music:")) b.text = newText;
      }
      // TODO: Implement actual music toggling
    } 
    // Handle accessibility options in settings menu
    else if (buttonText.startsWith("High Contrast:")) {
      accessManager.toggleHighContrastMode();
      updateAccessibilityButtonText();
    } else if (buttonText.startsWith("Color Blind Mode:")) {
      accessManager.toggleColorBlindMode();
      updateAccessibilityButtonText();
    } else if (buttonText.startsWith("Keyboard Navigation:")) {
      // Toggle keyboard navigation
      boolean oldValue = accessManager.keyboardOnly;
      accessManager.toggleKeyboardOnly();
      
      // If we just turned on keyboard navigation, make sure a button is highlighted
      if (!oldValue && accessManager.keyboardOnly) {
        // Ensure we have a button highlighted
        updateSelectedItem(gameState, selectedMenuItem);
      }
      
      updateAccessibilityButtonText();
    }
    // Handle pause menu buttons
    else if (buttonText.equals("Resume")) {
      gameState = STATE_GAME;
    } else if (buttonText.equals("Restart")) {
      game.reset();
      gameState = STATE_GAME;
    } else if (buttonText.equals("Main Menu")) {
      gameState = STATE_MAIN_MENU;
      selectedMenuItem = 0;
    }
  }
  
  // Handle main menu click
  void handleMainMenuClick() {
    // Only process clicks if we're not in keyboard-only mode
    if (!accessManager.keyboardOnly) {
      checkButtonClicks(mainMenuButtons);
    }
  }
  
  // Handle instructions click
  void handleInstructionsClick() {
    // Only process clicks if we're not in keyboard-only mode
    if (!accessManager.keyboardOnly) {
      checkButtonClicks(instructionsButtons);
    }
  }
  
  // Handle settings click
  void handleSettingsClick() {
    // Only process clicks if we're not in keyboard-only mode
    if (!accessManager.keyboardOnly) {
      checkButtonClicks(settingsButtons);
    }
  }
  
  // Handle pause menu click
  void handlePauseMenuClick() {
    // Only process clicks if we're not in keyboard-only mode
    if (!accessManager.keyboardOnly) {
      checkButtonClicks(pauseMenuButtons);
    }
  }
  
  // Handle game over click
  void handleGameOverClick() {
    // Only process clicks if we're not in keyboard-only mode
    if (!accessManager.keyboardOnly) {
      checkButtonClicks(gameOverButtons);
    }
  }
  
  // Handle accessibility menu click
  void handleAccessibilityMenuClick() {
    // Only process clicks if we're not in keyboard-only mode
    if (!accessManager.keyboardOnly) {
      checkButtonClicks(settingsButtons);
    }
  }
  
  // Generic button click handler
  void checkButtonClicks(ArrayList<Button> buttons) {
    for (int i = 0; i < buttons.size(); i++) {
      Button button = buttons.get(i);
      if (button.isClicked()) {
        // Activate the button action
        activateButton(button);
        return;
      }
    }
  }
  
  // Activate a button (delegates to clickButton)
  void activateButton(Button button) {
    if (button == null) return;
    
    // Play a sound effect for button activation
    soundManager.playButtonSound();
    
    // Perform the button action
    clickButton(button);
  }
  
  // Activate menu items with keyboard (used from main program)
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
    // This function is no longer used
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
  
  // Clears keyboard selection from all buttons
  void clearKeyboardSelection() {
    // Only disable keyboard selection if not in keyboard-only mode
    if (!accessManager.keyboardOnly) {
      // Remove highlight from all buttons
      unhighlightAllButtons();
      
      // Reset the current selection index
      currentSelectedButton = -1;
    }
  }
  
  // Update settings button text to reflect current settings
  void updateSettingsButtonText() {
    // Find and update accessibility option buttons
    for (Button button : settingsButtons) {
      // Update High Contrast toggle
      if (button.text.startsWith("High Contrast:")) {
        button.text = "High Contrast: " + (accessManager.highContrastMode ? "ON" : "OFF");
      }
      // Update Color Blind Mode toggle
      else if (button.text.startsWith("Color Blind Mode:")) {
        button.text = "Color Blind Mode: " + (accessManager.colorBlindMode ? "ON" : "OFF");
      }
      // Update Keyboard Navigation toggle
      else if (button.text.startsWith("Keyboard Navigation:")) {
        button.text = "Keyboard Navigation: " + (accessManager.keyboardOnly ? "ON" : "OFF");
      }
    }
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
} 