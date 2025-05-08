/**
 * PowerUp.pde
 * 
 * Clase que maneja los efectos de power-ups en el juego.
 * Los power-ups pueden ser recogidos y proporcionan beneficios temporales al jugador.
 * Esta clase gestiona la visualización de power-ups en el HUD y rastrea su duración.
 */

class PowerUp {
  // Tipos de power-up
  static final int SHIELD = 1;
  static final int SPEED_BOOST = 2;
  static final int DOUBLE_POINTS = 3;
  
  int type;
  int duration; // Duración en frames
  int timeRemaining; // Tiempo restante para el efecto del power-up
  boolean isActive;
   
  // Para efectos visuales
  color effectColor;
  PVector position = new PVector(0, 0);
  boolean showInHUD = false;
  
  // Accesibilidad
  AccessibilityManager accessManager;
  
  // Gestor de assets
  AssetManager assetManager;
  
  PowerUp(int type, int duration) {
    this.type = type;
    this.duration = duration;
    this.timeRemaining = duration;
    this.isActive = true;
    
    // Color predeterminado según el tipo
    setEffectProperties();
    
    // Gestor de accesibilidad predeterminado
    this.accessManager = new AccessibilityManager();
  }
  
  // Constructor con gestor de accesibilidad
  PowerUp(int type, int duration, AccessibilityManager accessManager) {
    this.type = type;
    this.duration = duration;
    this.timeRemaining = duration;
    this.isActive = true;
    
    // Color predeterminado según el tipo
    setEffectProperties();
    
    // Guardar el gestor de accesibilidad proporcionado
    this.accessManager = accessManager;
  }
  
  // Constructor con gestor de accesibilidad y assetManager
  PowerUp(int type, int duration, AccessibilityManager accessManager, AssetManager assetManager) {
    this.type = type;
    this.duration = duration;
    this.timeRemaining = duration;
    this.isActive = true;
    
    // Color predeterminado según el tipo
    setEffectProperties();
    
    // Guardar los gestores proporcionados
    this.accessManager = accessManager;
    this.assetManager = assetManager;
  }
  
  void setEffectProperties() {
    switch(type) {
      case SHIELD:
        effectColor = color(100, 200, 255, 180);
        break;
      case SPEED_BOOST:
        effectColor = color(255, 100, 100, 180);
        break;
      case DOUBLE_POINTS:
        effectColor = color(255, 200, 50, 180);
        break;
      default:
        effectColor = color(200, 200, 200, 180);
    }
  }
  
  void update() {
    if (isActive) {
      timeRemaining--;
      if (timeRemaining <= 0) {
        isActive = false;
      }
    }
  }
  
