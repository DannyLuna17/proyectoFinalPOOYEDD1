class Weather {
  // Weather types
  static final int CLEAR = 0;
  static final int RAIN = 1;
  static final int FOG = 2;
  static final int WIND = 3;
  static final int HEATWAVE = 4;
  
  // Current state
  int currentWeather = CLEAR;
  float intensity = 0; // 0.0 to 1.0
  float transitionProgress = 0;
  int transitionDuration = 180; // frames for weather transition
  boolean isTransitioning = false;
  int targetWeather = CLEAR;
  
  // Weather timers and durations
  int weatherTimer = 0;
  int weatherDuration = 600; // Base duration for weather events (10 seconds at 60fps)
  int clearDuration = 1200; // Base duration for clear weather periods (20 seconds at 60fps)
  
  // Weather probabilities - can be influenced by ecosystem health
  float rainProbability = 0.3; 
  float fogProbability = 0.2;
  float windProbability = 0.2;
  float heatwaveProbability = 0.1;
  
  // Weather effect parameters
  float jumpModifier = 0; // -0.3 to +0.3
  float speedModifier = 0; // -0.3 to +0.3
  float visibilityModifier = 0; // -0.7 to 0
  
  // Visual effect elements
  ArrayList<Raindrop> raindrops;
  ArrayList<WindParticle> windParticles;
  color fogColor = color(255, 255, 255, 0);
  float fogOpacity = 0;
  float[] heatwaveDistortion;
  
  // Weather name for display
  String weatherName = "Clear";
  
  Weather() {
    raindrops = new ArrayList<Raindrop>();
    windParticles = new ArrayList<WindParticle>();
    heatwaveDistortion = new float[width];
    
    // Initialize heat wave distortion values
    for (int i = 0; i < width; i++) {
      heatwaveDistortion[i] = 0;
    }
  }
  
  void update(EcoSystem ecoSystem) {
    // Update weather timer
    weatherTimer++;
    
    // In transition mode, progress the transition
    if (isTransitioning) {
      transitionProgress += 1.0 / transitionDuration;
      
      if (transitionProgress >= 1.0) {
        // Transition complete
        completeTransition();
      } else {
        // Update intensity during transition
        if (currentWeather == CLEAR) {
          // Transitioning from clear to weather event
          intensity = transitionProgress;
        } else if (targetWeather == CLEAR) {
          // Transitioning from weather event to clear
          intensity = 1.0 - transitionProgress;
        } else {
          // Transitioning between two weather events
          intensity = max(0.3, min(1.0, transitionProgress));
        }
      }
    } 
    
    // Check if weather should change
    if (!isTransitioning) {
      // Get the base duration for the current weather
      int baseDuration = (currentWeather == CLEAR) ? clearDuration : weatherDuration;
      
      // Adjust duration based on ecosystem health
      float durationMultiplier = 1.0;
      
      if (ecoSystem.isInCriticalState()) {
        // More extreme weather in critical state
        if (currentWeather == CLEAR) {
          durationMultiplier = 0.7; // Clear weather doesn't last as long
        } else {
          durationMultiplier = 1.4; // Bad weather lasts longer
        }
      } else if (ecoSystem.isInWarningState()) {
        // Slightly more extreme weather in warning state
        if (currentWeather == CLEAR) {
          durationMultiplier = 0.9; // Slightly shorter clear weather
        } else {
          durationMultiplier = 1.2; // Slightly longer weather events
        }
      }
      
      int adjustedDuration = int(baseDuration * durationMultiplier);
      
      // Check if it's time for a weather change
      if (weatherTimer >= adjustedDuration) {
        selectNewWeather(ecoSystem);
      }
    }
    
    // Update visual effects and parameters based on current weather state
    updateWeatherEffects();
    
    // Update gameplay effect parameters
    updateGameplayParameters();
  }
  
  void selectNewWeather(EcoSystem ecoSystem) {
    // Reset weather timer
    weatherTimer = 0;
    
    // Determine target weather based on probabilities and eco-system state
    float[] probabilities = new float[5]; // probability for each weather type
    
    // Start with base probabilities
    probabilities[CLEAR] = 0.4; // 40% chance for clear weather
    probabilities[RAIN] = rainProbability;
    probabilities[FOG] = fogProbability;
    probabilities[WIND] = windProbability;
    probabilities[HEATWAVE] = heatwaveProbability;
    
    // Adjust probabilities based on ecosystem state
    if (ecoSystem.isInCriticalState()) {
      // Critical state has more extreme weather, less clear weather
      probabilities[CLEAR] *= 0.5; // 50% less chance of clear weather
      probabilities[RAIN] *= 1.5; // 50% more rain
      probabilities[FOG] *= 1.5; // 50% more fog
      probabilities[WIND] *= 1.3; // 30% more wind
      probabilities[HEATWAVE] *= 2.0; // Twice as many heatwaves
    } else if (ecoSystem.isInWarningState()) {
      // Warning state has slightly more extreme weather
      probabilities[CLEAR] *= 0.8; // 20% less chance of clear weather
      probabilities[RAIN] *= 1.2; // 20% more rain
      probabilities[FOG] *= 1.2; // 20% more fog
      probabilities[WIND] *= 1.1; // 10% more wind
      probabilities[HEATWAVE] *= 1.3; // 30% more heatwaves
    }
    
    // Never transition to the same weather (except clear)
    if (currentWeather != CLEAR) {
      probabilities[currentWeather] = 0;
    }
    
    // If already in clear weather, force a change to a weather event
    if (currentWeather == CLEAR) {
      probabilities[CLEAR] = 0;
    }
    
    // Normalize probabilities to ensure they sum to 1.0
    float totalProbability = 0;
    for (int i = 0; i < probabilities.length; i++) {
      totalProbability += probabilities[i];
    }
    
    for (int i = 0; i < probabilities.length; i++) {
      probabilities[i] /= totalProbability;
    }
    
    // Select weather using the probability distribution
    float random = random(1);
    float cumulativeProbability = 0;
    
    for (int i = 0; i < probabilities.length; i++) {
      cumulativeProbability += probabilities[i];
      if (random <= cumulativeProbability) {
        targetWeather = i;
        break;
      }
    }
    
    // Start transition to new weather
    startTransition();
  }
  
  void startTransition() {
    isTransitioning = true;
    transitionProgress = 0;
  }
  
  void completeTransition() {
    isTransitioning = false;
    transitionProgress = 0;
    currentWeather = targetWeather;
    
    // Set intensity based on target weather
    if (currentWeather == CLEAR) {
      intensity = 0;
    } else {
      // Random intensity for the weather event
      intensity = random(0.5, 1.0);
    }
    
    // Update weather name
    updateWeatherName();
  }
  
  void updateWeatherName() {
    switch (currentWeather) {
      case CLEAR:
        weatherName = "Clear";
        break;
      case RAIN:
        if (intensity > 0.8) weatherName = "Heavy Rain";
        else if (intensity > 0.5) weatherName = "Rain";
        else weatherName = "Light Rain";
        break;
      case FOG:
        if (intensity > 0.8) weatherName = "Dense Fog";
        else if (intensity > 0.5) weatherName = "Fog";
        else weatherName = "Light Fog";
        break;
      case WIND:
        if (intensity > 0.8) weatherName = "Strong Wind";
        else if (intensity > 0.5) weatherName = "Wind";
        else weatherName = "Light Breeze";
        break;
      case HEATWAVE:
        if (intensity > 0.8) weatherName = "Extreme Heat";
        else if (intensity > 0.5) weatherName = "Heatwave";
        else weatherName = "Warm Weather";
        break;
    }
  }
  
  void updateGameplayParameters() {
    // Reset modifiers
    jumpModifier = 0;
    speedModifier = 0;
    visibilityModifier = 0;
    
    // Apply effects based on current weather and intensity
    switch (currentWeather) {
      case RAIN:
        // Rain makes jumping harder and reduces speed slightly
        jumpModifier = -0.2 * intensity;
        speedModifier = -0.1 * intensity;
        visibilityModifier = -0.3 * intensity;
        break;
      case FOG:
        // Fog significantly reduces visibility but doesn't affect movement much
        visibilityModifier = -0.7 * intensity;
        break;
      case WIND:
        // Wind affects jumping and speed
        jumpModifier = 0.15 * intensity; // Easier to jump with wind
        speedModifier = 0.2 * intensity; // Faster movement with wind
        break;
      case HEATWAVE:
        // Heatwave reduces speed but jumping is unaffected
        speedModifier = -0.25 * intensity;
        visibilityModifier = -0.15 * intensity; // Slight heat distortion
        break;
    }
  }
  
  void updateWeatherEffects() {
    // Update weather visual effects based on current weather and intensity
    switch (currentWeather) {
      case RAIN:
        updateRainEffects();
        break;
      case FOG:
        updateFogEffects();
        break;
      case WIND:
        updateWindEffects();
        break;
      case HEATWAVE:
        updateHeatwaveEffects();
        break;
      default:
        // Clear weather - remove any remaining effects
        clearEffects();
    }
  }
  
  void updateRainEffects() {
    // Add new raindrops based on intensity
    int maxRaindrops = int(map(intensity, 0, 1, 10, 80));
    
    while (raindrops.size() < maxRaindrops) {
      raindrops.add(new Raindrop());
    }
    
    // Update existing raindrops
    for (int i = raindrops.size() - 1; i >= 0; i--) {
      Raindrop drop = raindrops.get(i);
      drop.update();
      
      // Remove finished raindrops
      if (drop.isFinished()) {
        raindrops.remove(i);
      }
    }
  }
  
  void updateFogEffects() {
    // Adjust fog opacity based on intensity
    fogOpacity = intensity * 180; // Max opacity of 180 (semi-transparent)
    fogColor = color(255, 255, 255, fogOpacity);
  }
  
  void updateWindEffects() {
    // Add new wind particles based on intensity
    int maxParticles = int(map(intensity, 0, 1, 10, 50));
    
    while (windParticles.size() < maxParticles) {
      windParticles.add(new WindParticle());
    }
    
    // Update existing wind particles
    for (int i = windParticles.size() - 1; i >= 0; i--) {
      WindParticle particle = windParticles.get(i);
      particle.update();
      
      // Remove offscreen particles
      if (particle.isOffscreen()) {
        windParticles.remove(i);
      }
    }
  }
  
  void updateHeatwaveEffects() {
    // Update heat wave distortion values
    for (int i = 0; i < width; i++) {
      // Create wavy patterns using sine function
      float waveSpeed = frameCount * 0.02;
      float waveDensity = i * 0.01;
      float waveHeight = 5 * intensity;
      
      heatwaveDistortion[i] = sin(waveSpeed + waveDensity) * waveHeight;
    }
  }
  
  void clearEffects() {
    // Clear all visual effects
    raindrops.clear();
    windParticles.clear();
    fogOpacity = 0;
    
    for (int i = 0; i < width; i++) {
      heatwaveDistortion[i] = 0;
    }
  }
  
  void display() {
    // Draw weather effects based on current weather
    switch (currentWeather) {
      case RAIN:
        displayRain();
        break;
      case FOG:
        displayFog();
        break;
      case WIND:
        displayWind();
        break;
      case HEATWAVE:
        displayHeatwave();
        break;
    }
  }
  
  void displayRain() {
    // Draw raindrops
    stroke(100, 150, 255, 150);
    strokeWeight(2);
    
    for (Raindrop drop : raindrops) {
      drop.display();
    }
    
    // Add a slight blue overlay for heavy rain
    if (intensity > 0.7) {
      fill(100, 150, 255, 30 * intensity);
      rect(0, 0, width, height);
    }
  }
  
  void displayFog() {
    // Draw fog as a semi-transparent overlay
    noStroke();
    fill(fogColor);
    rect(0, 0, width, height);
  }
  
  void displayWind() {
    // Draw wind particles
    noStroke();
    for (WindParticle particle : windParticles) {
      particle.display();
    }
  }
  
  void displayHeatwave() {
    // Draw heatwave distortion effect using a simplified approach
    if (intensity > 0.3) {
      // Add subtle warm tint
      fill(255, 200, 100, 20 * intensity);
      rect(0, 0, width, height);
      
      // Only visible with higher intensity
      if (intensity > 0.5) {
        stroke(255, 255, 255, 40 * intensity);
        strokeWeight(1);
        
        for (int y = height/3; y < height * 0.8; y += 20) {
          beginShape();
          noFill();
          for (int x = 0; x < width; x += 5) {
            float distortY = y + heatwaveDistortion[min(x, width-1)];
            vertex(x, distortY);
          }
          endShape();
        }
      }
    }
  }
  
  // Gameplay effect getters
  float getJumpModifier() {
    return jumpModifier;
  }
  
  float getSpeedModifier() {
    return speedModifier;
  }
  
  float getVisibilityModifier() {
    return visibilityModifier;
  }
  
  int getCurrentWeather() {
    return currentWeather;
  }
  
  float getIntensity() {
    return intensity;
  }
}

// Class for rain effect
class Raindrop {
  float x, y;
  float speed;
  float length;
  float alpha;
  float groundLevel;
  
  Raindrop() {
    x = random(width);
    y = random(-20, 0);
    speed = random(5, 15);
    length = map(speed, 5, 15, 10, 20);
    alpha = random(150, 200);
    groundLevel = height * 0.8; // Same as game ground level
  }
  
  void update() {
    y += speed;
  }
  
  void display() {
    stroke(100, 150, 255, alpha);
    line(x, y, x - 1, y + length);
  }
  
  boolean isFinished() {
    return y > groundLevel;
  }
}

// Class for wind effect
class WindParticle {
  float x, y;
  float speed;
  float size;
  float alpha;
  
  WindParticle() {
    x = random(-20, 0);
    y = random(height * 0.3, height * 0.7);
    speed = random(5, 15);
    size = random(2, 6);
    alpha = random(50, 120);
  }
  
  void update() {
    x += speed;
  }
  
  void display() {
    fill(200, 220, 255, alpha);
    ellipse(x, y, size, size/2);
  }
  
  boolean isOffscreen() {
    return x > width + 20;
  }
} 