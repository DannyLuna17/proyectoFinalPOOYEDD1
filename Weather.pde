class Weather {
  // Tipos de clima
  static final int CLEAR = 0;
  static final int RAIN = 1;
  static final int FOG = 2;
  static final int WIND = 3;
  static final int HEATWAVE = 4;
  
  // Estado actual
  int currentWeather = CLEAR;
  float intensity = 0; // 0.0 a 1.0
  float transitionProgress = 0;
  int transitionDuration = 180; // frames para la transición del clima
  boolean isTransitioning = false;
  int targetWeather = CLEAR;
  
  // Temporizadores y duraciones del clima
  int weatherTimer = 0;
  int weatherDuration = 600; // Duración base para eventos climáticos (10 segundos a 60fps)
  int clearDuration = 1200; // Duración base para períodos de clima despejado (20 segundos a 60fps)
  
  // Probabilidades del clima - pueden ser influenciadas por la salud del ecosistema
  float rainProbability = 0.3; 
  float fogProbability = 0.2;
  float windProbability = 0.2;
  float heatwaveProbability = 0.1;
  
  // Parámetros de efectos del clima
  float jumpModifier = 0; // -0.3 a +0.3
  float speedModifier = 0; // -0.3 a +0.3
  float visibilityModifier = 0; // -0.7 a 0
  
  // Elementos de efectos visuales
  ArrayList<Raindrop> raindrops;
  ArrayList<WindParticle> windParticles;
  color fogColor = color(255, 255, 255, 0);
  float fogOpacity = 0;
  float[] heatwaveDistortion;
  
  // Nombre del clima para mostrar
  String weatherName = "Clear";
  
  Weather() {
    raindrops = new ArrayList<Raindrop>();
    windParticles = new ArrayList<WindParticle>();
    heatwaveDistortion = new float[width];
    
    // Inicializar valores de distorsión de ola de calor
    for (int i = 0; i < width; i++) {
      heatwaveDistortion[i] = 0;
    }
  }
  
  void update(EcoSystem ecoSystem) {
    // Actualizar temporizador del clima
    weatherTimer++;
    
    // En modo de transición, avanzar la transición
    if (isTransitioning) {
      transitionProgress += 1.0 / transitionDuration;
      
      if (transitionProgress >= 1.0) {
        // Transición completa
        completeTransition();
      } else {
        // Actualizar intensidad durante la transición
        if (currentWeather == CLEAR) {
          // Transición de clima despejado a evento climático
          intensity = transitionProgress;
        } else if (targetWeather == CLEAR) {
          // Transición de evento climático a despejado
          intensity = 1.0 - transitionProgress;
        } else {
          // Transición entre dos eventos climáticos
          intensity = max(0.3, min(1.0, transitionProgress));
        }
      }
    } 
    
    // Comprobar si el clima debería cambiar
    if (!isTransitioning) {
      // Obtener la duración base para el clima actual
      int baseDuration = (currentWeather == CLEAR) ? clearDuration : weatherDuration;
      
      // Ajustar duración según la salud del ecosistema
      float durationMultiplier = 1.0;
      
      if (ecoSystem.isInCriticalState()) {
        // Clima más extremo en estado crítico
        if (currentWeather == CLEAR) {
          durationMultiplier = 0.7; // El clima despejado no dura tanto
        } else {
          durationMultiplier = 1.4; // El mal tiempo dura más
        }
      } else if (ecoSystem.isInWarningState()) {
        // Clima ligeramente más extremo en estado de advertencia
        if (currentWeather == CLEAR) {
          durationMultiplier = 0.9; // Clima despejado un poco más corto
        } else {
          durationMultiplier = 1.2; // Eventos climáticos un poco más largos
        }
      }
      
      int adjustedDuration = int(baseDuration * durationMultiplier);
      
      // Comprobar si es hora de un cambio de clima
      if (weatherTimer >= adjustedDuration) {
        selectNewWeather(ecoSystem);
      }
    }
    
    // Actualizar efectos visuales y parámetros según el estado del clima actual
    updateWeatherEffects();
    
    // Actualizar parámetros de jugabilidad
    updateGameplayParameters();
  }
  
  void selectNewWeather(EcoSystem ecoSystem) {
    // Reiniciar temporizador del clima
    weatherTimer = 0;
    
    // Determinar clima objetivo basado en probabilidades y estado del ecosistema
    float[] probabilities = new float[5]; // probabilidad para cada tipo de clima
    
    // Comenzar con probabilidades base
    probabilities[CLEAR] = 0.4; // 40% de probabilidad para clima despejado
    probabilities[RAIN] = rainProbability;
    probabilities[FOG] = fogProbability;
    probabilities[WIND] = windProbability;
    probabilities[HEATWAVE] = heatwaveProbability;
    
    // Ajustar probabilidades según el estado del ecosistema
    if (ecoSystem.isInCriticalState()) {
      // El estado crítico tiene clima más extremo, menos clima despejado
      probabilities[CLEAR] *= 0.5; // 50% menos probabilidad de clima despejado
      probabilities[RAIN] *= 1.5; // 50% más lluvia
      probabilities[FOG] *= 1.5; // 50% más niebla
      probabilities[WIND] *= 1.3; // 30% más viento
      probabilities[HEATWAVE] *= 2.0; // El doble de olas de calor
    } else if (ecoSystem.isInWarningState()) {
      // El estado de advertencia tiene clima ligeramente más extremo
      probabilities[CLEAR] *= 0.8; // 20% menos probabilidad de clima despejado
      probabilities[RAIN] *= 1.2; // 20% más lluvia
      probabilities[FOG] *= 1.2; // 20% más niebla
      probabilities[WIND] *= 1.1; // 10% más viento
      probabilities[HEATWAVE] *= 1.3; // 30% más olas de calor
    }
    
    // Nunca hacer transición al mismo clima (excepto despejado)
    if (currentWeather != CLEAR) {
      probabilities[currentWeather] = 0;
    }
    
    // Si ya está en clima despejado, forzar un cambio a un evento climático
    if (currentWeather == CLEAR) {
      probabilities[CLEAR] = 0;
    }
    
    // Normalizar probabilidades para asegurar que sumen 1.0
    float totalProbability = 0;
    for (int i = 0; i < probabilities.length; i++) {
      totalProbability += probabilities[i];
    }
    
    for (int i = 0; i < probabilities.length; i++) {
      probabilities[i] /= totalProbability;
    }
    
    // Seleccionar clima usando la distribución de probabilidad
    float random = random(1);
    float cumulativeProbability = 0;
    
    for (int i = 0; i < probabilities.length; i++) {
      cumulativeProbability += probabilities[i];
      if (random <= cumulativeProbability) {
        targetWeather = i;
        break;
      }
    }
    
    // Iniciar transición al nuevo clima
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
    
    // Establecer intensidad según el clima objetivo
    if (currentWeather == CLEAR) {
      intensity = 0;
    } else {
      // Intensidad aleatoria para el evento climático
      intensity = random(0.5, 1.0);
    }
    
    // Actualizar nombre del clima
    updateWeatherName();
  }
  
  void updateWeatherName() {
    switch (currentWeather) {
      case CLEAR:
        weatherName = "Despejado";
        break;
      case RAIN:
        if (intensity > 0.8) weatherName = "Lluvia Intensa";
        else if (intensity > 0.5) weatherName = "Lluvia";
        else weatherName = "Llovizna";
        break;
      case FOG:
        if (intensity > 0.8) weatherName = "Niebla Densa";
        else if (intensity > 0.5) weatherName = "Niebla";
        else weatherName = "Niebla Ligera";
        break;
      case WIND:
        if (intensity > 0.8) weatherName = "Viento Fuerte";
        else if (intensity > 0.5) weatherName = "Viento";
        else weatherName = "Brisa Suave";
        break;
      case HEATWAVE:
        if (intensity > 0.8) weatherName = "Calor Extremo";
        else if (intensity > 0.5) weatherName = "Ola de Calor";
        else weatherName = "Clima Cálido";
        break;
    }
  }
  
  void updateGameplayParameters() {
    // Reiniciar modificadores
    resetModifiers();
    
    // Aplicar efectos según el clima actual y su intensidad
    switch (currentWeather) {
      case RAIN:
        // La lluvia dificulta saltar y reduce ligeramente la velocidad
        jumpModifier = -0.2 * intensity;
        speedModifier = -0.1 * intensity;
        visibilityModifier = -0.3 * intensity;
        break;
      case FOG:
        // La niebla reduce significativamente la visibilidad pero no afecta mucho al movimiento
        visibilityModifier = -0.7 * intensity;
        break;
      case WIND:
        // El viento afecta al salto y a la velocidad
        jumpModifier = 0.15 * intensity; // Más fácil saltar con viento
        speedModifier = 0.2 * intensity; // Movimiento más rápido con viento
        break;
      case HEATWAVE:
        // La ola de calor reduce la velocidad pero no afecta al salto
        speedModifier = -0.25 * intensity;
        visibilityModifier = -0.15 * intensity; // Ligera distorsión por calor
        break;
    }
  }
  
  void updateWeatherEffects() {
    // Actualizar efectos visuales del clima según el clima actual y su intensidad
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
        // Clima despejado - eliminar cualquier efecto restante
        clearEffects();
    }
  }
  
  void updateRainEffects() {
    // Añadir nuevas gotas de lluvia según la intensidad
    int maxRaindrops = int(map(intensity, 0, 1, 10, 80));
    
    while (raindrops.size() < maxRaindrops) {
      raindrops.add(new Raindrop());
    }
    
    // Actualizar gotas existentes
    for (int i = raindrops.size() - 1; i >= 0; i--) {
      Raindrop drop = raindrops.get(i);
      drop.update();
      
      // Eliminar gotas terminadas
      if (drop.isFinished()) {
        raindrops.remove(i);
      }
    }
  }
  
  void updateFogEffects() {
    // Ajustar opacidad de la niebla según la intensidad
    fogOpacity = intensity * 180; // Opacidad máxima de 180 (semi-transparente)
    fogColor = color(255, 255, 255, fogOpacity);
  }
  
  void updateWindEffects() {
    // Añadir nuevas partículas de viento según la intensidad
    int maxParticles = int(map(intensity, 0, 1, 10, 50));
    
    while (windParticles.size() < maxParticles) {
      windParticles.add(new WindParticle());
    }
    
    // Actualizar partículas existentes
    for (int i = windParticles.size() - 1; i >= 0; i--) {
      WindParticle particle = windParticles.get(i);
      particle.update();
      
      // Eliminar partículas fuera de pantalla
      if (particle.isOffscreen()) {
        windParticles.remove(i);
      }
    }
  }
  
  void updateHeatwaveEffects() {
    // Actualizar valores de distorsión de ola de calor
    for (int i = 0; i < width; i++) {
      // Crear patrones ondulados usando la función seno
      float waveSpeed = frameCount * 0.02;
      float waveDensity = i * 0.01;
      float waveHeight = 5 * intensity;
      
      heatwaveDistortion[i] = sin(waveSpeed + waveDensity) * waveHeight;
    }
  }
  
  void clearEffects() {
    // Eliminar todos los efectos visuales
    raindrops.clear();
    windParticles.clear();
    fogOpacity = 0;
    
    for (int i = 0; i < width; i++) {
      heatwaveDistortion[i] = 0;
    }
  }
  
  // Método principal de visualización (ahora solo para efectos en primer plano)
  void display() {
    // Dibujar efectos de clima en primer plano según el clima actual
    switch (currentWeather) {
      case RAIN:
        displayRain();
        break;
      case WIND:
        displayWind();
        break;
      case HEATWAVE:
        // Solo mostrar las líneas de distorsión de ola de calor (no el tinte de fondo)
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
        break;
    }
  }
  
  // Mostrar efectos de clima de fondo (llamado antes de dibujar los elementos del juego)
  void displayBackgroundEffects() {
    // Solo mostrar efectos de fondo para ciertos tipos de clima
    switch (currentWeather) {
      case FOG:
        // Dibujar niebla como una capa de fondo
        noStroke();
        fill(fogColor);
        rect(0, 0, width, height);
        break;
      case HEATWAVE:
        // Dibujar efectos de fondo de ola de calor
        if (intensity > 0.3) {
          // Añadir un tinte cálido sutil como capa de fondo
          fill(255, 200, 100, 20 * intensity);
          rect(0, 0, width, height);
        }
        break;
    }
  }
  
  void displayRain() {
    // Dibujar gotas de lluvia
    stroke(100, 150, 255, 150);
    strokeWeight(2);
    
    for (Raindrop drop : raindrops) {
      drop.display();
    }
    
    // Añadir una superposición azul ligera para lluvia intensa
    if (intensity > 0.7) {
      fill(100, 150, 255, 30 * intensity);
      rect(0, 0, width, height);
    }
  }
  
  void displayWind() {
    // Dibujar partículas de viento
    noStroke();
    for (WindParticle particle : windParticles) {
      particle.display();
    }
  }
  
  // Captadores de efectos de jugabilidad
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
  
  // Reiniciar modificadores
  void resetModifiers() {
    jumpModifier = 0;
    speedModifier = 0;
    visibilityModifier = 0;
  }
}

// Clase para efecto de lluvia
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
    groundLevel = height * 0.8; // Igual que el nivel del suelo del juego
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

// Clase para efecto de viento
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