/**
 * Sistema de clima para el juego.
 */

class Weather {
  // Tipos de clima
  static final int CLEAR = 0;  // Despejado
  static final int FOG = 1;    // Niebla
  static final int WIND = 2;   // Viento
  static final int HEATWAVE = 3; // Ola de calor
  static final int RAIN = 4;   // Lluvia
  
  // Estado de clima actual
  int currentWeather = CLEAR;
  int targetWeather = CLEAR;
  float intensity = 0; // 0 a 1
  
  // Temporizadores y duración
  int weatherTimer = 0;
  int weatherDuration = 600; // 10 segundos aproximadamente para climas
  int clearDuration = 1200;  // 20 segundos aproximadamente para clima despejado
  
  // Transición
  boolean isTransitioning = false;
  float transitionProgress = 0;
  int transitionDuration = 180; // 3 segundos de transición
  
  // Probabilidades de los tipos de clima
  float fogProbability = 0.2;
  float windProbability = 0.2;
  float heatwaveProbability = 0.1;
  float rainProbability = 0.25; // Alta probabilidad para lluvia
  
  // Parámetros de efectos del clima
  float jumpModifier = 0; // -0.3 a +0.3
  float speedModifier = 0; // -0.3 a +0.3
  float visibilityModifier = 0; // -0.7 a 0
  
  // Elementos de efectos visuales
  Queue<WindParticle> windParticles;
  color fogColor = color(255, 255, 255, 0);
  float fogOpacity = 0;
  float[] heatwaveDistortion;
  
  // Elementos para efecto de lluvia
  PImage rainImage;
  float rainX = 0;
  float rainY = 0;
  float rainSpeed = 10;
  float rainAlpha = 220; // Transparencia del efecto
  
  // Nombre del clima para mostrar
  String weatherName = "Clear";
  
  // Referencia al AssetManager
  AssetManager assetManager;
  
  Weather() {
    this(null);
  }
  
