/**
 * PlayerProgression
 * 
 * Sistema de progresión del jugador que maneja niveles, experiencia y beneficios
 * a largo plazo para aumentar el engagement y la sensación de evolución.
 */

class PlayerProgression {
  // Variables de progresión básicas
  int currentLevel;
  int currentXP;
  int xpToNextLevel;
  int totalXP;
  
  // Configuración de XP y niveles
  int baseXPRequired = 1000; // XP base requerido para el nivel 1
  float xpMultiplier = 1.5; // Multiplicador para cada nivel (la dificultad aumenta)
  int maxLevel = 100; // Nivel máximo permitido
  
  // Factores de XP por actividad (cuánto XP da cada acción)
  int xpPerDistanceUnit = 1; // XP por cada unidad de distancia recorrida
  int xpPerCollectible = 25; // XP por cada coleccionable recolectado
  int xpPerSecondSurvived = 5; // XP por segundo de supervivencia
  int xpPerEcoHealthPoint = 2; // XP por punto de salud del ecosistema mantenido
  
  // Bonificaciones especiales
  int xpBonusNoHit = 500; // Bonus por completar una partida sin ser golpeado
  int xpBonusLongRun = 200; // Bonus por sobrevivir más de 2 minutos
  int xpBonusEcoMaster = 300; // Bonus por mantener ecosistema en verde >75% del tiempo
  
  // Estadísticas de la partida actual (para calcular XP al final)
  float distanceTraveled;
  int collectiblesGathered;
  int timeInSeconds;
  float avgEcosystemHealth;
  boolean wasHitDuringRun;
  float timeInGoodEcoState; // Tiempo que el ecosistema estuvo en buen estado
  
  // Sistema de archivos para persistencia
  String progressionFile = "player_progression.txt";
  
  // Referencias externas
  AccessibilityManager accessManager;
  
  // Variables para efectos visuales de level up
  boolean justLeveledUp = false;
  int levelUpTimer = 0;
  int levelUpDisplayDuration = 180; // 3 segundos a 60 FPS
  int previousLevel; // Para mostrar el cambio de nivel
  
  // Variables para tracking en tiempo real del XP
  int currentRunXP; // XP ganado en la partida actual (se muestra en tiempo real)
  int lastFrameUpdate; // Para calcular XP de distancia solo una vez por frame
  float lastDistanceTracked; // Última distancia registrada
  int lastCollectiblesTracked; // Últimos coleccionables registrados
  int lastSecondsTracked; // Últimos segundos registrados
  float lastEcoHealthTracked; // Última salud del ecosistema registrada
  
  // Variables para efectos visuales de XP en tiempo real
  boolean showXPGain = false;
  int xpGainAmount = 0;
  String xpGainReason = "";
  int xpGainTimer = 0;
  int xpGainDisplayDuration = 90; // 1.5 segundos a 60 FPS
  
  // Constructor
  PlayerProgression() {
    this(new AccessibilityManager());
  }
  
  PlayerProgression(AccessibilityManager accessManager) {
    this.accessManager = accessManager;
    
    // Inicializar valores por defecto
    currentLevel = 1;
    currentXP = 0;
    totalXP = 0;
    calculateXPToNextLevel();
    
    // Cargar progresión guardada
    loadProgression();
    
    // Inicializar estadísticas de partida
    resetRunStats();
  }
  
  // Calcular cuánto XP se necesita para el siguiente nivel
  void calculateXPToNextLevel() {
    if (currentLevel >= maxLevel) {
      xpToNextLevel = 0; // Ya está al máximo nivel
      return;
    }
    
    // Fórmula exponencial: cada nivel requiere más XP que el anterior
    int xpRequired = (int)(baseXPRequired * pow(xpMultiplier, currentLevel - 1));
    xpToNextLevel = xpRequired;
  }
  
  // Reiniciar estadísticas de la partida actual
  void resetRunStats() {
    distanceTraveled = 0;
    collectiblesGathered = 0;
    timeInSeconds = 0;
    avgEcosystemHealth = 0;
    wasHitDuringRun = false;
    timeInGoodEcoState = 0;
    
    // Variables para tracking en tiempo real
    currentRunXP = 0;
    lastFrameUpdate = frameCount;
    lastDistanceTracked = 0;
    lastCollectiblesTracked = 0;
    lastSecondsTracked = 0;
    lastEcoHealthTracked = 50.0; // Valor inicial del ecosistema
  }
  
