/**
 * XPSummaryScreen.pde
 * 
 * Pantalla que muestra un resumen detallado del XP ganado al final de una partida,
 * incluyendo desglose por categorías e intentos de efectos visuales.
 */

class XPSummaryScreen {
  // Datos del XP ganado
  int totalXPEarned;
  int distanceXP;
  int collectiblesXP;
  int survivalXP;
  int ecoXP;
  int bonusXP;
  String[] bonusDescriptions;
  
  // Estados de animación
  boolean isAnimating;
  int animationTimer;
  int animationDuration = 300; // 5 segundos a 60 FPS
  int currentAnimationStage;
  int maxAnimationStages = 6;
  
  AccessibilityManager accessManager;
  PlayerProgression playerProgression;
  
  // Botón para continuar
  Button continueButton;
  
  // Variables para efectos visuales
  boolean showLevelUpEffect;
  int levelUpEffectTimer;
  int oldLevel;
  int newLevel;
  
  XPSummaryScreen(AccessibilityManager accessManager, PlayerProgression playerProgression) {
    this.accessManager = accessManager;
    this.playerProgression = playerProgression;
    
    // Inicializar botón de continuar
    continueButton = new Button(width/2, height - 80, 200, 50, "CONTINUAR", accessManager);
    
    // Inicializar datos
    resetData();
  }
  
  // Configurar datos del XP ganado
  void setXPData(int totalEarned, float distance, int collectibles, int timeSeconds, 
                 float avgEcoHealth, boolean wasHit, float goodEcoTime) {
    
    // Usar el total real que se pasó como parámetro
    this.totalXPEarned = totalEarned;
    
    // Calcular los valores teóricos para proporciones
    int theoreticalDistanceXP = (int)(distance * playerProgression.xpPerDistanceUnit);
    int theoreticalCollectiblesXP = collectibles * playerProgression.xpPerCollectible;
    int theoreticalSurvivalXP = timeSeconds * playerProgression.xpPerSecondSurvived;
    int theoreticalEcoXP = (int)(avgEcoHealth * playerProgression.xpPerEcoHealthPoint);
    
    // Calcular bonuses esperados
    int theoreticalBonusXP = 0;
    ArrayList<String> bonuses = new ArrayList<String>();
    
    if (!wasHit && timeSeconds > 30) {
      theoreticalBonusXP += playerProgression.xpBonusNoHit;
      bonuses.add("🛡️ Sin daño: +" + playerProgression.xpBonusNoHit + " XP");
    }
    
    if (timeSeconds > 120) {
      theoreticalBonusXP += playerProgression.xpBonusLongRun;
      bonuses.add("⏱️ Supervivencia larga: +" + playerProgression.xpBonusLongRun + " XP");
    }
    
    float goodEcoPercentage = goodEcoTime / timeSeconds;
    if (goodEcoPercentage > 0.75 && timeSeconds > 60) {
      theoreticalBonusXP += playerProgression.xpBonusEcoMaster;
      bonuses.add("🌱 Eco maestro: +" + playerProgression.xpBonusEcoMaster + " XP");
    }
    
    // Total teórico
    int theoreticalTotal = theoreticalDistanceXP + theoreticalCollectiblesXP + theoreticalSurvivalXP + theoreticalEcoXP + theoreticalBonusXP;
    
    // Si hay diferencia entre teórico y real, ajustar proporcionalmente
    if (theoreticalTotal > 0) {
      float ratio = (float)totalEarned / theoreticalTotal;
      
      distanceXP = (int)(theoreticalDistanceXP * ratio);
      collectiblesXP = (int)(theoreticalCollectiblesXP * ratio);
      survivalXP = (int)(theoreticalSurvivalXP * ratio);
      ecoXP = (int)(theoreticalEcoXP * ratio);
      bonusXP = (int)(theoreticalBonusXP * ratio);
      
      // Ajustar cualquier diferencia por redondeo en la categoría más grande
      int adjustedTotal = distanceXP + collectiblesXP + survivalXP + ecoXP + bonusXP;
      int difference = totalEarned - adjustedTotal;
      
      if (difference != 0) {
        // Añadir la diferencia a la categoría con más XP
        if (survivalXP >= distanceXP && survivalXP >= collectiblesXP && survivalXP >= ecoXP && survivalXP >= bonusXP) {
          survivalXP += difference;
        } else if (ecoXP >= distanceXP && ecoXP >= collectiblesXP && ecoXP >= bonusXP) {
          ecoXP += difference;
        } else if (distanceXP >= collectiblesXP && distanceXP >= bonusXP) {
          distanceXP += difference;
        } else if (collectiblesXP >= bonusXP) {
          collectiblesXP += difference;
        } else {
          bonusXP += difference;
        }
      }
    } else {
      distanceXP = 0;
      collectiblesXP = 0;
      survivalXP = 0;
      ecoXP = 0;
      bonusXP = totalEarned;
      bonuses.add("🎯 XP total: +" + totalEarned + " XP");
    }
    
    bonusDescriptions = bonuses.toArray(new String[bonuses.size()]);
    
    // Iniciar animación
    startAnimation();
  }
  
