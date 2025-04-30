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
    "¡Menos huella de carbono!",
    "¡Energía renovable!",
    "¡Energía limpia!",
    "¡Acción sostenible!",
    "¡Un árbol absorbe CO2!",
    "¡Reciclar ahorra energía!",
    "¡Bicicleta = cero emisiones!",
    "¡Las LED ahorran energía!",
    "¡Ahorra agua!",
    "¡Papel reciclable!",
    "¡Bolsas de tela!",
    "¡Reduce, Reutiliza, Recicla!",
    "¡Vidrio reciclable!"
  };
  
  String[] negativeMessages = {
    "¡Cuidado contaminación!",
    "¡Emisiones de carbono!",
    "¡Daño ambiental!",
    "¡Cambio climático!",
    "¡No sostenible!",
    "¡Desperdicio!",
    "¡Plástico = 500 años!",
    "¡Pilas contaminan agua!",
    "¡Plástico afecta fauna marina!",
    "¡Demasiado plástico!",
    "¡No desperdicies agua!",
    "¡Evita deforestación!",
    "¡Contaminar aire es peligroso!",
    "¡Cuidado con microplásticos!",
    "¡Aguas residuales contaminan!"
  };
  
  // Tips según nivel
  String[] beginerEcoTips = {
    "¡Separa residuos!",
    "¡Cierra el grifo!",
    "¡Usa bolsas reutilizables!",
    "¡Apaga luces!"
  };
  
  String[] intermediateEcoTips = {
    "¡Cultiva plantas!",
    "¡Menos empaques!",
    "¡Usa transporte público!",
    "¡Consume local!"
  };
  
  String[] advancedEcoTips = {
    "¡Composta!",
    "¡Energía solar!",
    "¡Dieta sostenible!",
    "¡Planta árboles!"
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
  
  // AccessibilityManager
  AccessibilityManager accessManager;
  
  EcoSystem() {
    ecoHealth = startingHealth;
    // Use default accessibility
    this.accessManager = new AccessibilityManager();
  }
  
  // Constructor con gestor de accesibilidad
  EcoSystem(AccessibilityManager accessManager) {
    ecoHealth = startingHealth;
    this.accessManager = accessManager;
  }
  
  // Aumentar la salud del ecosistema (usado por coleccionables ECO_BOOST)
  void boost(float amount) {
    ecoHealth += amount * 100; // Convertir de escala 0-1 a escala 0-100
    ecoHealth = constrain(ecoHealth, minEcoHealth, maxEcoHealth);
    
    // Mostrar efecto visual
    String message = "¡Eco Boost +" + int(amount * 100) + "!";
    showEffect(message, goodColor);
  }
  
  // Reducir contaminación (usado por coleccionables ECO_CLEANUP)
  void reduce(float amount) {
    // Similar a boost pero con mensaje diferente
    ecoHealth += amount * 100; // Convertir de escala 0-1 a escala 0-100
    ecoHealth = constrain(ecoHealth, minEcoHealth, maxEcoHealth);
    
    // Mostrar efecto visual
    String message = "¡Contaminación -" + int(amount * 100) + "!";
    showEffect(message, normalColor);
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
  
  // Método para obtener el nivel actual de contaminación (0.0 a 1.0)
  float getPollutionLevel() {
    // Devuelve un valor entre 0.0 (sin contaminación) y 1.0 (contaminación máxima)
    // Basado en la salud del ecosistema
    if (pollutionEffect) {
      return map(ecoHealth, minEcoHealth, warningThreshold, 1.0, 0.0);
    } else {
      return 0.0;
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
  
  String getAppropriateEcoTip(int difficultyLevel) {
    // Devuelve un tip adecuado al nivel de dificultad del jugador
    if (difficultyLevel <= 3) {
      return beginerEcoTips[int(random(beginerEcoTips.length))];
    } else if (difficultyLevel <= 6) {
      return intermediateEcoTips[int(random(intermediateEcoTips.length))];
    } else {
      return advancedEcoTips[int(random(advancedEcoTips.length))];
    }
  }
  
  // Métodos para ajustar la salud del ecosistema directamente
  void increaseHealth(float amount) {
    ecoHealth += amount;
    ecoHealth = constrain(ecoHealth, minEcoHealth, maxEcoHealth);
    
    // Mostrar efecto visual
    String message = "¡Eco +" + int(amount) + "!";
    showEffect(message, goodColor);
  }
  
  void decreaseHealth(float amount) {
    ecoHealth -= amount;
    ecoHealth = constrain(ecoHealth, minEcoHealth, maxEcoHealth);
    
    // Mostrar efecto visual
    String message = "¡Eco -" + int(amount) + "!";
    showEffect(message, criticalColor);
  }
} 