  // Actualizar estadísticas durante la partida Y calcular XP en tiempo real
  void updateRunStats(float distance, int collectibles, int seconds, float ecoHealth, boolean wasHit) {
    distanceTraveled = distance;
    collectiblesGathered = collectibles;
    timeInSeconds = seconds;
    avgEcosystemHealth = ecoHealth;
    
    // Solo marcar como golpeado si antes no había sido golpeado
    if (wasHit && !wasHitDuringRun) {
      wasHitDuringRun = true;
    }
    
    // Actualizar tiempo en buen estado del ecosistema
    if (ecoHealth >= 75.0) { // Si el ecosistema está en buen estado (verde)
      timeInGoodEcoState += 1.0/60.0; // Incrementar por frame (asumiendo 60 FPS)
    }
    
    // Calcular XP en tiempo real y mostrarlo al jugador
    calculateRealTimeXP(distance, collectibles, seconds, ecoHealth);
  }
  
  // Calcular y mostrar XP en tiempo real durante la partida
  void calculateRealTimeXP(float distance, int collectibles, int seconds, float ecoHealth) {
    int newXP = 0;
    String reason = "";
    
    // XP por distancia (solo actualizar si realmente hubo movimiento)
    if (distance > lastDistanceTracked + 5.0) { // Cada 5 unidades de distancia
      int distanceXPGain = (int)((distance - lastDistanceTracked) * xpPerDistanceUnit);
      newXP += distanceXPGain;
      lastDistanceTracked = distance;
      reason = "Distancia recorrida";
    }
    
    // XP por coleccionables (instantáneo cuando se recolecta)
    if (collectibles > lastCollectiblesTracked) {
      int collectibleXPGain = (collectibles - lastCollectiblesTracked) * xpPerCollectible;
      newXP += collectibleXPGain;
      lastCollectiblesTracked = collectibles;
      reason = "¡Coleccionable!";
    }
    
    // XP por supervivencia (cada segundo)
    if (seconds > lastSecondsTracked) {
      int survivalXPGain = (seconds - lastSecondsTracked) * xpPerSecondSurvived;
      newXP += survivalXPGain;
      lastSecondsTracked = seconds;
      if (reason.length() == 0) reason = "Supervivencia";
    }
    
    // XP por mantener ecosistema saludable (cada frame si está en buen estado)
    if (ecoHealth >= 75.0 && ecoHealth > lastEcoHealthTracked) {
      int ecoXPGain = (int)((ecoHealth - lastEcoHealthTracked) * xpPerEcoHealthPoint * 0.1); 
      if (ecoXPGain > 0) {
        newXP += ecoXPGain;
        if (reason.length() == 0) reason = "Ecosistema saludable";
      }
    }
    lastEcoHealthTracked = ecoHealth;
    
    // Si hubo ganancia de XP, mostrarla y agregarla al total
    if (newXP > 0) {
      awardRealTimeXP(newXP, reason);
    }
  }
  
  // Otorgar XP inmediatamente y mostrar efecto visual
  void awardRealTimeXP(int xp, String reason) {
    currentRunXP += xp;
    
    // Solo mostrar efecto visual si es una cantidad significativa (para no saturar la pantalla)
    if (xp >= 5) {
      showXPGain = true;
      xpGainAmount = xp;
      xpGainReason = reason;
      xpGainTimer = 0;
    }
    
    // Añadir XP inmediatamente al total del jugador
    addXP(xp);
  }
  
  // Método especial para otorgar XP por coleccionables (llamado desde CollectibleManager)
  void awardCollectibleXP(String collectibleType) {
    int xp = xpPerCollectible;
    String reason = "¡" + collectibleType + "!";
    
    // Bonus extra por ciertos tipos de coleccionables
    if (collectibleType.contains("eco") || collectibleType.contains("verde")) {
      xp = (int)(xp * 1.5); // 50% bonus por coleccionables ecológicos
      reason = "¡Eco coleccionable!";
    }
    
    awardRealTimeXP(xp, reason);
  }
  
  // Método especial para bonuses instantáneos
  void awardBonusXP(int bonusXP, String bonusReason) {
    awardRealTimeXP(bonusXP, bonusReason);
  }
  