  // Resetear datos
  void resetData() {
    totalXPEarned = 0;
    distanceXP = 0;
    collectiblesXP = 0;
    survivalXP = 0;
    ecoXP = 0;
    bonusXP = 0;
    bonusDescriptions = new String[0];
    
    isAnimating = false;
    animationTimer = 0;
    currentAnimationStage = 0;
    showLevelUpEffect = false;
  }
  
  // Iniciar animación de entrada
  void startAnimation() {
    // Verificar si hubo level up
    oldLevel = playerProgression.getCurrentLevel();
    // Simular level up temporal para mostrar el efecto (el nivel ya se actualizó)
    if (playerProgression.hasJustLeveledUp()) {
      showLevelUpEffect = true;
      newLevel = oldLevel;
      oldLevel = newLevel - 1; // Asumir que subió un nivel
    }
    
    isAnimating = true;
    animationTimer = 0;
    currentAnimationStage = 0;
  }
  
  // Actualizar animación
  void update() {
    if (isAnimating) {
      animationTimer++;
      
      // Cambiar de etapa cada cierto tiempo
      int stageLength = animationDuration / maxAnimationStages;
      int newStage = animationTimer / stageLength;
      
      if (newStage != currentAnimationStage && newStage < maxAnimationStages) {
        currentAnimationStage = newStage;
        
        // Reproducir sonido para cada etapa (si hay soundManager disponible)
        // TODO: Integrar con SoundManager
      }
      
      // Terminar animación
      if (animationTimer >= animationDuration) {
        isAnimating = false;
        currentAnimationStage = maxAnimationStages;
      }
    }
    
    // Actualizar efecto de level up
    if (showLevelUpEffect) {
      levelUpEffectTimer++;
      if (levelUpEffectTimer > 180) { // 3 segundos
        showLevelUpEffect = false;
        levelUpEffectTimer = 0;
      }
    }
  }
  
  // Mostrar pantalla como overlay encima del juego
  void display() {
    pushStyle();
    
    // Fondo semi-transparente para oscurecer el juego pero mantenerlo visible
    fill(0, 0, 0, 150);
    rect(0, 0, width, height);
    
    // Panel principal más compacto para overlay
    int panelWidth = 450;
    int panelHeight = 450; 
    int panelX = (width - panelWidth) / 2;
    int panelY = (height - panelHeight) / 2;
    
    // Fondo del panel con mejor transparencia
    color panelColor = accessManager.getBackgroundColor(color(25, 25, 35, 230));
    fill(panelColor);
    stroke(accessManager.getUIBorderColor(color(100, 150, 255)));
    strokeWeight(3);
    rectMode(CORNER);
    rect(panelX, panelY, panelWidth, panelHeight, 15);
    
    // Título principal
    drawTitle(panelX, panelY, panelWidth);
    
    // Desglose de XP con animación
    drawXPBreakdown(panelX, panelY, panelWidth, panelHeight);
    
    // Total con efecto especial e información de nivel integrada
    drawTotalXPWithLevel(panelX, panelY, panelWidth, panelHeight);
    
    // Actualizar posición del botón continuar para el overlay
    continueButton.x = panelX + panelWidth/2;
    continueButton.y = panelY + panelHeight + 50; 
    continueButton.display();
    
    // Efecto de level up superpuesto
    if (showLevelUpEffect) {
      drawLevelUpOverlay();
    }
    
    // Mostrar indicación para saltar animación si está activa
    if (isAnimating) {
      drawSkipAnimationHint();
    }
    
    popStyle();
  }
  
