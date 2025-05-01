class Collectible {
  float x, y;
  float size;
  float speed;
  
  // Tipos de coleccionables
  static final int COIN = 0;        // Moneda básica
  static final int GEM = 1;         // Gema (más valor)
  static final int SHIELD = 2;      // Escudo temporal
  static final int SPEED_BOOST = 3; // Aumento de velocidad
  static final int DOUBLE_POINTS = 4; // Puntos dobles
  static final int HEART = 5;       // Corazón (vida extra)
  
  // Coleccionables ambientales
  static final int ECO_POSITIVE = 6; // Items ecológicos 
  static final int ECO_NEGATIVE = 7; // Items contaminantes
  
  // Tipos específicos de coleccionables ambientales
  static final int ECO_BOOST = 8;    // Mejora el ecosistema
  static final int ECO_CLEANUP = 9;  // Limpia la contaminación
  
  // Valores por tipo
  final int[] VALUE_BY_TYPE = {
    10,    // COIN
    50,    // GEM
    20,    // SHIELD
    15,    // SPEED_BOOST
    15,    // DOUBLE_POINTS
    30,    // HEART
    40,    // ECO_POSITIVE
    -30,   // ECO_NEGATIVE
    50,    // ECO_BOOST
    75     // ECO_CLEANUP
  };
  
  // Duración en frames (60 fps)
  final int[] DURATION_BY_TYPE = {
    0,     // COIN
    0,     // GEM
    300,   // SHIELD - 5 segundos
    240,   // SPEED_BOOST - 4 segundos
    360,   // DOUBLE_POINTS - 6 segundos
    0,     // HEART
    0,     // ECO_POSITIVE
    0,     // ECO_NEGATIVE
    0,     // ECO_BOOST
    0      // ECO_CLEANUP
  };
  
  int type;
  color itemColor;
  float rotation = 0;
  boolean collected = false;
  
  // Valores ambientales
  float ecoImpact = 0; // Positivo ayuda, negativo daña
  
  // Animación al recoger
  boolean animating = false;
  float animationTime = 0;
  float maxAnimationTime = 30;
  
  // Platform binding properties
  boolean isPlatformBound = false;
  Platform boundPlatform = null;
  
  // Efectos de partículas
  ArrayList<Particle> particles;
  
  // Constructor with default size and speed
  Collectible(float x, float y, int type) {
    // Default size of 30 and speed of 5
    this(x, y, 30, 5, type);
  }
  
  Collectible(float x, float y, float size, float speed, int type) {
    this.x = x;
    this.y = y;
    this.size = size;
    this.speed = speed;
    this.type = type;
    this.particles = new ArrayList<Particle>();
    
    setupVisuals();
    setupEcoImpact();
  }
  
  // Method to bind a collectible to a platform
  void setPlatformBound(boolean bound, Platform platform) {
    this.isPlatformBound = bound;
    this.boundPlatform = platform;
  }
  
  void setupVisuals() {
    // Color según tipo
    switch(type) {
      case COIN:
        itemColor = color(255, 215, 0); // Dorado
        break;
      case GEM:
        itemColor = color(0, 191, 255); // Azul
        break;
      case SHIELD:
        itemColor = color(100, 255, 100); // Verde
        break;
      case SPEED_BOOST:
        itemColor = color(255, 50, 50); // Rojo
        break;
      case DOUBLE_POINTS:
        itemColor = color(255, 100, 255); // Morado
        break;
      case HEART:
        itemColor = color(255, 50, 50); // Rojo brillante
        break;
      case ECO_POSITIVE:
        itemColor = color(0, 200, 100); // Verde brillante
        break;
      case ECO_NEGATIVE:
        itemColor = color(100, 0, 0); // Rojo oscuro
        break;
      case ECO_BOOST:
        itemColor = color(0, 255, 0); // Verde brillante
        break;
      case ECO_CLEANUP:
        itemColor = color(255, 255, 0); // Amarillo
        break;
      default:
        itemColor = color(255, 215, 0); // Dorado por defecto
    }
  }
  
  void setupEcoImpact() {
    switch(type) {
      case COIN:
        ecoImpact = 0; // Neutral
        break;
      case GEM:
        ecoImpact = 2; // Ligero positivo
        break;
      case SHIELD:
        ecoImpact = 5; // Moderado positivo
        break;
      case SPEED_BOOST:
        ecoImpact = 0; // Neutral
        break;
      case DOUBLE_POINTS:
        ecoImpact = 3; // Ligero positivo
        break;
      case HEART:
        ecoImpact = 0; // Neutral
        break;
      case ECO_POSITIVE:
        ecoImpact = 10; // Muy positivo
        break;
      case ECO_NEGATIVE:
        ecoImpact = -15; // Muy negativo
        break;
      case ECO_BOOST:
        ecoImpact = 5; // Moderado positivo
        break;
      case ECO_CLEANUP:
        ecoImpact = 7; // Muy positivo
        break;
      default:
        ecoImpact = 0; // Neutral
    }
  }
  
  void update() {
    // Mover de derecha a izquierda
    x -= speed;
    
    // Rotar para animar
    rotation += 0.05;
    
    // Animación al recoger
    if (animating) {
      animationTime++;
      
      // Generar partículas
      if (animationTime < 10 && animationTime % 3 == 0) {
        for (int i = 0; i < 3; i++) {
          particles.add(new Particle(x, y, itemColor));
        }
      }
      
      if (animationTime >= maxAnimationTime) {
        collected = true;
      }
    }
    
    // Actualizar partículas
    for (int i = particles.size() - 1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.update();
      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }
  
  void update(float obstacleSpeed) {
    // Mover de derecha a izquierda usando la velocidad proporcionada
    x -= obstacleSpeed;
    
    // Rotar para animar
    rotation += 0.05;
    
    // Animación al recoger
    if (animating) {
      animationTime++;
      
      // Generar partículas
      if (animationTime < 10 && animationTime % 3 == 0) {
        for (int i = 0; i < 3; i++) {
          particles.add(new Particle(x, y, itemColor));
        }
      }
      
      if (animationTime >= maxAnimationTime) {
        collected = true;
      }
    }
    
    // Actualizar partículas
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
      // Solo dibujar partículas
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
    
    // Dibujar según tipo
    switch(type) {
      case COIN:
        ellipse(0, 0, size, size);
        fill(255, 235, 50);
        ellipse(0, 0, size * 0.7, size * 0.7);
        break;
        
      case GEM:
        beginShape();
        vertex(0, -size/2);
        vertex(size/2, 0);
        vertex(0, size/2);
        vertex(-size/2, 0);
        endShape(CLOSE);
        fill(100, 220, 255);
        beginShape();
        vertex(0, -size/3);
        vertex(size/3, 0);
        vertex(0, size/3);
        vertex(-size/3, 0);
        endShape(CLOSE);
        break;
        
      case SHIELD:
        ellipse(0, 0, size, size);
        fill(150, 255, 150);
        ellipse(0, 0, size * 0.7, size * 0.7);
        fill(200, 255, 200);
        ellipse(0, 0, size * 0.4, size * 0.4);
        break;
        
      case SPEED_BOOST:
        fill(255, 100, 100);
        beginShape();
        vertex(-size/4, -size/2);
        vertex(size/4, -size/4);
        vertex(-size/4, size/4);
        vertex(size/4, size/2);
        endShape(CLOSE);
        fill(255, 200, 200);
        ellipse(0, 0, size * 0.3, size * 0.3);
        break;
        
      case DOUBLE_POINTS:
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
        
      case HEART:
        // Dibujar un corazón
        noStroke();
        // Color principal más saturado
        fill(255, 30, 30);
        beginShape();
        // Un corazón hecho con vértices y curvas bezier
        vertex(0, size/4);
        bezierVertex(0, 0, -size/2, 0, -size/2, -size/4);
        bezierVertex(-size/2, -size/2, 0, -size/2, 0, -size/4);
        bezierVertex(0, -size/2, size/2, -size/2, size/2, -size/4);
        bezierVertex(size/2, 0, 0, 0, 0, size/4);
        endShape(CLOSE);
        
        // Efecto de brillo pulsante (usando frameCount para animación)
        float pulse = sin(frameCount * 0.1) * 0.5 + 0.5;
        fill(255, 150 + pulse * 100, 150 + pulse * 50);
        ellipse(-size/5, -size/5, size/4, size/4);
        
        // Contorno sutil para destacarlo más
        noFill();
        stroke(255, 220, 220, 150);
        strokeWeight(2);
        beginShape();
        vertex(0, size/4 - 2);
        bezierVertex(0, -2, -size/2 + 2, -2, -size/2 + 2, -size/4);
        bezierVertex(-size/2 + 2, -size/2 + 2, 0, -size/2 + 2, 0, -size/4);
        bezierVertex(0, -size/2 + 2, size/2 - 2, -size/2 + 2, size/2 - 2, -size/4);
        bezierVertex(size/2 - 2, -2, 0, -2, 0, size/4 - 2);
        endShape(CLOSE);
        break;
      
      case ECO_POSITIVE:
        float s = size * 0.8;
        strokeWeight(size/10);
        stroke(0, 150, 0);
        noFill();
        triangle(0, -s/2, s/2, s/3, -s/2, s/3);
        
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
        fill(100, 0, 0);
        rect(-size/3, -size/4, size/6, size/2); // Chimenea izq
        rect(size/6, -size/3, size/6, size/2);  // Chimenea der
        rect(-size/2, size/4, size, size/4);    // Base fábrica
        
        fill(80, 80, 80, 200);
        ellipse(-size/3, -size/3, size/3, size/3);
        ellipse(size/6, -size/2, size/3, size/3);
        ellipse(-size/5, -size/2, size/4, size/4);
        break;
        
      case ECO_BOOST:
        fill(0, 255, 0);
        ellipse(0, 0, size * 0.8, size * 0.8);
        break;
        
      case ECO_CLEANUP:
        fill(255, 255, 0);
        ellipse(0, 0, size * 0.8, size * 0.8);
        break;
    }
    
    popStyle();
    popMatrix();
  }
  
  void collect() {
    if (!animating && !collected) {
      animating = true;
      animationTime = 0;
      
      for (int i = 0; i < 10; i++) {
        particles.add(new Particle(x, y, itemColor));
      }
    }
  }
  
  boolean isOffScreen() {
    return x < -size;
  }
  
  int getPointValue() {
    if (type >= 0 && type < VALUE_BY_TYPE.length) {
      return VALUE_BY_TYPE[type];
    }
    return 10; // Valor por defecto
  }
  
  int getPowerUpDuration() {
    if (type >= 0 && type < DURATION_BY_TYPE.length) {
      return DURATION_BY_TYPE[type];
    }
    return 300; // Duración por defecto
  }
  
  boolean isPowerUp() {
    return type == SHIELD || type == SPEED_BOOST || type == DOUBLE_POINTS;
  }
  
  boolean hasEcoImpact() {
    return ecoImpact != 0;
  }
  
  float getEcoImpact() {
    return ecoImpact;
  }
  
  int getValue() {
    return getPointValue(); // Redirige al método existente
  }
  
  int getType() {
    return type;
  }
  
  color getColor() {
    return itemColor;
  }
  
  boolean checkCollision(Player player) {
    // Calculate distance between player and collectible
    float distance = dist(x, y, player.x, player.y);
    
    // Use average of player and collectible sizes for collision detection
    float collisionThreshold = (size + player.size) * 0.4;
    
    // Return true if collision detected
    return distance < collisionThreshold;
  }
}

// Clase para efectos de partículas
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