  // Calcular y otorgar XP al final de una partida
  int calculateEndOfRunXP() {
    int bonusXPEarned = 0;
    
    // Solo calcular bonificaciones especiales al final de la partida
    // El XP regular (distancia, coleccionables, supervivencia, ecosistema) ya se otorgó en tiempo real
    
    // Bonificaciones especiales que solo se pueden evaluar al final
    if (!wasHitDuringRun && timeInSeconds > 30) { // Al menos 30 segundos sin ser golpeado
      bonusXPEarned += xpBonusNoHit;
      awardRealTimeXP(xpBonusNoHit, "🛡️ ¡Sin daño recibido!");
    }
    
    if (timeInSeconds > 120) { // Más de 2 minutos de supervivencia
      bonusXPEarned += xpBonusLongRun;
      awardRealTimeXP(xpBonusLongRun, "⏱️ ¡Supervivencia épica!");
    }
    
    // Bonus por mantener ecosistema en buen estado más del 75% del tiempo
    float goodEcoPercentage = timeInGoodEcoState / timeInSeconds;
    if (goodEcoPercentage > 0.75 && timeInSeconds > 60) {
      bonusXPEarned += xpBonusEcoMaster;
      awardRealTimeXP(xpBonusEcoMaster, "🌱 ¡Maestro del ecosistema!");
    }
    
    // El XP total de la partida es lo que ya se acumuló en tiempo real + los bonuses finales
    int totalRunXP = currentRunXP + bonusXPEarned;
    
    // Resetear estadísticas para la próxima partida
    resetRunStats();
    
    return totalRunXP;
  }
  
  // Añadir XP y manejar subidas de nivel
  void addXP(int xp) {
    if (currentLevel >= maxLevel) return; // Ya está al máximo nivel
    
    currentXP += xp;
    totalXP += xp;
    
    // Verificar si hay subida de nivel
    checkLevelUp();
  }
  
  // Verificar y manejar subidas de nivel
  void checkLevelUp() {
    if (currentLevel >= maxLevel) return;
    
    while (currentXP >= xpToNextLevel && currentLevel < maxLevel) {
      // Subir de nivel
      previousLevel = currentLevel;
      currentXP -= xpToNextLevel;
      currentLevel++;
      
      // Activar efectos visuales de level up
      justLeveledUp = true;
      levelUpTimer = 0;
      
      // Recalcular XP necesario para el siguiente nivel
      calculateXPToNextLevel();
      
      // Si llegamos al máximo nivel, ajustar XP sobrante
      if (currentLevel >= maxLevel) {
        currentXP = 0;
        xpToNextLevel = 0;
      }
    }
  }
  
  // Actualizar efectos visuales y timers
  void update() {
    // Actualizar timer de level up
    if (justLeveledUp) {
      levelUpTimer++;
      if (levelUpTimer >= levelUpDisplayDuration) {
        justLeveledUp = false;
        levelUpTimer = 0;
      }
    }
    
    // Actualizar efectos visuales de XP en tiempo real
    if (showXPGain) {
      xpGainTimer++;
      if (xpGainTimer >= xpGainDisplayDuration) {
        showXPGain = false;
        xpGainTimer = 0;
      }
    }
  }
  
  // Mostrar la UI de progresión
  void display() {
    displayLevelAndXP();
    
    // Mostrar XP ganado en tiempo real
    if (showXPGain) {
      displayRealTimeXPGain();
    }
    
    // Mostrar efecto de level up si es necesario
    if (justLeveledUp) {
      displayLevelUpEffect();
    }
  }
  