  // Dibujar título
  void drawTitle(int panelX, int panelY, int panelWidth) {
    color titleColor = accessManager.getTextColor(color(255, 220, 100));
    fill(titleColor);
    textAlign(CENTER, CENTER);
    textSize(accessManager.getAdjustedTextSize(32));
    text("EXPERIENCIA GANADA", panelX + panelWidth/2, panelY + 35);
    
    // Línea decorativa
    stroke(titleColor);
    strokeWeight(2);
    line(panelX + 40, panelY + 55, panelX + panelWidth - 40, panelY + 55);
  }
  
  // Dibujar desglose de XP con animación
  void drawXPBreakdown(int panelX, int panelY, int panelWidth, int panelHeight) {
    int startY = panelY + 75;
    int lineHeight = 28;
    int currentY = startY;
    
    // Distancia (etapa 0)
    if (currentAnimationStage >= 0) {
      drawXPLine("Distancia recorrida:", distanceXP, panelX + 25, currentY, 
                 currentAnimationStage == 0);
      currentY += lineHeight;
    }
    
    // Coleccionables (etapa 1)
    if (currentAnimationStage >= 1) {
      drawXPLine("Coleccionables:", collectiblesXP, panelX + 25, currentY, 
                 currentAnimationStage == 1);
      currentY += lineHeight;
    }
    
    // Supervivencia (etapa 2)
    if (currentAnimationStage >= 2) {
      drawXPLine("Tiempo supervivencia:", survivalXP, panelX + 25, currentY, 
                 currentAnimationStage == 2);
      currentY += lineHeight;
    }
    
    // Ecosistema (etapa 3)
    if (currentAnimationStage >= 3) {
      drawXPLine("Salud ecosistema:", ecoXP, panelX + 25, currentY, 
                 currentAnimationStage == 3);
      currentY += lineHeight;
    }
    
    // Bonuses (etapa 4)
    if (currentAnimationStage >= 4 && bonusDescriptions.length > 0) {
      currentY += 15; // Espacio extra antes de bonuses
      
      // Título de bonificaciones
      fill(accessManager.getTextColor(color(100, 255, 100)));
      textAlign(LEFT, CENTER);
      textSize(accessManager.getAdjustedTextSize(15));
      text("BONIFICACIONES:", panelX + 25, currentY);
      currentY += 22;
      
      // Lista de bonuses
      for (String bonus : bonusDescriptions) {
        fill(accessManager.getTextColor(color(150, 255, 150)));
        textAlign(LEFT, CENTER);
        textSize(accessManager.getAdjustedTextSize(13));
        text(bonus, panelX + 40, currentY);
        currentY += 18;
      }
    }
  }
  
  // Dibujar línea individual de XP
  void drawXPLine(String label, int xpValue, int x, int y, boolean highlight) {
    pushStyle();
    
    // Color base o destacado
    color textColor;
    if (highlight) {
      textColor = accessManager.getTextColor(color(255, 255, 100)); // Amarillo destacado
      
      // Efecto de brillo para la línea actual
      fill(255, 255, 100, 40);
      noStroke();
      rect(x - 15, y - 10, 380, 20, 5);
    } else {
      textColor = accessManager.getTextColor(color(255, 255, 255));
    }
    
    // Texto de la etiqueta (lado izquierdo)
    fill(textColor);
    textAlign(LEFT, CENTER);
    textSize(accessManager.getAdjustedTextSize(16));
    text(label, x, y);
    
    // Valor de XP (lado derecho, alineado a la derecha)
    textAlign(RIGHT, CENTER);
    textSize(accessManager.getAdjustedTextSize(16));
    String xpText = "+" + xpValue + " XP";
    text(xpText, x + 350, y);
    
    // Línea de puntos para conectar (solo si no está resaltado)
    if (!highlight) {
      stroke(accessManager.getTextColor(color(120, 120, 120, 150)));
      strokeWeight(1);
      
      // Calcular espacio para los puntos
      float labelWidth = textWidth(label);
      float xpWidth = textWidth(xpText);
      int startDot = x + (int)labelWidth + 15;
      int endDot = x + 350 - (int)xpWidth - 10;
      
      // Dibujar puntos solo en el espacio disponible
      int dotSpacing = 8;
      for (int dotX = startDot; dotX < endDot; dotX += dotSpacing) {
        point(dotX, y);
      }
    }
    
    popStyle();
  }
  
