/**
 * LoadingScreen.pde
 * 
 * Pantalla de carga inicial que se muestra al arrancar el juego.
 * Presenta el logo de EcoRunner rotando mientras se cargan los assets.
 */

class LoadingScreen {
  // Logo y estado de carga
  PImage logo;
  boolean isLoaded = false;
  
  // Animación del logo
  float rotationAngle = 0;
  float rotationSpeed = 2.0; 
  
  // Timer para asegurar que la pantalla de carga sea visible por un tiempo mínimo
  int loadingTimer = 0;
  int minimumLoadingTime = 120;
  
  // Estado de assets
  boolean assetsLoaded = false;
  
  // Referencias
  AccessibilityManager accessManager;
  
  LoadingScreen(AccessibilityManager accessManager) {
    this.accessManager = accessManager;
    loadLogo();
  }
  
  // Cargar el logo desde assets
  void loadLogo() {
    try {
      logo = loadImage("assets/EcoRunner.png");
      if (logo != null) {
        println("Logo cargado exitosamente para la pantalla de carga");
      } else {
        println("Error: No se pudo cargar el logo EcoRunner.png");
      }
    } catch (Exception e) {
      println("Error al cargar el logo: " + e.getMessage());
      logo = null;
    }
  }
  
  // Actualizar estado de la pantalla de carga
  void update() {
    // Actualizar ángulo de rotación del logo
    rotationAngle += rotationSpeed;
    if (rotationAngle >= 360) {
      rotationAngle = 0; // resetear para evitar números muy grandes
    }
    
    // Incrementar timer de carga
    loadingTimer++;
    
    // Verificar si ya podemos marcar como completada la carga
    if (loadingTimer >= minimumLoadingTime && assetsLoaded) {
      isLoaded = true;
    }
  }
  
  // Renderizar la pantalla de carga
  void display() {
    // Fondo negro elegante
    background(0);
    
    // Solo mostrar si tenemos el logo cargado
    if (logo != null) {
      // Guardar estado de transformación
      pushMatrix();
      pushStyle();
      
      // Mover al centro de la pantalla
      translate(width/2, height/2);
      
      // Aplicar rotación
      rotate(radians(rotationAngle));
      
      // Configurar el modo de imagen para que se centre en el punto de rotación
      imageMode(CENTER);
      
      // Calcular tamaño apropiado del logo
      float logoScale = min(width, height) * 0.3 / max(logo.width, logo.height);
      float logoWidth = logo.width * logoScale;
      float logoHeight = logo.height * logoScale;
      
      // Dibujar el logo con un poco de transparencia para que se vea suave
      tint(255, 255); // sin transparencia - logo completamente visible
      image(logo, 0, 0, logoWidth, logoHeight);
      
      // Restaurar estados
      popStyle();
      popMatrix();
      
      // Texto de carga debajo del logo (sin rotar)
      drawLoadingText();
    } else {
      // Si no hay logo, mostrar solo texto
      drawLoadingTextFallback();
    }
  }
  
  // Dibujar texto de carga debajo del logo
  void drawLoadingText() {
    // Texto de "Cargando..." con puntos animados
    String loadingText = "Cargando";
    int dots = (loadingTimer / 30) % 4; // cambiar cada medio segundo aproximadamente
    for (int i = 0; i < dots; i++) {
      loadingText += ".";
    }
    
    // Configurar texto
    fill(accessManager.getTextColor(color(255, 255, 255)));
    textAlign(CENTER, CENTER);
    textSize(accessManager.getAdjustedTextSize(24));
    
    // Posicionar texto debajo del logo
    text(loadingText, width/2, height/2 + height * 0.2);
    
    // Texto adicional más pequeño
    fill(accessManager.getTextColor(color(180, 180, 180)));
    textSize(accessManager.getAdjustedTextSize(14));
    text("Preparando EcoRunner...", width/2, height/2 + height * 0.25);
  }
  
  // Texto de respaldo si no se puede cargar el logo
  void drawLoadingTextFallback() {
    fill(accessManager.getTextColor(color(255, 255, 255)));
    textAlign(CENTER, CENTER);
    textSize(accessManager.getAdjustedTextSize(48));
    text("EcoRunner", width/2, height/2 - 30);
    
    // Texto de carga
    textSize(accessManager.getAdjustedTextSize(24));
    String loadingText = "Cargando";
    int dots = (loadingTimer / 30) % 4;
    for (int i = 0; i < dots; i++) {
      loadingText += ".";
    }
    text(loadingText, width/2, height/2 + 30);
  }
  
  // Marcar assets como cargados
  void setAssetsLoaded(boolean loaded) {
    this.assetsLoaded = loaded;
  }
  
  // Verificar si la carga está completa
  boolean isLoadingComplete() {
    return isLoaded;
  }
  
  // Resetear para futuros usos
  void reset() {
    isLoaded = false;
    loadingTimer = 0;
    rotationAngle = 0;
    assetsLoaded = false;
  }
} 