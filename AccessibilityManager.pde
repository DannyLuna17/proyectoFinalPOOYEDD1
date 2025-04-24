/**
 * Clase para gestionar opciones de accesibilidad
 */
class AccessibilityManager {
  // Ajustes visuales
  boolean highContrastMode = false;
  int textSizeMultiplier = 1; // 1 = normal, 2 = grande, 3 = muy grande
  boolean colorBlindMode = false;
  boolean reduceAnimations = false;
  
  // Ajustes auditivos
  boolean visualCuesForAudio = true;
  
  // Ajustes de control
  boolean alternativeControls = false;
  boolean keyboardOnly = false;
  boolean mouseOnly = false;
  
  // Teclas por defecto
  char jumpKey = ' ';
  char slideKey = 's';
  char pauseKey = 'p';
  
  // Colores para alto contraste
  color highContrastBackground;
  color highContrastForeground;
  color highContrastAccent;
  color highContrastText;
  
  // Colores para UI en alto contraste
  color highContrastTextOnDark;
  color highContrastTextOnLight;
  color highContrastUIElement;
  color highContrastUIBorder;
  
  // Paleta para daltónicos
  color[] colorBlindPalette;
  
  // Colores originales
  color originalBgColor;
  color originalFgColor;
  color originalTextColor;
  
  // Colores para modo daltónico
  color colorBlindBackground;
  color colorBlindForeground;
  color colorBlindText;
  color colorBlindObstacle;
  color colorBlindCollectible;
  
  // Propiedades para señales visuales de sonido
  float soundCueDisplayTime = 2.0;
  ArrayList<SoundCue> activeSoundCues;
  
  AccessibilityManager() {
    // Colores alto contraste
    highContrastBackground = color(0);
    highContrastForeground = color(255, 255, 0);
    highContrastAccent = color(255, 0, 0);
    highContrastText = color(0);
    
    highContrastTextOnDark = color(255, 255, 0);
    highContrastTextOnLight = color(0);
    highContrastUIElement = color(255);
    highContrastUIBorder = color(255, 0, 0);
    
    // Paleta para daltónicos
    colorBlindPalette = new color[5];
    colorBlindPalette[0] = color(27, 158, 119);
    colorBlindPalette[1] = color(217, 95, 2);
    colorBlindPalette[2] = color(117, 112, 179);
    colorBlindPalette[3] = color(231, 41, 138);
    colorBlindPalette[4] = color(102, 166, 30);
    
    // Colores originales
    originalBgColor = color(80, 150, 200);
    originalFgColor = color(50, 50, 50);
    originalTextColor = color(0);
    
    // Colores para daltónicos
    colorBlindBackground = color(51, 78, 204);
    colorBlindForeground = color(255, 150, 0);
    colorBlindText = color(0, 0, 153);
    colorBlindObstacle = color(204, 82, 0);
    colorBlindCollectible = color(0, 153, 153);
    
    activeSoundCues = new ArrayList<SoundCue>();
  }
  
  float getAdjustedTextSize(float baseSize) {
    return baseSize * textSizeMultiplier;
  }
  
  color getBackgroundColor(color defaultColor) {
    if (highContrastMode) {
      return highContrastBackground;
    } else if (colorBlindMode) {
      return colorBlindBackground;
    } else {
      return defaultColor;
    }
  }
  
  color getForegroundColor(color defaultColor) {
    if (highContrastMode) {
      return highContrastForeground;
    } else if (colorBlindMode) {
      return colorBlindForeground;
    } else {
      return defaultColor;
    }
  }
  
  color getTextColor(color defaultColor) {
    if (highContrastMode) {
      float brightness = brightness(defaultColor);
      
      if (brightness > 200) {
        return color(0);
      } else {
        return color(255, 255, 0);
      }
    } else if (colorBlindMode) {
      return colorBlindText;
    } else {
      return defaultColor;
    }
  }
  
