class PowerUp {
  int type;
  int duration;
  int remainingTime;
  color powerUpColor;
  String name;
  
  PowerUp(int type, int duration) {
    this.type = type;
    this.duration = duration;
    this.remainingTime = duration;
    
    switch(type) {
      case Collectible.SHIELD:
        name = "SHIELD";
        powerUpColor = color(100, 255, 100);
        break;
      case Collectible.SPEED_BOOST:
        name = "SPEED BOOST";
        powerUpColor = color(255, 50, 50);
        break;
      case Collectible.DOUBLE_POINTS:
        name = "DOUBLE POINTS";
        powerUpColor = color(255, 100, 255);
        break;
      default:
        name = "UNKNOWN";
        powerUpColor = color(255);
    }
  }
  
  void update() {
    if (remainingTime > 0) {
      remainingTime--;
    }
  }
  
  boolean isActive() {
    return remainingTime > 0;
  }
  
  float getProgressPercentage() {
    return float(remainingTime) / float(duration);
  }
  
  void display(float x, float y, float w, float h) {
    pushStyle();
    
    // Background - use high contrast for better visibility
    color bgColor = accessManager.highContrastMode ? color(40) : color(50, 150);
    fill(bgColor);
    rect(x, y, w, h);
    
    // Progress bar - apply high contrast if needed
    float progressWidth = w * getProgressPercentage();
    color adjustedPowerUpColor = accessManager.getUIElementColor(powerUpColor);
    fill(adjustedPowerUpColor);
    rect(x, y, progressWidth, h);
    
    // Border - use high contrast border
    noFill();
    color borderColor = accessManager.getUIBorderColor(color(255));
    stroke(borderColor);
    rect(x, y, w, h);
    
    // Text - use high contrast text color based on background
    color textColor = accessManager.getUITextColor(color(255), bgColor);
    fill(textColor);
    textAlign(LEFT, CENTER);
    textSize(accessManager.getAdjustedTextSize(12));
    text(name, x + 5, y + h/2);
    
    // Duration text
    int secondsLeft = ceil(remainingTime / 60.0);
    textAlign(RIGHT, CENTER);
    text(secondsLeft + "s", x + w - 5, y + h/2);
    
    popStyle();
  }
} 
