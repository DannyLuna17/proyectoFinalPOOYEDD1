class Collectible {
  float x, y;
  float size;
  float speed;
  
  // Collectible type constants
  static final int COIN = 0;        // Basic points collectible
  static final int GEM = 1;         // High-value collectible
  static final int SHIELD = 2;      // Invincibility power-up
  static final int SPEED_BOOST = 3; // Increased speed power-up
  static final int DOUBLE_POINTS = 4; // Double points power-up
  
  // Environmental collectible types
  static final int ECO_POSITIVE = 5; // Eco-friendly items (recycling, renewable energy)
  static final int ECO_NEGATIVE = 6; // Harmful items (pollution, waste)
  
  int type;
  color itemColor;
  float rotation = 0;
  boolean collected = false;
  
  // Environmental impact values
  float ecoImpact = 0; // Positive values help environment, negative values harm it
  
  // Collection animation
  boolean animating = false;
  float animationTime = 0;
  float maxAnimationTime = 30;
  
  // Particle effects (simple implementation)
  ArrayList<Particle> particles;
  
  Collectible(float x, float y, float size, float speed, int type) {
    this.x = x;
    this.y = y;
    this.size = size;
    this.speed = speed;
    this.type = type;
    this.particles = new ArrayList<Particle>();
    
    // Assign color based on type
    setupVisuals();
    
    // Assign environmental impact value based on type
    setupEcoImpact();
  }
  
  void setupVisuals() {
    // Assign colors and properties based on collectible type
    switch(type) {
      case COIN:
        itemColor = color(255, 215, 0); // Gold
        break;
      case GEM:
        itemColor = color(0, 191, 255); // Deep blue
        break;
      case SHIELD:
        itemColor = color(100, 255, 100); // Green
        break;
      case SPEED_BOOST:
        itemColor = color(255, 50, 50); // Red
        break;
      case DOUBLE_POINTS:
        itemColor = color(255, 100, 255); // Purple
        break;
      case ECO_POSITIVE:
        itemColor = color(0, 200, 100); // Bright green
        break;
      case ECO_NEGATIVE:
        itemColor = color(100, 0, 0); // Dark red
        break;
      default:
        itemColor = color(255, 215, 0); // Default gold
    }
  }
  
  void setupEcoImpact() {
    // Set the environmental impact based on collectible type
    switch(type) {
      case COIN:
        ecoImpact = 0; // Neutral impact
        break;
      case GEM:
        ecoImpact = 2; // Slightly positive impact
        break;
      case SHIELD:
        ecoImpact = 5; // Moderate positive impact
        break;
      case SPEED_BOOST:
        ecoImpact = 0; // Neutral impact
        break;
      case DOUBLE_POINTS:
        ecoImpact = 3; // Slightly positive impact
        break;
      case ECO_POSITIVE:
        ecoImpact = 10; // Strong positive impact
        break;
      case ECO_NEGATIVE:
        ecoImpact = -15; // Strong negative impact
        break;
      default:
        ecoImpact = 0; // Default - neutral impact
    }
  }
  
  void update() {
    // Move collectible from right to left
    x -= speed;
    
    // Simple animation - rotate the collectible
    rotation += 0.05;
    
    // Handle collection animation
    if (animating) {
      animationTime++;
      
      // Generate particles during animation
      if (animationTime < 10 && animationTime % 3 == 0) {
        for (int i = 0; i < 3; i++) {
          particles.add(new Particle(x, y, itemColor));
        }
      }
      
      // End of animation
      if (animationTime >= maxAnimationTime) {
        collected = true;
      }
    }
    
    // Update particles
    for (int i = particles.size() - 1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.update();
      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }
  
  void display() {
    if (animating) {
      // Draw only particles during animation
      for (Particle p : particles) {
        p.display();
      }
      return;
    }
    
    pushMatrix();
    pushStyle();
    
    translate(x, y);
    rotate(rotation);
    
    fill(itemColor);
    noStroke();
    
    // Draw different shapes based on collectible type
    switch(type) {
      case COIN:
        // Simple circle for coins
        ellipse(0, 0, size, size);
        // Inner detail
        fill(255, 235, 50);
        ellipse(0, 0, size * 0.7, size * 0.7);
        break;
        
      case GEM:
        // Diamond shape for gems
        beginShape();
        vertex(0, -size/2);
        vertex(size/2, 0);
        vertex(0, size/2);
        vertex(-size/2, 0);
        endShape(CLOSE);
        // Inner detail
        fill(100, 220, 255);
        beginShape();
        vertex(0, -size/3);
        vertex(size/3, 0);
        vertex(0, size/3);
        vertex(-size/3, 0);
        endShape(CLOSE);
        break;
        
      case SHIELD:
        // Shield shape
        ellipse(0, 0, size, size);
        fill(150, 255, 150);
        ellipse(0, 0, size * 0.7, size * 0.7);
        fill(200, 255, 200);
        ellipse(0, 0, size * 0.4, size * 0.4);
        break;
        
      case SPEED_BOOST:
        // Lightning bolt for speed
        fill(255, 100, 100);
        beginShape();
        vertex(-size/4, -size/2);
        vertex(size/4, -size/4);
        vertex(-size/4, size/4);
        vertex(size/4, size/2);
        endShape(CLOSE);
        // Highlight
        fill(255, 200, 200);
        ellipse(0, 0, size * 0.3, size * 0.3);
        break;
        
      case DOUBLE_POINTS:
        // Star shape for double points
        float angle = TWO_PI / 5;
        float halfAngle = angle/2.0;
        beginShape();
        for (float a = 0; a < TWO_PI; a += angle) {
          float sx = cos(a) * size/2;
          float sy = sin(a) * size/2;
          vertex(sx, sy);
          sx = cos(a+halfAngle) * size/4;
          sy = sin(a+halfAngle) * size/4;
          vertex(sx, sy);
        }
        endShape(CLOSE);
        break;
      
      case ECO_POSITIVE:
        // Recycling symbol or leaf shape for eco-friendly items
        // Draw a recycling triangle
        float s = size * 0.8;
        strokeWeight(size/10);
        stroke(0, 150, 0);
        noFill();
        triangle(0, -s/2, s/2, s/3, -s/2, s/3);
        
        // Add recycling arrows
        stroke(0, 200, 0);
        line(-s/4, s/6, 0, -s/4);
        line(s/4, s/6, 0, -s/4);
        line(-s/4, s/6, -s/6, s/3);
        line(s/4, s/6, s/6, s/3);
        noStroke();
        fill(0, 220, 100);
        ellipse(0, 0, size * 0.3, size * 0.3);
        break;
        
      case ECO_NEGATIVE:
        // Pollution or waste symbol for harmful items
        // Draw a factory/smokestack
        fill(100, 0, 0);
        rect(-size/3, -size/4, size/6, size/2); // Left chimney
        rect(size/6, -size/3, size/6, size/2);  // Right chimney
        rect(-size/2, size/4, size, size/4);    // Factory base
        
        // Smoke clouds
        fill(80, 80, 80, 200);
        ellipse(-size/3, -size/3, size/3, size/3);
        ellipse(size/6, -size/2, size/3, size/3);
        ellipse(-size/5, -size/2, size/4, size/4);
        break;
    }
    
    popStyle();
    popMatrix();
  }
  
  void collect() {
    if (!animating && !collected) {
      animating = true;
      animationTime = 0;
      
      // Generate initial particles
      for (int i = 0; i < 10; i++) {
        particles.add(new Particle(x, y, itemColor));
      }
    }
  }
  
  boolean isOffscreen() {
    return x < -size;
  }
  
  // Get point value of collectible
  int getPointValue() {
    switch(type) {
      case COIN: return 50;
      case GEM: return 200;
      case ECO_POSITIVE: return 100;
      case ECO_NEGATIVE: return 25; // Lower points for eco-negative items
      default: return 25;
    }
  }
  
  // Get power-up duration in frames (60 = 1 second at 60fps)
  int getPowerUpDuration() {
    switch(type) {
      case SHIELD: return 300; // 5 seconds
      case SPEED_BOOST: return 180; // 3 seconds
      case DOUBLE_POINTS: return 300; // 5 seconds
      default: return 0;
    }
  }
  
  // Helper method to check if this is a power-up type
  boolean isPowerUp() {
    return type == SHIELD || type == SPEED_BOOST || type == DOUBLE_POINTS;
  }
  
  // Helper method to check if this has environmental impact
  boolean hasEcoImpact() {
    return ecoImpact != 0;
  }
  
  // Get the environmental impact value
  float getEcoImpact() {
    return ecoImpact;
  }
}

// Simple particle class for collection effects
class Particle {
  PVector position;
  PVector velocity;
  color particleColor;
  float size;
  float lifespan;
  
  Particle(float x, float y, color c) {
    position = new PVector(x, y);
    velocity = PVector.random2D();
    velocity.mult(random(1, 3));
    particleColor = c;
    size = random(3, 8);
    lifespan = 255;
  }
  
  void update() {
    position.add(velocity);
    lifespan -= 10;
    size *= 0.95;
  }
  
  void display() {
    pushStyle();
    noStroke();
    fill(red(particleColor), green(particleColor), blue(particleColor), lifespan);
    ellipse(position.x, position.y, size, size);
    popStyle();
  }
  
  boolean isDead() {
    return lifespan <= 0;
  }
} 