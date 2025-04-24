class EcoSystem {
  // Parámetros ambientales
  float ecoHealth;
  float maxEcoHealth = 100;
  float minEcoHealth = 0;
  float startingHealth = 50;
  
  // Umbrales
  float criticalThreshold = 25;
  float warningThreshold = 50;
  float goodThreshold = 75;
  
  // Colores
  color goodColor = color(0, 200, 0);
  color normalColor = color(200, 200, 0);
  color warningColor = color(255, 150, 0);
  color criticalColor = color(255, 50, 0);
  
  // Mensajes
  String[] positiveMessages = {
    "¡Buen reciclaje!",
    "¡Elección ecológica!",
    "¡Reduciendo huella de carbono!",
    "¡Energía renovable!",
    "¡Impulso de energía limpia!",
    "¡Acción sostenible!"
  };
  
  String[] negativeMessages = {
    "¡Cuidado con la contaminación!",
    "¡Emisiones de carbono elevadas!",
    "¡Daño ambiental!",
    "¡Impacto climático creciente!",
    "¡Acción insostenible!",
    "¡Desperdicio de energía!"
  };
  
  // Efecto ambiental
  boolean hasActiveEffect = false;
  String activeEffectName = "";
  color activeEffectColor;
  int effectTimer = 0;
  int effectDuration = 180;
  
  // Contaminación
  boolean pollutionEffect = false;
  float pollutionDensity = 0;
  
  EcoSystem() {
    ecoHealth = startingHealth;
  }
  
  void update() {
    if (ecoHealth < goodThreshold) {
      ecoHealth -= 0.02;
    } else {
      ecoHealth += 0.01;
    }
    
    ecoHealth = constrain(ecoHealth, minEcoHealth, maxEcoHealth);
    
    if (hasActiveEffect) {
      effectTimer++;
      if (effectTimer >= effectDuration) {
        hasActiveEffect = false;
        effectTimer = 0;
      }
    }
    
    updatePollutionEffect();
  }
  
  void updatePollutionEffect() {
    if (ecoHealth < warningThreshold) {
      pollutionEffect = true;
      pollutionDensity = map(ecoHealth, minEcoHealth, warningThreshold, 0.7, 0.2);
    } else {
      pollutionEffect = false;
      pollutionDensity = 0;
    }
  }
  
  void display(float x, float y, float w, float h) {
    pushStyle();
    
    color bgColor = accessManager.highContrastMode ? color(40) : color(50, 150);
    fill(bgColor);
    rect(x, y, w, h);
    
    float healthWidth = map(ecoHealth, minEcoHealth, maxEcoHealth, 0, w);
    
    color healthColor;
    if (ecoHealth >= goodThreshold) {
      healthColor = goodColor;
    } else if (ecoHealth >= warningThreshold) {
      healthColor = normalColor;
    } else if (ecoHealth >= criticalThreshold) {
      healthColor = warningColor;
    } else {
      healthColor = criticalColor;
    }
    
    color adjustedHealthColor = accessManager.getUIElementColor(healthColor);
    fill(adjustedHealthColor);
    rect(x, y, healthWidth, h);
    
    noFill();
    color borderColor = accessManager.getUIBorderColor(color(255));
    stroke(borderColor);
    rect(x, y, w, h);
    
    color textColor = accessManager.getUITextColor(color(255), bgColor);
    fill(textColor);
    textAlign(LEFT, CENTER);
    textSize(accessManager.getAdjustedTextSize(12));
    text("ECO", x + 5, y + h/2);
    
    textAlign(RIGHT, CENTER);
    text(int(ecoHealth) + "%", x + w - 5, y + h/2);
    
    popStyle();
    
    if (hasActiveEffect) {
      displayActiveEffect(x, y - 25);
    }
  }
  
  void displayActiveEffect(float x, float y) {
    pushStyle();
    color bgColor = accessManager.getBackgroundColor(color(200));
    color textColor = accessManager.getUITextColor(activeEffectColor, bgColor);
    fill(textColor);
    textAlign(LEFT, CENTER);
    textSize(accessManager.getAdjustedTextSize(14));
    text(activeEffectName, x, y);
    popStyle();
  }
  
  void displayPollution() {
    if (pollutionEffect) {
      pushStyle();
      noStroke();
      fill(100, 100, 100, pollutionDensity * 255);
      rect(0, 0, width, height);
      popStyle();
    }
  }
  
  void applyPositiveImpact(float amount) {
    ecoHealth += amount;
    ecoHealth = constrain(ecoHealth, minEcoHealth, maxEcoHealth);
    
    String message = positiveMessages[int(random(positiveMessages.length))];
    showEffect(message, goodColor);
  }
  
  void applyNegativeImpact(float amount) {
    ecoHealth -= amount;
    ecoHealth = constrain(ecoHealth, minEcoHealth, maxEcoHealth);
    
    String message = negativeMessages[int(random(negativeMessages.length))];
    showEffect(message, criticalColor);
  }
  
  void showEffect(String effectName, color effectColor) {
    activeEffectName = effectName;
    activeEffectColor = effectColor;
    hasActiveEffect = true;
    effectTimer = 0;
  }
  
  boolean isInCriticalState() {
    return ecoHealth <= criticalThreshold;
  }
  
  boolean isInWarningState() {
    return ecoHealth <= warningThreshold && ecoHealth > criticalThreshold;
  }
  
  boolean isInGoodState() {
    return ecoHealth >= goodThreshold;
  }
  
  float getDifficultyMultiplier() {
    if (isInCriticalState()) {
      return 1.5;
    } else if (isInWarningState()) {
      return 1.2;
    } else {
      return 1.0;
    }
  }
  
  float getPointMultiplier() {
    if (isInGoodState()) {
      return 1.5;
    } else if (!isInWarningState() && !isInCriticalState()) {
      return 1.2;
    } else {
      return 1.0;
    }
  }
} 