  // Mostrar nivel y barra de XP
  void displayLevelAndXP() {
    pushStyle();
    
    // Configuración de UI
    int panelWidth = 320;      
    int panelHeight = 100;     
    int leftMargin = 35;       
    int topMargin = 190;       
    float cornerRadius = 12;   
    
    // Panel de fondo para el nivel y XP con mejor contraste
    color bgColor = accessManager.getBackgroundColor(color(0, 0, 0, 200));
    fill(bgColor);
    stroke(accessManager.getUIBorderColor(color(255, 255, 255, 120)));
    strokeWeight(3); 
    rect(leftMargin, topMargin, panelWidth, panelHeight, cornerRadius);
    
    color textColor = accessManager.getTextColor(color(255, 220, 100));
    fill(textColor);
    textAlign(LEFT, CENTER);
    textSize(accessManager.getAdjustedTextSize(26)); 
    text("NIVEL " + currentLevel, leftMargin + 20, topMargin + 20);
    
    // Mostrar XP de la partida actual con texto más visible
    textSize(accessManager.getAdjustedTextSize(18)); 
    fill(accessManager.getTextColor(color(100, 255, 100))); 
    text("Esta partida: +" + currentRunXP + " XP", leftMargin + 20, topMargin + 45);
    
    // Mostrar XP total si no está al máximo nivel
    if (currentLevel < maxLevel) {
      textSize(accessManager.getAdjustedTextSize(18)); 
      fill(accessManager.getTextColor(color(255, 255, 255)));
      text("Total: " + currentXP + "/" + xpToNextLevel, leftMargin + 20, topMargin + 70);
      
      // Barra de progreso de XP
      int barWidth = panelWidth - 40;  
      int barHeight = 12;              
      int barX = leftMargin + 20;
      int barY = topMargin + 85;       
      
      fill(accessManager.getBackgroundColor(color(50, 50, 50)));
      stroke(accessManager.getUIBorderColor(color(100, 100, 100)));
      strokeWeight(1);
      rect(barX, barY, barWidth, barHeight, barHeight/2);
      
      // Relleno de la barra de progreso
      if (xpToNextLevel > 0) {
        float progressPercent = (float)currentXP / xpToNextLevel;
        int fillWidth = (int)(barWidth * progressPercent);
        
        // Color que cambia según el progreso
        color barColor;
        float pulse = sin(millis() * 0.005) * 0.1 + 0.9; // Pulsación muy sutil
        
        if (progressPercent < 0.33) {
          barColor = accessManager.getUIElementColor(color((int)(100 * pulse), (int)(150 * pulse), 255)); // Azul
        } else if (progressPercent < 0.66) {
          barColor = accessManager.getUIElementColor(color(255, (int)(150 * pulse), (int)(100 * pulse))); // Naranja
        } else {
          barColor = accessManager.getUIElementColor(color((int)(100 * pulse), 255, (int)(100 * pulse))); // Verde
        }
        
        fill(barColor);
        noStroke();
        rect(barX + 1, barY + 1, fillWidth - 2, barHeight - 2, (barHeight-2)/2);
      }
    } else {
      // Mostrar mensaje de nivel máximo
      textSize(accessManager.getAdjustedTextSize(18)); 
      fill(accessManager.getTextColor(color(255, 215, 0))); 
      text("¡NIVEL MÁXIMO!", leftMargin + 20, topMargin + 70);
    }
    
    popStyle();
  }
  
  // Mostrar efecto visual de XP ganado en tiempo real
  void displayRealTimeXPGain() {
    pushStyle();
    
    // Calcular posición y transparencia basada en el timer
    float alpha = 255;
    float yOffset = 0;
    
    if (xpGainTimer < xpGainDisplayDuration * 0.3) {
      // Fase de aparición
      yOffset = map(xpGainTimer, 0, xpGainDisplayDuration * 0.3, 40, 0); 
      alpha = map(xpGainTimer, 0, xpGainDisplayDuration * 0.3, 0, 255);
    } else if (xpGainTimer > xpGainDisplayDuration * 0.7) {
      // Fase de desaparición - fade out
      alpha = map(xpGainTimer, xpGainDisplayDuration * 0.7, xpGainDisplayDuration, 255, 0);
    }
    
    // Posición cerca del panel de nivel
    int textX = 370; 
    int textY = 60 - (int)yOffset; 
    
    // Calcular tamaño del texto para el fondo
    textSize(accessManager.getAdjustedTextSize(26)); 
    float mainTextWidth = textWidth("+" + xpGainAmount + " XP");
    
    textSize(accessManager.getAdjustedTextSize(18)); 
    float reasonTextWidth = textWidth(xpGainReason);
    
    float maxTextWidth = max(mainTextWidth, reasonTextWidth);
    
    // Fondo semi-transparente
    fill(0, 0, 0, alpha * 0.8); 
    noStroke();
    int bgWidth = (int)(maxTextWidth + 30); 
    int bgHeight = 60; 
    rect(textX - 15, textY - 25, bgWidth, bgHeight, 18); 
    
    fill(100, 255, 100, alpha);
    textAlign(LEFT, CENTER);
    textSize(accessManager.getAdjustedTextSize(26)); 
    text("+" + xpGainAmount + " XP", textX, textY);
    
    // Razón del XP ganado
    fill(200, 255, 200, alpha * 0.8);
    textSize(accessManager.getAdjustedTextSize(18)); 
    text(xpGainReason, textX, textY + 20); 
    
    popStyle();
  }
  