  // Dibujar total de XP con efecto especial e información de nivel integrada
  void drawTotalXPWithLevel(int panelX, int panelY, int panelWidth, int panelHeight) {
    if (currentAnimationStage >= maxAnimationStages - 1) {
      int totalY = panelY + panelHeight - 140; // Ajustado para hacer espacio para nivel
      
      // Línea separadora
      stroke(accessManager.getTextColor(color(200, 200, 200)));
      strokeWeight(2);
      line(panelX + 25, totalY - 15, panelX + panelWidth - 25, totalY - 15);
      
      // Fondo destacado para el total
      fill(accessManager.getBackgroundColor(color(50, 100, 50, 150)));
      noStroke();
      rect(panelX + 15, totalY - 10, panelWidth - 30, 30, 8);
      
      // Texto del total con efecto pulsante
      float pulse = sin(millis() * 0.008) * 0.2 + 1.0;
      color totalColor = accessManager.getTextColor(color(255, 215, 0));
      fill(red(totalColor) * pulse, green(totalColor) * pulse, blue(totalColor) * pulse);
      
      textAlign(CENTER, CENTER);
      textSize(accessManager.getAdjustedTextSize(24));
      text("TOTAL: +" + totalXPEarned + " XP", panelX + panelWidth/2, totalY + 2.5);
      
      // Información de nivel integrada dentro del panel
      drawLevelInfoIntegrated(panelX, totalY + 50, panelWidth);
    }
  }
  
  // Dibujar información de nivel integrada dentro del panel principal
  void drawLevelInfoIntegrated(int x, int y, int panelWidth) {
    if (currentAnimationStage >= maxAnimationStages) {
      // Línea separadora para la sección de nivel
      stroke(accessManager.getTextColor(color(180, 180, 180)));
      strokeWeight(1);
      line(x + 25, y - 10, x + panelWidth - 25, y - 10);
      
      // Información de nivel
      fill(accessManager.getTextColor(color(255, 220, 100)));
      textAlign(LEFT, CENTER);
      textSize(accessManager.getAdjustedTextSize(20));
      text("NIVEL " + playerProgression.getCurrentLevel(), x + 25, y + 15);
      
      // Barra de progreso de XP
      if (!playerProgression.isMaxLevel()) {
        int barWidth = panelWidth - 50;
        int barHeight = 8;
        int barX = x + 25;
        int barY = y + 35;
        
        // Fondo de la barra
        fill(accessManager.getBackgroundColor(color(50, 50, 50)));
        noStroke();
        rect(barX, barY, barWidth, barHeight, barHeight/2);
        
        // Progreso de la barra
        float progress = (float)playerProgression.getCurrentXP() / playerProgression.getXPToNextLevel();
        int fillWidth = (int)(barWidth * progress);
        
        fill(accessManager.getUIElementColor(color(100, 255, 100)));
        rect(barX, barY, fillWidth, barHeight, barHeight/2);
        
        // Texto de XP debajo de la barra
        textSize(accessManager.getAdjustedTextSize(14));
        textAlign(CENTER, CENTER);
        fill(accessManager.getTextColor(color(200, 200, 200)));
        text(playerProgression.getCurrentXP() + " / " + playerProgression.getXPToNextLevel() + " XP hasta el siguiente nivel", 
             x + panelWidth/2, y + 55);
      } else {
        textSize(accessManager.getAdjustedTextSize(16));
        textAlign(CENTER, CENTER);
        fill(accessManager.getTextColor(color(255, 215, 0)));
        text("¡NIVEL MÁXIMO ALCANZADO!", x + panelWidth/2, y + 35);
      }
    }
  }
  