  Weather(AssetManager assetManager) {
    this.assetManager = assetManager;
    
    windParticles = new Queue<WindParticle>();
    heatwaveDistortion = new float[width];
    
    // Inicializar valores de distorsión de ola de calor
    for (int i = 0; i < width; i++) {
      heatwaveDistortion[i] = 0;
    }
    
    // Intentar cargar la imagen de lluvia si tenemos AssetManager
    if (assetManager != null) {
      rainImage = assetManager.getRainImage();
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
    float[] probabilities = new float[5]; // aumentado de 4 a 5 para incluir RAIN
    
    // Comenzar con probabilidades base
    probabilities[CLEAR] = 0.4; // 40% de probabilidad para clima despejado
    probabilities[FOG] = fogProbability;
    probabilities[WIND] = windProbability;
    probabilities[HEATWAVE] = heatwaveProbability;
    probabilities[RAIN] = rainProbability;
    
    // Ajustar probabilidades según el estado del ecosistema
    if (ecoSystem.isInCriticalState()) {
      // El estado crítico tiene clima más extremo, menos clima despejado
      probabilities[CLEAR] *= 0.5; // 50% menos probabilidad de clima despejado
      probabilities[FOG] *= 1.5; // 50% más niebla
      probabilities[WIND] *= 1.3; // 30% más viento
      probabilities[HEATWAVE] *= 2.0; // El doble de olas de calor
      probabilities[RAIN] *= 1.8; // 80% más lluvia
    } else if (ecoSystem.isInWarningState()) {
      // El estado de advertencia tiene clima ligeramente más extremo
      probabilities[CLEAR] *= 0.8; // 20% menos probabilidad de clima despejado
      probabilities[FOG] *= 1.2; // 20% más niebla
      probabilities[WIND] *= 1.1; // 10% más viento
      probabilities[HEATWAVE] *= 1.3; // 30% más olas de calor
      probabilities[RAIN] *= 1.4; // 40% más lluvia
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
      case RAIN:
        if (intensity > 0.8) weatherName = "Tormenta";
        else if (intensity > 0.5) weatherName = "Lluvia";
        else weatherName = "Llovizna";
        break;
    }
  }
  
  void updateGameplayParameters() {
    // Reiniciar modificadores
    resetModifiers();
    
    // Aplicar efectos según el clima actual y su intensidad
    switch (currentWeather) {
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
      case RAIN:
        // La lluvia hace un poco más difícil el salto y reduce ligeramente la velocidad
        jumpModifier = -0.1 * intensity;
        speedModifier = -0.15 * intensity;
        visibilityModifier = -0.3 * intensity; // Reducción moderada de visibilidad
        break;
    }
  }
  
  void updateWeatherEffects() {
    // Actualizar niebla
    if (currentWeather == FOG) {
      updateFogEffects();
    } else if (currentWeather == WIND) {
      // Actualizar efecto de viento (partículas)
      // Generar nuevas partículas basadas en la intensidad
      int particleAmount = floor(intensity * 2); // hasta 1-2 partículas por frame
      
      for (int i = 0; i < particleAmount; i++) {
        if (random(1) < 0.2 * intensity) {
          float xPos = width + random(50);
          float yPos = random(height);
          float speedMultiplier = 0.5 + random(1) * intensity;
          WindParticle particle = new WindParticle(xPos, yPos, speedMultiplier);
          // windParticles.add(particle);
          windParticles.enqueue(particle);
        }
      }
    } else if (currentWeather == RAIN) {
      // Actualizar posición del efecto de lluvia
      updateRainEffects();
    }
    
    // Actualizar partículas de viento
    // Eliminar partículas que han salido de la pantalla
    // for (int i = windParticles.size() - 1; i >= 0; i--) {
    //   WindParticle particle = windParticles.get(i);
    //   particle.update();
    //   
    //   if (particle.isDead()) {
    //     windParticles.remove(i);
    //   }
    // }
    
    // Actualizar y eliminar partículas usando Queue
    int particleCount = windParticles.size();
    for (int i = 0; i < particleCount; i++) {
      WindParticle particle = windParticles.dequeue();
      particle.update();
      
      // Si la partícula sigue viva, volver a ponerla en la cola
      if (!particle.isDead()) {
        windParticles.enqueue(particle);
      }
      // Si está muerta, no la volvemos a poner en la cola
    }
    
    // Actualizar efectos visuales del clima según el clima actual y su intensidad
    switch (currentWeather) {
      case FOG:
        updateFogEffects();
        break;
      case WIND:
        updateWindEffects();
        break;
      case HEATWAVE:
        updateHeatwaveEffects();
        break;
      case RAIN:
        updateRainEffects();
        break;
      default:
        // Clima despejado - eliminar cualquier efecto restante
        clearEffects();
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
    
    int currentParticleCount = windParticles.size();
    
    while (currentParticleCount < maxParticles) {
      // Crear una partícula con valores aleatorios
      float randomX = width + random(50);
      float randomY = random(height);
      float speedMultiplier = 0.5 + random(1) * intensity;
      
      // windParticles.add(new WindParticle());
      windParticles.enqueue(new WindParticle(randomX, randomY, speedMultiplier));
      currentParticleCount++;
    }
    
    // Actualizar partículas existentes
    // Aquí necesitamos actualizar todas las partículas y eliminar las que estén fuera de pantalla
    
    // Crear una cola temporal para las partículas que vamos a mantener
    Queue<WindParticle> tempQueue = new Queue<WindParticle>();
    int tempSize = windParticles.size();  // Guardar el tamaño original
    
    // Procesar todas las partículas
    for (int i = 0; i < tempSize; i++) {
      WindParticle particle = windParticles.dequeue();
      particle.update();
      
      // Si la partícula sigue en pantalla, guardarla
      if (!particle.isOffscreen()) {
        tempQueue.enqueue(particle);
      }
    }
    
    // Reemplazar la cola original con la filtrada
    windParticles = tempQueue;
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
  
  void updateRainEffects() {
    // Actualizar posición del overlay de lluvia
    rainY += rainSpeed * intensity;
    
    // Si la imagen se salió de la pantalla, reiniciarla arriba
    if (rainY > height) {
      rainY = -rainImage.height + (rainY - height);
    }
    
    // Ajustar transparencia según intensidad
    rainAlpha = 150 + (70 * intensity);
  }
  
  void clearEffects() {
    // Eliminar todos los efectos visuales
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
      case RAIN:
        displayRain();
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
      case RAIN:
        // Añadir un tinte ligeramente azulado/grisáceo para clima lluvioso
        noStroke();
        fill(100, 120, 150, 25 * intensity);
        rect(0, 0, width, height);
        break;
    }
  }
  
  void displayWind() {
    // Dibujar partículas de viento
    noStroke();
    
    // Necesitamos iterar sobre todas las partículas sin perderlas
    Queue<WindParticle> tempQueue = new Queue<WindParticle>();
    
    while (!windParticles.isEmpty()) {
      WindParticle particle = windParticles.dequeue();
      particle.display();
      tempQueue.enqueue(particle);
    }
    
    // Restaurar la cola original
    windParticles = tempQueue;
  }
  
  void displayRain() {
    // Primero asegurar que tenemos la imagen de lluvia
    if (rainImage == null && assetManager != null) {
      // Intentar obtener la imagen desde AssetManager
      rainImage = assetManager.getRainImage();
      
      // Si todavía es nula, no podemos mostrar el efecto
      if (rainImage == null) {
        return;
      }
    }
    
    if (rainImage == null) return;
    
    // Aplicar transparencia a la imagen de lluvia
    tint(255, rainAlpha);
    
    // Calcular cuántas veces necesitamos repetir la imagen horizontal y verticalmente
    int numCopiesX = ceil(width / (float)rainImage.width) + 1;
    int numCopiesY = ceil(height / (float)rainImage.height) + 1;
    
    // Dibujar la matriz de imágenes para cubrir toda la pantalla
    for (int y = 0; y < numCopiesY; y++) {
      // Calcular posición Y con desplazamiento
      float yPos = (rainY % rainImage.height) + (y * rainImage.height) - rainImage.height;
      
      for (int x = 0; x < numCopiesX; x++) {
        float xPos = x * rainImage.width;
        image(rainImage, xPos, yPos);
      }
    }
    
    // Restaurar configuración de tinte
    noTint();
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

// Clase para partículas de viento
class WindParticle {
  float x, y;
  float speed;
  float alpha;
  float size;
  
  WindParticle(float x, float y, float speedMultiplier) {
    this.x = x;
    this.y = y;
    this.speed = (10 + random(5)) * speedMultiplier;
    this.alpha = 120 + random(100);
    this.size = 2 + random(4);
  }
  
  void update() {
    x -= speed;
    alpha -= 0.5;
  }
  
  void display() {
    pushStyle();
    noStroke();
    fill(255, 255, 255, alpha);
    ellipse(x, y, size, size/2);
    line(x, y, x + size*1.5, y);
    popStyle();
  }
  
  boolean isDead() {
    return x < -10 || alpha <= 0;
  }
  
  boolean isOffscreen() {
    return x < -10 || x > width || y < -10 || y > height;
  }
} 