  // Mostrar efecto visual de level up sin oscurecer la pantalla del juego
  void displayLevelUpEffect() {
    pushStyle();
    
    // Calcular alpha y posición basado en el timer para animación suave
    float alpha = 255;
    float yOffset = 0;
    float scale = 1.0;
    
    // Animación de entrada (primeros 30 frames)
    if (levelUpTimer < 30) {
      float progress = levelUpTimer / 30.0;
      alpha = 255 * progress;
      yOffset = -50 * (1 - progress); // Se desliza desde arriba
      scale = 0.5 + 0.5 * progress;   // Crece desde 50% a 100%
    }
    // Animación de salida (últimos 60 frames)
    else if (levelUpTimer > levelUpDisplayDuration * 0.66) {
      float fadeProgress = (levelUpTimer - levelUpDisplayDuration * 0.66) / (levelUpDisplayDuration * 0.34);
      alpha = 255 * (1 - fadeProgress);
      yOffset = -20 * fadeProgress; // Se desliza ligeramente hacia arriba al desaparecer
    }
    
    // Posición centrada horizontalmente pero en la parte superior de la pantalla
    float centerX = width / 2;
    float baseY = height * 0.25 + yOffset; 
    
    // Panel de fondo elegante para la notificación
    float panelWidth = 450;
    float panelHeight = 140;
    float panelX = centerX - panelWidth/2;
    float panelY = baseY - panelHeight/2;
    
    pushMatrix();
    translate(centerX, baseY);
    scale(scale);
    translate(-centerX, -baseY);
    
    // Fondo del panel con gradiente sutil y bordes redondeados
    fill(0, 0, 0, alpha * 0.85); 
    stroke(255, 215, 0, alpha); 
    strokeWeight(4);
    rect(panelX, panelY, panelWidth, panelHeight, 20); 
    
    // Efecto de brillo en el borde
    stroke(255, 215, 0, alpha * 0.5);
    strokeWeight(8);
    rect(panelX, panelY, panelWidth, panelHeight, 20);
    
    // Texto principal del level up
    fill(255, 215, 0, alpha); 
    textAlign(CENTER, CENTER);
    textSize(accessManager.getAdjustedTextSize(48)); 
    text("¡LEVEL UP!", centerX, baseY - 25);
    
    fill(255, 255, 255, alpha);
    textSize(accessManager.getAdjustedTextSize(28));
    text("Nivel " + previousLevel + " → " + currentLevel, centerX, baseY + 10);
    
    float pulse = sin(millis() * 0.015) * 0.3 + 0.7; 
    fill(100, 255, 100, alpha * pulse * 0.8); 
    textSize(accessManager.getAdjustedTextSize(20));
    text("¡Sigue cuidando el planeta!", centerX, baseY + 40);
    
    popMatrix();
    
    popStyle();
  }
  
