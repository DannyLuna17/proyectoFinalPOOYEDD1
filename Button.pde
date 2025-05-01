class Button {
  float x, y;
  float width, height;
  String text;
  color baseColor, hoverColor, textColor;
  boolean isHovered;
  boolean isHighlighted; // Para navegación por teclado
  boolean isAnimatingPress = false;
  int pressAnimationTimer = 0;
  boolean keyboardHoverEmulation = false; 
  Menu menu;
  AccessibilityManager accessManager;
  
  float animProgress = 0; 
  float hoverGrowth = 0.05;
  float scale = 1.0; // Para efecto de escala al pasar el cursor/resaltar
  float glowIntensity = 0;
  float maxGlowIntensity = 60;
  float glowSpeed = 2;
  float targetScale = 1.0;
  float scaleSpeed = 0.05; 
  
  boolean isPressed = false;
  float pressScale = 0.95; 
  
  color defaultBaseColor = color(227, 242, 255); 
  color defaultTextColor = color(20, 20, 30);    
  
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
    isHighlighted = false;
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
  
  void updateHoverColor() {
    float r = red(baseColor);
    float g = green(baseColor);
    float b = blue(baseColor);
    hoverColor = color(constrain(r - 20, 0, 255), constrain(g - 20, 0, 255), constrain(b, 0, 255));
  }
  
  void update() {
    if (!accessManager.keyboardOnly) {
      boolean wasHovered = isHovered;
      boolean newHoverState = isMouseOver();
      
      if (newHoverState && !wasHovered) {
        if (menu != null) {
          menu.clearKeyboardSelection();
        }
      }
      
      isHovered = newHoverState;
      
      // Si el ratón está sobre este botón, desactivar el efecto hover por teclado
      // para asegurarse de que solo este botón tenga el efecto visual de selección
      if (isHovered && keyboardHoverEmulation) {
        // Si hay un efecto de hover por teclado activo en este botón y el ratón
        // ahora está sobre él, mantenemos el estado visual pero por el ratón
        keyboardHoverEmulation = false;
      }
      
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
    
    // Verificamos si cualquier botón tiene el ratón encima para determinar si mostramos
    // el efecto de selección por teclado
    boolean effectivelyHovered = isHovered || keyboardHoverEmulation;
    
    // Si el ratón está sobre el botón, quitamos el resaltado por teclado,
    // pero mantenemos el efecto visual de hover gracias al isHovered
    if (isHovered && isHighlighted) {
      // Solo cambiamos el estado interno, no el visual
      isHighlighted = false;
    }
    
    if (isHighlighted || effectivelyHovered) {
      glowIntensity = min(glowIntensity + glowSpeed, maxGlowIntensity);
      targetScale = 1.1; 
    } else {
      glowIntensity = max(glowIntensity - glowSpeed, 0);
      targetScale = 1.0;
    }
    
    if (isPressed) {
      targetScale = pressScale;
    }
    
    if (!accessManager.reduceAnimations) {
      scale += (targetScale - scale) * scaleSpeed;
    } else {
      scale = targetScale; 
    }
  }
  
  // Método para aplicar o quitar el efecto de hover emulado por teclado
  void applyKeyboardHoverEffect(boolean apply) {
    keyboardHoverEmulation = apply;
  }
  
  boolean isMouseOver() {
    boolean overButton = mouseX >= x - width/2 && mouseX <= x + width/2 && 
                        mouseY >= y - height/2 && mouseY <= y + height/2;
    
    if (overButton && pmouseX == mouseX && pmouseY == mouseY && menu != null && !mousePressed) {
      if (menu.currentSelectedButton >= 0) {
        return false;
      }
    }
    
    return overButton;
  }
  
  void display() {
    update();
    
    pushStyle();
    rectMode(CENTER);
    
    color currentBaseColor = accessManager.adjustButtonColor(baseColor);
    color currentHoverColor = accessManager.adjustButtonHoverColor(hoverColor);
    color currentTextColor = accessManager.adjustTextColor(textColor);
    
    color displayColor;
    if (isHighlighted || isHovered || keyboardHoverEmulation) {
      displayColor = currentHoverColor;
    } else {
      displayColor = currentBaseColor;
    }
    
    pushMatrix();
    translate(x, y);
    scale(scale);
    
    if (!accessManager.highContrastMode && !accessManager.reduceAnimations) {
      noStroke();
      fill(0, 60);
      rect(2, 3, width, height, height/2); 
    }
    
    if (glowIntensity > 0 && !accessManager.reduceAnimations) {
      noStroke();
      for (int i = 0; i < 3; i++) {
        float alpha = glowIntensity * (3-i) / 3.0;
        float size = i * 3;
        color glowColor = accessManager.highContrastMode ? 
                         color(255, alpha) : // White glow for high contrast
                         color(red(displayColor), green(displayColor), blue(displayColor), alpha); 
                         
        fill(glowColor);
        rect(0, 0, width + size, height + size, (height + size)/2); 
      }
    }
    
    if (accessManager.highContrastMode) {
      stroke(255);
      strokeWeight(3);
    } else {
      stroke(80, 100, 120);
      strokeWeight(1);
    }
    fill(displayColor);
    rect(0, 0, width, height, height/2); 
    
    if (isHighlighted || isHovered || keyboardHoverEmulation) {
      strokeWeight(2);
      stroke(255);
      noFill();
      rect(0, 0, width + 4, height + 4, (height + 4)/2);
    }
    
    float textSizeValue = accessManager.getAdjustedTextSize(20); // Default size
    textSize(textSizeValue);
    
    textAlign(CENTER, CENTER);
    fill(currentTextColor);
    
    if (!accessManager.highContrastMode) {
      fill(0, 40);
      text(text, 1, 1);
    }
    
    fill(currentTextColor);
    text(text, 0, 0);
    
    if (isHighlighted && accessManager.keyboardOnly) {
      popMatrix(); 
      fill(accessManager.highContrastMode ? color(255) : color(255, 220));
      textSize(12);
      textAlign(CENTER, BOTTOM);
      text("Enter/Space to select", x, y + height/2 + 20);
    } else {
      popMatrix(); 
    }
    
    popStyle();
  }
  
  boolean isClicked() {
    if (accessManager.keyboardOnly) return false;
    
    return isMouseOver() && mousePressed;
  }
  
  void setHighlighted(boolean highlighted) {
    isHighlighted = highlighted;
  }
  
  void toggleHighlight() {
    isHighlighted = !isHighlighted;
  }
  
  void setMenu(Menu menu) {
    this.menu = menu;
  }
} 