  color findClosestColorBlindColor(color inputColor) {
    float brightness = (red(inputColor) + green(inputColor) + blue(inputColor)) / 3;
    int index = int(map(brightness, 0, 255, 0, colorBlindPalette.length - 1));
    return colorBlindPalette[index];
  }
  
  void toggleHighContrastMode() {
    highContrastMode = !highContrastMode;
    println("High contrast mode: " + (highContrastMode ? "ON" : "OFF"));
  }
  
  void toggleColorBlindMode() {
    colorBlindMode = !colorBlindMode;
    println("Color blind mode: " + (colorBlindMode ? "ON" : "OFF"));
  }
  
  void toggleReducedAnimations() {
    reduceAnimations = !reduceAnimations;
    println("Reduced animations: " + (reduceAnimations ? "ON" : "OFF"));
  }
  
  void toggleVisualCuesForAudio() {
    visualCuesForAudio = !visualCuesForAudio;
    println("Visual cues for audio: " + (visualCuesForAudio ? "ON" : "OFF"));
  }
  
  void toggleAlternativeControls() {
    alternativeControls = !alternativeControls;
    println("Alternative controls: " + (alternativeControls ? "ON" : "OFF"));
  }
  
  void toggleKeyboardOnly() {
    keyboardOnly = !keyboardOnly;
    if (keyboardOnly) mouseOnly = false;
    println("Keyboard only: " + (keyboardOnly ? "ON" : "OFF"));
  }
  
  void toggleMouseOnly() {
    mouseOnly = !mouseOnly;
    if (mouseOnly) keyboardOnly = false;
    println("Mouse only: " + (mouseOnly ? "ON" : "OFF"));
  }
  
  void setTextSizeMultiplier(int multiplier) {
    textSizeMultiplier = constrain(multiplier, 1, 3);
    println("Text size multiplier set to: " + textSizeMultiplier);
  }
  
  void cycleTextSize() {
    textSizeMultiplier = (textSizeMultiplier % 3) + 1;
    println("Text size multiplier set to: " + textSizeMultiplier);
  }
  
  void setJumpKey(char key) {
    jumpKey = key;
    println("Jump key set to: " + jumpKey);
  }
  
  void setSlideKey(char key) {
    slideKey = key;
    println("Slide key set to: " + slideKey);
  }
  
  void setPauseKey(char key) {
    pauseKey = key;
    println("Pause key set to: " + pauseKey);
  }
  
  char getJumpKey() {
    if (alternativeControls) {
      return 'j';
    } else {
      return jumpKey;
    }
  }
  
  char getSlideKey() {
    if (alternativeControls) {
      return 's';
    } else {
      return slideKey;
    }
  }
  
  color getUITextColor(color defaultColor, color backgroundColor) {
    if (highContrastMode) {
      float bgBrightness = brightness(backgroundColor);
      
      if (bgBrightness > 127) {
        return color(0);
      } else {
        return color(255, 255, 0);
      }
    } else if (colorBlindMode) {
      return colorBlindText;
    } else {
      return defaultColor;
    }
  }
  
  color getUIBorderColor(color defaultColor) {
    if (highContrastMode) {
      return highContrastUIBorder;
    } else if (colorBlindMode) {
      return colorBlindForeground;
    } else {
      return defaultColor;
    }
  }
  
  color getUIElementColor(color defaultColor) {
    if (highContrastMode) {
      return highContrastUIElement;
    } else if (colorBlindMode) {
      return colorBlindForeground;
    } else {
      return defaultColor;
    }
  }
  
  color adjustButtonColor(color defaultColor) {
    if (highContrastMode) {
      return highContrastForeground;
    } else if (colorBlindMode) {
      return colorBlindForeground;
    }
    return defaultColor;
  }
  
  color adjustButtonHoverColor(color defaultHoverColor) {
    if (highContrastMode) {
      return color(255);
    } else if (colorBlindMode) {
      return color(red(colorBlindForeground) * 0.8, 
                  green(colorBlindForeground) * 0.8, 
                  blue(colorBlindForeground) * 0.8);
    }
    return defaultHoverColor;
  }
  
