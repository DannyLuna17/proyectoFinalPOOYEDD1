/**
 * Button class - Interactive UI element with hover and click functionality
 * Used for all menu screens and navigation
 */
class Button {
  float x, y;
  float width, height;
  String text;
  color baseColor, hoverColor, textColor;
  boolean isHovered;
  boolean isHighlighted; // Para navegación por teclado
  boolean isAnimatingPress = false;
  int pressAnimationTimer = 0;
  boolean keyboardHoverEmulation = false; // Flag for emulating hover via keyboard
  Menu menu;
  AccessibilityManager accessManager;
  
  // Animation properties
  float animProgress = 0; // 0 to 1
  float hoverGrowth = 0.05;
  float scale = 1.0; // Para efecto de escala al pasar el cursor/resaltar
  float glowIntensity = 0;
  float maxGlowIntensity = 60;
  float glowSpeed = 2;
  float targetScale = 1.0;
  float scaleSpeed = 0.05; // How quickly the button scales
  
  // Click animation properties
  boolean isPressed = false;
  float pressScale = 0.95; // Scale when pressed
  
  // Default colors - light pastel blue with dark text
  color defaultBaseColor = color(227, 242, 255); // Light pastel blue
  color defaultTextColor = color(20, 20, 30);    // Dark (near-black)
  
  Button(float x, float y, float w, float h, String text, AccessibilityManager accessManager) {
    this.x = x;
    this.y = y;
    this.width = w;
    this.height = h;
    this.text = text;
    this.accessManager = accessManager;
    this.baseColor = defaultBaseColor;
    this.textColor = defaultTextColor;
    updateHoverColor();
    isHovered = false;
    isHighlighted = false; // Initialize highlighted state
  }
  
  Button(float x, float y, float w, float h, String text, color baseColor, AccessibilityManager accessManager) {
    this.x = x;
    this.y = y;
    this.width = w;
    this.height = h;
    this.text = text;
    this.accessManager = accessManager;
    this.baseColor = baseColor;
    this.textColor = defaultTextColor;
    updateHoverColor();
    isHovered = false;
    isHighlighted = false;
  }
  
  Button(float x, float y, float w, float h, String text, color baseColor, color textColor, AccessibilityManager accessManager) {
    this.x = x;
    this.y = y;
    this.width = w;
    this.height = h;
    this.text = text;
    this.accessManager = accessManager;
    this.baseColor = baseColor;
    this.textColor = textColor;
    updateHoverColor();
    isHovered = false;
    isHighlighted = false;
  }
  
  // Auto-generate hover color from base color
  void updateHoverColor() {
    // Make hover color slightly darker for better contrast
    float r = red(baseColor);
    float g = green(baseColor);
    float b = blue(baseColor);
    hoverColor = color(constrain(r - 20, 0, 255), constrain(g - 20, 0, 255), constrain(b, 0, 255));
  }
  
  void update() {
    // Update hover state based on mouse position if keyboard navigation is not active
    if (!accessManager.keyboardOnly) {
      boolean wasHovered = isHovered;
      boolean newHoverState = isMouseOver();
      
      // If this button is now being hovered and wasn't before
      if (newHoverState && !wasHovered) {
        // Clear keyboard selection from all menu buttons when mouse hovers any button
        if (menu != null) {
          menu.clearKeyboardSelection();
        }
      }
      
      isHovered = newHoverState;
      
      // Check for mouse press/release
      if (isHovered && mousePressed) {
        isPressed = true;
      } else {
        isPressed = false;
      }
    } else {
      // En modo keyboard-only, el hover real del mouse no se aplica
      // pero el hover por teclado sí (a través de keyboardHoverEmulation)
      isHovered = keyboardHoverEmulation;
      isPressed = false;
    }
    
    // Si keyboardHoverEmulation está activado, tratamos el botón como si tuviera hover
    boolean effectivelyHovered = isHovered || keyboardHoverEmulation;
    
    // Update glow animation
    if (isHighlighted || effectivelyHovered) {
      // Increase glow intensity if highlighted or hovered
      glowIntensity = min(glowIntensity + glowSpeed, maxGlowIntensity);
      targetScale = 1.1; // Scale up when hovered/highlighted
    } else {
      // Decrease glow intensity if not highlighted or hovered
      glowIntensity = max(glowIntensity - glowSpeed, 0);
      targetScale = 1.0; // Return to normal scale
    }
    
    // Apply scaling when pressed
    if (isPressed) {
      targetScale = pressScale;
    }
    
    // Smoothly animate the scale
    if (!accessManager.reduceAnimations) {
      scale += (targetScale - scale) * scaleSpeed;
    } else {
      scale = targetScale; // Immediate scaling if animations reduced
    }
  }
  
