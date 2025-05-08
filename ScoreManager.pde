/**
 * ScoreManager.pde
 * 
 * Manages the game scoring system, including score calculation,
 * bonus points, and persistent high score tracking.
 */

class ScoreManager {
  int score;
  int highScore;
  
  // Score parameters
  int scoreIncrement = 1;
  int bonusPoints = 0;
  int framesSinceLastCollision = 0;
  int bonusThreshold = 300; // 5 seconds without collision
  int collectiblesCollected = 0;
  
  // Multipliers
  int pointsMultiplier = 1;
  boolean hasScoreBoost = false;
  int scoreBoostTimer = 0;
  int scoreBoostDuration = 0;
  
  ScoreManager() {
    reset();
  }
  
  void reset() {
    // Save high score before reset
    if (score > highScore) {
      highScore = score;
    }
    
    // Reset current score
    score = 0;
    framesSinceLastCollision = 0;
    collectiblesCollected = 0;
    pointsMultiplier = 1;
    hasScoreBoost = false;
    scoreBoostTimer = 0;
  }
  
  void update(Player player) {
    // Base score increment
    score += scoreIncrement * player.pointsMultiplier;
    
    // Bonus for consecutive obstacle avoidance
    if (framesSinceLastCollision > bonusThreshold) {
      bonusPoints = 1 + (framesSinceLastCollision - bonusThreshold) / 60;
      score += bonusPoints * player.pointsMultiplier;
    }
    
    // Update score boost timer
    if (hasScoreBoost) {
      scoreBoostTimer++;
      if (scoreBoostTimer >= scoreBoostDuration) {
        deactivateScoreBoost();
      }
    }
    
    // Increment frame counter
    framesSinceLastCollision++;
  }
  
  void recordCollision() {
    // Reset consecutive frames counter
    framesSinceLastCollision = 0;
    bonusPoints = 0;
  }
  
  void addCollectible() {
    collectiblesCollected++;
  }
  
  void addPoints(int points, Player player) {
    // Add points with any active multipliers
    score += points * player.pointsMultiplier;
  }
  
  void activateScoreBoost(int duration, int multiplier) {
    hasScoreBoost = true;
    scoreBoostDuration = duration;
    scoreBoostTimer = 0;
    pointsMultiplier = multiplier;
  }
  
  void deactivateScoreBoost() {
    hasScoreBoost = false;
    scoreBoostTimer = 0;
    pointsMultiplier = 1;
  }
  
  int getScore() {
    return score;
  }
  
  int getHighScore() {
    return highScore;
  }
  
  boolean hasNewHighScore() {
    return score > highScore;
  }
  
  void display() {
    // Variables para una UI más consistente
    int panelWidth = 200;  // Aumentando el ancho del panel
    int panelHeight = 40;  // Aumentando la altura del panel
    int rightMargin = 20;  // Margen derecho consistente
    int topMargin = 20;    // Margen superior consistente
    int panelSpacing = 15; // Espacio entre paneles
    float cornerRadius = 10; // Bordes redondeados para estética moderna
    
    // Posición base para todos los paneles (alineados a la derecha)
    int baseX = width - rightMargin - panelWidth;
    
    // Panel de puntuación actual
    fill(0, 0, 0, 180); // Fondo más oscuro para mejor contraste
    rect(baseX, topMargin, panelWidth, panelHeight, cornerRadius);
    
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(22); // Texto más grande para mejor legibilidad
    text("PUNTOS: " + score, baseX + panelWidth/2, topMargin + panelHeight/2);
    
    // Panel de puntuación máxima
    fill(0, 0, 0, 180);
    rect(baseX, topMargin + panelHeight + panelSpacing, panelWidth, panelHeight, cornerRadius);
    
    // Usar un color diferente para destacar la puntuación máxima
    fill(255, 220, 100); // Color dorado para máxima puntuación
    textAlign(CENTER, CENTER);
    textSize(22);
    text("MÁXIMO: " + highScore, baseX + panelWidth/2, topMargin + panelHeight + panelSpacing + panelHeight/2);
    
    // Panel de bonificación si está activo
    if (bonusPoints > 0) {
      fill(0, 0, 0, 180);
      rect(baseX, topMargin + (panelHeight + panelSpacing) * 2, panelWidth, panelHeight, cornerRadius);
      
      fill(255, 255, 0); // Amarillo brillante para bonus
      textAlign(CENTER, CENTER);
      textSize(22);
      text("BONUS: +" + bonusPoints, baseX + panelWidth/2, topMargin + (panelHeight + panelSpacing) * 2 + panelHeight/2);
    }
    
    // Panel de multiplicador si está activo
    if (pointsMultiplier > 1) {
      fill(0, 0, 0, 180);
      rect(baseX, topMargin + (panelHeight + panelSpacing) * 3, panelWidth, panelHeight, cornerRadius);
      
      fill(255, 100, 100); // Rojo claro para el multiplicador
      textAlign(CENTER, CENTER);
      textSize(22);
      text("MULTI: x" + pointsMultiplier, baseX + panelWidth/2, topMargin + (panelHeight + panelSpacing) * 3 + panelHeight/2);
    }
  }
} 