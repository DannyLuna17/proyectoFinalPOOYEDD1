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
    // Score display
    fill(0, 0, 0, 150);
    rect(width - 170, 20, 150, 20);
    
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(12);
    text("PUNTOS: " + score, width - 170 + 150/2, 20 + 10);
    
    // High score display
    fill(0, 0, 0, 150);
    rect(width - 170, 50, 150, 20);
    
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(12);
    text("MÁXIMO: " + highScore, width - 170 + 150/2, 50 + 10);
    
    // Bonus display if active
    if (bonusPoints > 0) {
      fill(0, 0, 0, 150);
      rect(width - 170, 80, 150, 20);
      
      fill(255, 255, 0);
      textAlign(CENTER, CENTER);
      textSize(12);
      text("BONUS: +" + bonusPoints, width - 170 + 150/2, 80 + 10);
    }
    
    // Score multiplier display if active
    if (pointsMultiplier > 1) {
      fill(0, 0, 0, 150);
      rect(width - 170, 110, 150, 20);
      
      fill(255, 200, 0);
      textAlign(CENTER, CENTER);
      textSize(12);
      text("MULTI: x" + pointsMultiplier, width - 170 + 150/2, 110 + 10);
    }
  }
} 