  // Dibujar overlay de level up como notificación elegante sin oscurecer toda la pantalla
  // Funciona de manera similar al efecto de PlayerProgression pero adaptado para XPSummaryScreen
  void drawLevelUpOverlay() {
    pushStyle();
    
    // Calcular alpha y animación para la notificación
    float alpha = 255;
    float yOffset = 0;
    float scale = 1.0;
    
    // Animación de entrada
    if (levelUpEffectTimer < 30) {
      float progress = levelUpEffectTimer / 30.0;
      alpha = 255 * progress;
      yOffset = -40 * (1 - progress); // Se desliza desde arriba
      scale = 0.6 + 0.4 * progress;   // Crece desde 60% a 100%
    }
    // Animación de salida (últimos 60 frames de 180)
    else if (levelUpEffectTimer > 120) {
      alpha = map(levelUpEffectTimer, 120, 180, 255, 0);
      yOffset = -15 * ((levelUpEffectTimer - 120) / 60.0); // Se desliza hacia arriba
    }
    
    // Posición en la parte superior para no interferir con el panel de XP
    float centerX = width / 2;
    float baseY = height * 0.15 + yOffset; // 15% desde arriba, más alto que en PlayerProgression
    
    // Panel compacto para la notificación de level up
    float panelWidth = 380;
    float panelHeight = 120;
    float panelX = centerX - panelWidth/2;
    float panelY = baseY - panelHeight/2;
    
    pushMatrix();
    translate(centerX, baseY);
    scale(scale);
    translate(-centerX, -baseY);
    
    // Fondo elegante del panel de notificación (NO toda la pantalla)
    fill(0, 0, 0, alpha * 0.9); // Fondo negro semi-transparente para el panel
    stroke(255, 215, 0, alpha);  // Borde dorado brillante
    strokeWeight(3);
    rect(panelX, panelY, panelWidth, panelHeight, 18);
    
    // Efecto de brillo para hacer la notificación más llamativa
    stroke(255, 215, 0, alpha * 0.4);
    strokeWeight(6);
    rect(panelX, panelY, panelWidth, panelHeight, 18);
    
    // Texto principal del level up, optimizado para el contexto de XP Summary
    fill(255, 215, 0, alpha);
    textAlign(CENTER, CENTER);
    textSize(accessManager.getAdjustedTextSize(42)); // Tamaño adecuado para la notificación
    text("¡LEVEL UP!", centerX, baseY - 20);
    
    // Cambio de nivel con un estilo compacto
    fill(255, 255, 255, alpha);
    textSize(accessManager.getAdjustedTextSize(24));
    text("Nivel " + oldLevel + " → " + newLevel, centerX, baseY + 5);
    
    // Mensaje motivacional sutil y no invasivo
    float pulse = sin(millis() * 0.012) * 0.25 + 0.75; // Pulsación muy sutil
    fill(100, 255, 100, alpha * pulse * 0.85);
    textSize(accessManager.getAdjustedTextSize(18));
    text("¡Sigue cuidando el planeta!", centerX, baseY + 30);
    
    popMatrix();
    
    popStyle();
  }
  
  // Dibujar indicación para saltar animación
  void drawSkipAnimationHint() {
    pushStyle();
    
    // Posición en la parte inferior del botón de continuar
    float hintY = continueButton.y + continueButton.height/2 + 25;
    
    // Efecto de parpadeo sutil para llamar la atención
    float alpha = 180 + sin(millis() * 0.008) * 75; // Oscila entre 105 y 255
    
    // Texto con fondo semi-transparente para mejor legibilidad
    color hintBgColor = accessManager.getBackgroundColor(color(0, 0, 0, 100));
    fill(hintBgColor);
    noStroke();
    
    // Calcular ancho del texto para el fondo
    textSize(accessManager.getAdjustedTextSize(16));
    String hintText = "Presiona cualquier tecla o haz clic para saltar la animación";
    float textWidth = textWidth(hintText);
    
    // Dibujar fondo redondeado
    rectMode(CENTER);
    rect(width/2, hintY, textWidth + 20, 25, 12);
    
    // Dibujar el texto de la indicación
    fill(accessManager.getTextColor(color(255, 255, 255, alpha)));
    textAlign(CENTER, CENTER);
    text(hintText, width/2, hintY);
    
    popStyle();
  }
  
  // Verificar clic en botón continuar
  boolean checkContinueClick() {
    return continueButton.isClicked() && currentAnimationStage >= maxAnimationStages;
  }
  
  // Saltar animación (si el usuario hace clic)
  void skipAnimation() {
    if (isAnimating) {
      isAnimating = false;
      currentAnimationStage = maxAnimationStages;
      animationTimer = animationDuration;
    }
  }
  
  // Manejar input de teclado
  void handleKeyPressed() {
    if (keyCode == ESC) {
      if (isAnimating) {
        skipAnimation();
      }
    }
    else if (isAnimating) {
      skipAnimation();
    }
  }
  
  // Manejar clicks del mouse
  void handleMousePressed() {
    // Click en cualquier parte salta la animación (pero no cierra la pantalla)
    if (isAnimating) {
      skipAnimation();
    }
  }
} 