  color adjustTextColor(color defaultTextColor) {
    if (highContrastMode) {
      return color(0);
    } else if (colorBlindMode) {
      return colorBlindText;
    } else {
      return defaultTextColor;
    }
  }
  
  void displaySoundCue(String soundType, float x, float y) {
    if (!visualCuesForAudio) return;
    
    SoundCue cue = new SoundCue(soundType, x, y);
    activeSoundCues.add(cue);
  }
  
  String getKeyboardNavInstructions() {
    return "Use ARROW KEYS or W/S to navigate, ENTER/SPACE to select, ESC to go back";
  }
  
  void updateSoundCues() {
    if (!visualCuesForAudio) return;
    
    for (int i = activeSoundCues.size() - 1; i >= 0; i--) {
      SoundCue cue = activeSoundCues.get(i);
      cue.update();
      cue.display();
      
      if (cue.isExpired()) {
        activeSoundCues.remove(i);
      }
    }
  }
  
  void displayStatus() {
    pushStyle();
    fill(0);
    textSize(12);
    textAlign(LEFT);
    text("High Contrast: " + highContrastMode, 10, height - 70);
    text("Color Blind: " + colorBlindMode, 10, height - 55);
    text("Visual Cues: " + visualCuesForAudio, 10, height - 40);
    text("Alt Controls: " + alternativeControls, 10, height - 25);
    text("Keyboard Only: " + keyboardOnly, 10, height - 10);
    popStyle();
  }
}

/**
 * Clase para mostrar indicadores visuales de sonido
 */
class SoundCue {
  String type;
  float x, y;
  float lifespan;
  float maxLifespan = 2000;
  color cueColor;
  float size;
  
  SoundCue(String type, float x, float y) {
    this.type = type;
    this.x = x;
    this.y = y;
    this.lifespan = maxLifespan;
    
    setCueProperties();
  }
  
  void setCueProperties() {
    switch(type) {
      case "jump":
        cueColor = color(0, 200, 255);
        size = 30;
        break;
      case "slide":
        cueColor = color(255, 100, 0);
        size = 30;
        break;
      case "collect":
        cueColor = color(0, 255, 0);
        size = 25;
        break;
      case "collision":
        cueColor = color(255, 0, 0);
        size = 35;
        break;
      case "powerup":
        cueColor = color(200, 0, 255);
        size = 40;
        break;
      case "game_over":
        cueColor = color(255, 0, 0);
        size = 50;
        break;
      case "button":
        cueColor = color(150, 150, 255);
        size = 20;
        break;
      default:
        cueColor = color(200);
        size = 25;
    }
    
    if (accessManager.highContrastMode) {
      cueColor = accessManager.highContrastForeground;
    } else if (accessManager.colorBlindMode) {
      cueColor = accessManager.colorBlindForeground;
    }
  }
  
  void update() {
    lifespan -= 16.67;
  }
  
  void display() {
    float alpha = map(lifespan, 0, maxLifespan, 0, 255);
    float currentSize = map(lifespan, 0, maxLifespan, size * 2, size);
    
    pushStyle();
    noFill();
    stroke(red(cueColor), green(cueColor), blue(cueColor), alpha);
    strokeWeight(3);
    ellipse(x, y, currentSize, currentSize);
    
    for (int i = 0; i < 4; i++) {
      float waveSize = currentSize + (i * 15) * (1 - lifespan/maxLifespan);
      stroke(red(cueColor), green(cueColor), blue(cueColor), alpha * (1 - i * 0.2));
      ellipse(x, y, waveSize, waveSize);
    }
    
    fill(red(cueColor), green(cueColor), blue(cueColor), alpha);
    textAlign(CENTER, CENTER);
    textSize(12);
    text(type.toUpperCase(), x, y + currentSize/2 + 15);
    popStyle();
  }
  
  boolean isExpired() {
    return lifespan <= 0;
  }
} 