  // Mostrar resumen de XP ganado al final de la partida
  void displayXPSummary(int xpEarned) {
    pushStyle();
    
    // Panel de resumen
    int panelWidth = 400;
    int panelHeight = 300;
    int panelX = (width - panelWidth) / 2;
    int panelY = (height - panelHeight) / 2;
    
    // Fondo del panel
    color bgColor = accessManager.getBackgroundColor(color(0, 0, 0, 200));
    fill(bgColor);
    stroke(accessManager.getUIBorderColor(color(255, 255, 255)));
    strokeWeight(3);
    rect(panelX, panelY, panelWidth, panelHeight, 15);
    
    // Título
    color textColor = accessManager.getTextColor(color(255, 215, 0));
    fill(textColor);
    textAlign(CENTER, CENTER);
    textSize(accessManager.getAdjustedTextSize(28));
    text("EXPERIENCIA GANADA", panelX + panelWidth/2, panelY + 40);
    
    // Desglose de XP
    textSize(accessManager.getAdjustedTextSize(18));
    textAlign(LEFT, CENTER);
    int lineHeight = 25;
    int startY = panelY + 80;
    
    fill(accessManager.getTextColor(color(255, 255, 255)));
    text("Distancia recorrida: +" + (int)(distanceTraveled * xpPerDistanceUnit) + " XP", 
         panelX + 20, startY);
    text("Coleccionables: +" + (collectiblesGathered * xpPerCollectible) + " XP", 
         panelX + 20, startY + lineHeight);
    text("Supervivencia: +" + (timeInSeconds * xpPerSecondSurvived) + " XP", 
         panelX + 20, startY + lineHeight * 2);
    text("Salud ecosistema: +" + (int)(avgEcosystemHealth * xpPerEcoHealthPoint) + " XP", 
         panelX + 20, startY + lineHeight * 3);
    
    // Bonificaciones
    int bonusY = startY + lineHeight * 4;
    if (!wasHitDuringRun && timeInSeconds > 30) {
      fill(accessManager.getTextColor(color(100, 255, 100)));
      text("🛡️ Sin daño: +" + xpBonusNoHit + " XP", panelX + 20, bonusY);
      bonusY += lineHeight;
    }
    
    if (timeInSeconds > 120) {
      fill(accessManager.getTextColor(color(100, 255, 100)));
      text("⏱️ Supervivencia larga: +" + xpBonusLongRun + " XP", panelX + 20, bonusY);
      bonusY += lineHeight;
    }
    
    float goodEcoPercentage = timeInGoodEcoState / timeInSeconds;
    if (goodEcoPercentage > 0.75 && timeInSeconds > 60) {
      fill(accessManager.getTextColor(color(100, 255, 100)));
      text("🌱 Eco maestro: +" + xpBonusEcoMaster + " XP", panelX + 20, bonusY);
    }
    
    // Total
    fill(accessManager.getTextColor(color(255, 215, 0)));
    textSize(accessManager.getAdjustedTextSize(24));
    textAlign(CENTER, CENTER);
    text("TOTAL: +" + xpEarned + " XP", panelX + panelWidth/2, panelY + panelHeight - 40);
    
    popStyle();
  }
  
  // Guardar progresión en archivo
  void saveProgression() {
    try {
      String[] lines = new String[4];
      lines[0] = "level=" + currentLevel;
      lines[1] = "xp=" + currentXP;
      lines[2] = "totalXP=" + totalXP;
      lines[3] = "xpToNext=" + xpToNextLevel;
      
      saveStrings(progressionFile, lines);
      println("✅ Progresión guardada: Nivel " + currentLevel + ", XP total: " + totalXP);
    } catch (Exception e) {
      println("❌ Error al guardar progresión: " + e.getMessage());
    }
  }
  
  // Cargar progresión desde archivo
  void loadProgression() {
    try {
      String[] lines = loadStrings(progressionFile);
      
      if (lines != null && lines.length >= 4) {
        // Parsear cada línea
        for (String line : lines) {
          String[] parts = split(line, '=');
          if (parts.length == 2) {
            String key = parts[0].trim();
            int value = Integer.parseInt(parts[1].trim());
            
            switch (key) {
              case "level":
                currentLevel = constrain(value, 1, maxLevel);
                break;
              case "xp":
                currentXP = max(0, value);
                break;
              case "totalXP":
                totalXP = max(0, value);
                break;
              case "xpToNext":
                xpToNextLevel = max(0, value);
                break;
            }
          }
        }
        
        // Recalcular XP to next level para asegurar consistencia
        calculateXPToNextLevel();
        
        println("✅ Progresión cargada: Nivel " + currentLevel + ", XP total: " + totalXP);
      } else {
        println("📁 No se encontró archivo de progresión, iniciando desde nivel 1");
      }
    } catch (Exception e) {
      println("❌ Error al cargar progresión: " + e.getMessage() + ", iniciando desde nivel 1");
      // Mantener valores por defecto
    }
  }
  
  // Getters para acceso externo
  int getCurrentLevel() { return currentLevel; }
  int getCurrentXP() { return currentXP; }
  int getXPToNextLevel() { return xpToNextLevel; }
  int getTotalXP() { return totalXP; }
  boolean isMaxLevel() { return currentLevel >= maxLevel; }
  boolean hasJustLeveledUp() { return justLeveledUp; }
  
  // Método para resetear progresión
  void resetProgression() {
    currentLevel = 1;
    currentXP = 0;
    totalXP = 0;
    calculateXPToNextLevel();
    saveProgression();
    resetRunStats();
  }
} 