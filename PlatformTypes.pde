/**
 * PlatformTypes.pde
 * 
 * Contains specialized platform types that inherit from the base Platform class.
 */

// Bounce platform - player bounces up when landing on it
class BouncePlatform extends Platform {
  BouncePlatform(float x, float y, float w) {
    super(x, y, w, 15, 5.0, 1, new AccessibilityManager());
  }
  
  BouncePlatform(float x, float y, float w, AccessibilityManager accessManager) {
    super(x, y, w, 15, 5.0, 1, accessManager);
  }
}

// Moving platform - moves up and down vertically
class MovingPlatform extends Platform {
  MovingPlatform(float x, float y, float w) {
    super(x, y, w, 15, 5.0, 2, new AccessibilityManager());
  }
  
  MovingPlatform(float x, float y, float w, AccessibilityManager accessManager) {
    super(x, y, w, 15, 5.0, 2, accessManager);
  }
}

// Disappearing platform - disappears after player steps on it
class DisappearingPlatform extends Platform {
  boolean activated = false;
  int disappearTimer = 0;
  int disappearDuration = 60; // 1 second to disappear
  
  DisappearingPlatform(float x, float y, float w) {
    super(x, y, w, 15, 5.0, 3, new AccessibilityManager());
  }
  
  DisappearingPlatform(float x, float y, float w, AccessibilityManager accessManager) {
    super(x, y, w, 15, 5.0, 3, accessManager);
  }
  
  @Override
  void update() {
    super.update();
    
    // If activated, count down to disappearance
    if (activated) {
      disappearTimer++;
    }
  }
  
  @Override
  void display() {
    if (!activated || disappearTimer < disappearDuration) {
      pushStyle();
      
      // Dibujar plataforma
      rectMode(CORNER);
      
      // Calculate alpha based on disappear timer
      float alpha = activated ? map(disappearTimer, 0, disappearDuration, 255, 0) : 255;
      
      // Color ajustado para accesibilidad
      color displayColor = accessManager.getForegroundColor(platformColor);
      fill(red(displayColor), green(displayColor), blue(displayColor), alpha);
      
      // Base platform shape
      rect(x, y, width, height, 4); // Slightly rounded corners
      
      // Add flicker effect when disappearing
      if (activated) {
        if (frameCount % 5 == 0) {
          stroke(255, alpha);
          strokeWeight(2);
          line(x, y, x + width, y + height);
          line(x + width, y, x, y + height);
        }
      }
      
      popStyle();
    }
  }
  
  @Override
  boolean isPlayerOn(Player player) {
    boolean result = super.isPlayerOn(player);
    
    // If player is on platform and not activated yet, activate
    if (result && !activated) {
      activated = true;
    }
    
    // If disappearing is complete, no collision
    if (activated && disappearTimer >= disappearDuration) {
      return false;
    }
    
    return result;
  }
  
  @Override
  boolean isOnScreen() {
    // If disappearing is complete, consider it off screen
    if (activated && disappearTimer >= disappearDuration) {
      return false;
    }
    return super.isOnScreen();
  }
} 