  // Método para aplicar o quitar el efecto de hover emulado por teclado
  void applyKeyboardHoverEffect(boolean apply) {
    keyboardHoverEmulation = apply;
  }
  
  boolean isMouseOver() {
    // Check if mouse is over the button
    return mouseX >= x - width/2 && mouseX <= x + width/2 && mouseY >= y - height/2 && mouseY <= y + height/2;
  }
  
  void display() {
    update();
    
    pushStyle();
    rectMode(CENTER);
    
    // Apply accessibility color adjustments - siempre usar los originales como base
    color currentBaseColor = accessManager.adjustButtonColor(baseColor);
    color currentHoverColor = accessManager.adjustButtonHoverColor(hoverColor);
    color currentTextColor = accessManager.adjustTextColor(textColor);
    
    // Determine which color to use
    color displayColor;
    if (isHighlighted || isHovered || keyboardHoverEmulation) {
      displayColor = currentHoverColor;
    } else {
      displayColor = currentBaseColor;
    }
    
    // Apply scaling transformation
    pushMatrix();
    translate(x, y);
    scale(scale);
    
    // Draw drop shadow for pill-shaped button
    if (!accessManager.highContrastMode && !accessManager.reduceAnimations) {
      noStroke();
      fill(0, 60);
      rect(2, 3, width, height, height/2); // Full rounded corners for pill shape with offset for shadow
    }
    
    // Draw glow effect when highlighted or hovered
    if (glowIntensity > 0 && !accessManager.reduceAnimations) {
      noStroke();
      // Draw multiple layers of semi-transparent outlines for glow effect
      for (int i = 0; i < 3; i++) {
        float alpha = glowIntensity * (3-i) / 3.0;
        float size = i * 3;
        color glowColor = accessManager.highContrastMode ? 
                         color(255, alpha) : // White glow for high contrast
                         color(red(displayColor), green(displayColor), blue(displayColor), alpha); // Color-matched glow
                         
        fill(glowColor);
        rect(0, 0, width + size, height + size, (height + size)/2); // Full pill shape
      }
    }
    
    // Draw button background with pill shape (fully rounded corners)
    if (accessManager.highContrastMode) {
      stroke(255);
      strokeWeight(3);
    } else {
      stroke(80, 100, 120);
      strokeWeight(1);
    }
    fill(displayColor);
    rect(0, 0, width, height, height/2); // Use h/2 for fully rounded corners (pill shape)
    
    // Draw white outline for highlighted/hovered buttons
    if (isHighlighted || isHovered || keyboardHoverEmulation) {
      strokeWeight(2);
      stroke(255);
      noFill();
      rect(0, 0, width + 4, height + 4, (height + 4)/2);
    }
    
    // Apply text size adjustment from accessibility manager
    float textSizeValue = accessManager.getAdjustedTextSize(20); // Default size
    textSize(textSizeValue);
    
    // Draw the text with consistent color and enforced contrast
    textAlign(CENTER, CENTER);
    fill(currentTextColor);
    
    // Add text shadow for better legibility
    if (!accessManager.highContrastMode) {
      fill(0, 40);
      text(text, 1, 1);
    }
    
    // Draw main text
    fill(currentTextColor);
    text(text, 0, 0);
    
    // Add a visual indicator for keyboard navigation when highlighted
    if (isHighlighted && accessManager.keyboardOnly) {
      // Draw a keyboard indicator if in keyboard-only mode
      popMatrix(); // Reset transformation for the keyboard indicator
      fill(accessManager.highContrastMode ? color(255) : color(255, 220));
      textSize(12);
      textAlign(CENTER, BOTTOM);
      text("Enter/Space to select", x, y + height/2 + 20);
    } else {
      popMatrix(); // Reset transformation
    }
    
    popStyle();
  }
  
  boolean isClicked() {
    // Check for mouse clicks only if not in keyboard-only mode
    if (accessManager.keyboardOnly) return false;
    
    return isMouseOver() && mousePressed;
  }
  
  // Set the button as highlighted (for keyboard navigation)
  void setHighlighted(boolean highlighted) {
    isHighlighted = highlighted;
  }
  
  // Toggle button highlight
  void toggleHighlight() {
    isHighlighted = !isHighlighted;
  }
  
  // Also initialize the menu reference for buttons in a menu
  void setMenu(Menu menu) {
    this.menu = menu;
  }
} 