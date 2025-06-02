/**
 * AvalancheEffect.pde
 * 
 * Efecto visual de avalancha que aparece detrás del jugador 
 */

class AvalancheEffect {
  // Imagen de la avalancha
  private PImage avalancheImage;
  
  // Posición y movimiento
  private float baseX;              // posición base horizontal (detrás del jugador)
  private float currentX;           // posición actual con movimiento
  private float y;                  // posición vertical (a nivel del suelo)
  private float oscillationSpeed;   // velocidad de oscilación
  private float oscillationRange;   // rango de movimiento horizontal
  private float scale;              // escala de la imagen
  
  // Transparencia y visibilidad
  private float alpha;              // transparencia de la avalancha
  private boolean isVisible;        // si el efecto está activo
  
  // Referencias para el posicionamiento
  private float groundLevel;        // nivel del suelo donde aparece la avalancha
  private AccessibilityManager accessManager;
  
  // Constructor
  AvalancheEffect(AssetManager assetManager, float groundLevel, AccessibilityManager accessManager) {
    this.avalancheImage = assetManager.getAvalancheImage();
    this.groundLevel = groundLevel;
    this.accessManager = accessManager;
    
    // Configuración del movimiento
    this.oscillationSpeed = 0.08;    
    this.oscillationRange = 12;      
    this.scale = 0.47;                
    this.alpha = 180;                
    
    // Posicionamiento inicial - atrás del jugador
    this.baseX = -width * 0.120;      
    this.currentX = baseX - 500;
    
    // Calcular posición vertical para que aparezca a nivel del suelo
    if (avalancheImage != null) {
      float imageHeight = avalancheImage.height * scale;
      this.y = groundLevel - imageHeight + 35.5; 
    } else {
      this.y = groundLevel;
    }
    
    this.isVisible = true;
  }
  
  // Actualizar el movimiento de oscilación
  void update() {
    if (!isVisible || avalancheImage == null) return;
    
    // Calcular movimiento de oscilación usando seno para movimiento suave
    float oscillation = sin(frameCount * oscillationSpeed) * oscillationRange;
    currentX = baseX + oscillation;
  }
  
  // Dibujar la avalancha
  void display() {
    if (!isVisible || avalancheImage == null) return;
    
    pushStyle();
    
    // Configurar transparencia
    // tint(255, alpha);
    
    // Configurar modo de imagen
    imageMode(CORNER);
    
    // Calcular dimensiones escaladas
    float scaledWidth = avalancheImage.width * scale;
    float scaledHeight = avalancheImage.height * scale;
    
    // Dibujar la avalancha en la posición calculada
    image(avalancheImage, currentX, y, scaledWidth, scaledHeight);
    
    // Resetear tinte
    noTint();
    
    popStyle();
  }
  
  // Métodos para controlar el efecto
  void show() {
    isVisible = true;
  }
  
  void hide() {
    isVisible = false;
  }
  
  void setAlpha(float alpha) {
    this.alpha = constrain(alpha, 0, 255);
  }
  
  void setScale(float scale) {
    this.scale = constrain(scale, 0.1, 2.0);
    // Recalcular posición Y cuando cambia la escala
    if (avalancheImage != null) {
      float imageHeight = avalancheImage.height * this.scale;
      this.y = groundLevel - imageHeight;
    }
  }
  
  void setOscillationSpeed(float speed) {
    this.oscillationSpeed = constrain(speed, 0.005, 0.1);
  }
  
  void setOscillationRange(float range) {
    this.oscillationRange = constrain(range, 5, 50);
  }
  
  // Mover la avalancha a una nueva posición base
  void setBasePosition(float x) {
    this.baseX = x;
  }
  
  // Obtener información del efecto
  boolean isActive() {
    return isVisible;
  }
  
  float getCurrentX() {
    return currentX;
  }
  
  float getY() {
    return y;
  }
} 