  void display() {
    if (!isActive || !showInHUD) return;
    
    pushStyle();
    pushMatrix();
    
    // Tamaños aumentados para mejor visibilidad
    float iconSize = accessManager.getAdjustedTextSize(80);    // Iconos aún más grandes
    float borderRadius = 15;                                   // Bordes más redondeados
    float barHeight = 10;                                      // Barra de tiempo más alta
    float padding = 8;                                         // Espacio alrededor de los elementos
    
    // Destacar en modo de alto contraste
    boolean isHighContrast = accessManager.highContrastMode;
    
    // Ajustes de colores para modo daltónico o alto contraste
    color bgColor = effectColor;
    color textColor = color(0);
    
    if (accessManager.colorBlindMode) {
      // Usar colores específicos para daltónicos basados en tipo
      switch(type) {
        case SHIELD:
          bgColor = color(27, 158, 119, 220);  // Más opaco
          break;
        case SPEED_BOOST:
          bgColor = color(217, 95, 2, 220);    // Más opaco
          break;
        case DOUBLE_POINTS:
          bgColor = color(117, 112, 179, 220); // Más opaco
          break;
      }
    } else if (isHighContrast) {
      bgColor = color(0);
      textColor = color(255, 255, 0);
    } else {
      // Mejorar opacidad para mejor visibilidad
      bgColor = color(red(bgColor), green(bgColor), blue(bgColor), 220);
    }
    
    // Añadir un borde sutil para destacar el icono
    strokeWeight(3);  // Borde más grueso
    stroke(255, 255, 255, 100);
    
    // Desplegar fondo
    fill(bgColor);
    if (isHighContrast) {
      strokeWeight(4);  // Borde más grueso para alto contraste
      stroke(255, 255, 0);
    }
    
    // Calcular posición
    rectMode(CENTER);
    rect(position.x, position.y, iconSize, iconSize, borderRadius);
    
    // Si tenemos acceso al AssetManager y no estamos en modo de alto contraste, usar imágenes
    if (assetManager != null && !isHighContrast && !accessManager.colorBlindMode) {
      // Intentar obtener la imagen correspondiente
      PImage powerUpImage = null;
      
      switch(type) {
        case SHIELD:
          powerUpImage = assetManager.getShieldImage();
          break;
        case SPEED_BOOST:
          powerUpImage = assetManager.getSpeedBoostImage();
          break;
        case DOUBLE_POINTS:
          powerUpImage = assetManager.getDoublePointsImage();
          break;
      }
      
      // Si tenemos una imagen válida, mostrarla
      if (powerUpImage != null) {
        imageMode(CENTER);
        tint(255, 250); // Casi sin transparencia para mayor nitidez
        image(powerUpImage, position.x, position.y, iconSize * 0.8, iconSize * 0.8);
        noTint();
      } else {
        // Sin imagen, usar el texto de respaldo
        displayFallbackIcon(textColor, iconSize);
      }
    } else {
      // Sin asset manager o en modo accesible, usar el texto de respaldo
      displayFallbackIcon(textColor, iconSize);
    }
    
    // Indicador de tiempo restante - ahora más grande y más visible
    float barWidth = iconSize * 1.1;  // Barra más ancha que el ícono
    float barY = position.y + (iconSize / 2) + padding;
    
    // Fondo de la barra
    noStroke();
    fill(50, 50, 50, 200);  // Fondo más oscuro para la barra
    rectMode(CORNER);
    rect(position.x - barWidth/2, barY, barWidth, barHeight, barHeight/2);
    
    // Relleno de la barra - con gradiente según el tiempo restante
    float remainingPercent = (float)timeRemaining / duration;
    color barColor;
    
    if (isHighContrast) {
      barColor = color(255, 255, 0);
    } else {
      // Color que cambia de verde a rojo según el tiempo restante
      if (remainingPercent > 0.6) {
        barColor = color(50, 255, 100);  // Verde
      } else if (remainingPercent > 0.3) {
        barColor = color(255, 230, 50);  // Amarillo
      } else {
        barColor = color(255, 80, 80);   // Rojo
      }
    }
    
    fill(barColor);
    float remainingBarWidth = map(timeRemaining, 0, duration, 0, barWidth);
    rect(position.x - barWidth/2, barY, remainingBarWidth, barHeight, barHeight/2);
    
    // Mostrar siempre los segundos restantes, más grande y visible
    textAlign(CENTER, CENTER);
    textSize(accessManager.getAdjustedTextSize(18));  // Texto más grande
    fill(255);
    // Mostrar segundos restantes
    int secondsLeft = ceil(timeRemaining / 60.0);
    
    // Añadir fondo para mejor visibilidad del texto
    fill(0, 0, 0, 150);
    noStroke();
    rect(position.x - 20, barY + barHeight + 5, 40, 22, 5);
    
    // Dibujar el texto de tiempo restante
    fill(255);
    if (secondsLeft < 5) {
      // Resaltar cuando quede poco tiempo
      fill(255, 100, 100);
    }
    text(secondsLeft + "s", position.x, barY + barHeight + 15);
    
    popMatrix();
    popStyle();
  }
  
  // Método para mostrar ícono de respaldo (texto)
  void displayFallbackIcon(color textColor, float iconSize) {
    fill(textColor);
    textAlign(CENTER, CENTER);
    textSize(accessManager.getAdjustedTextSize(36)); // Texto aún más grande
    
    String iconText = "";
    switch(type) {
      case SHIELD:
        iconText = "🛡️";
        break;
      case SPEED_BOOST:
        iconText = "⚡";
        break;
      case DOUBLE_POINTS:
        iconText = "2×"; // Usando el símbolo de multiplicación correcto
        break;
    }
    
    text(iconText, position.x, position.y);
  }
  
  void setPosition(float x, float y) {
    position.x = x;
    position.y = y;
    showInHUD = true;
  }
  
  boolean isExpired() {
    return !isActive;
  }
  
  float getTimeRemainingSeconds() {
    // Assuming 60 FPS
    return timeRemaining / 60.0;
  }
  
  String getTypeName() {
    switch(type) {
      case SHIELD:
        return "Escudo";
      case SPEED_BOOST:
        return "Velocidad";
      case DOUBLE_POINTS:
        return "Puntos Dobles";
      default:
        return "Desconocido";
    }
  }
  
  void deactivate() {
    isActive = false;
    timeRemaining = 0;
  }
} 
