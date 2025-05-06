/**
 * AssetManager.pde
 * 
 * Clase que centraliza la carga y gestión de todas las imágenes 
 * del juego para optimizar memoria y rendimiento.
 */
 
class AssetManager {
  // Imágenes del juego
  private PImage backgroundImage;
  private PImage scaledBackground;
  private PImage menuBackground;
  private PImage finalBackground;
  private PImage instructionsImage; // Imagen para la pantalla de instrucciones
  
  // Imágenes de coleccionables
  private PImage heartImage;       // corazon.png
  private PImage shieldImage;      // escudo.png
  private PImage trashImage;       // basura.png 
  private PImage doublePointsImage;// doblepunto.png
  private PImage speedBoostImage;  // dobleVelocidad2.png
  private PImage coinImage;        // imagen de moneda
  private PImage characterImage;   // personaje
  private PImage shadowImage;      // sombra
  
  // Imágenes de obstáculos
  private PImage factoryObstacleImage; // fabricaContaminante.png
  private PImage trashObstacleImage;   // basura.png para obstáculos
  
  // Dimensiones escaladas estándar para coleccionables
  private final int STD_SIZE = 40;
  
  // Constructor
  AssetManager() {
    loadAllAssets();
  }
  
  // Cargar todas las imágenes
  void loadAllAssets() {
    // Cargar fondos
    backgroundImage = loadImage("assets/fondo1.png");
    menuBackground = loadImage("assets/menuFinal.png");
    finalBackground = loadImage("assets/menuFinal.png");
    
    // Cargar imagen de instrucciones
    instructionsImage = loadImage("assets/instrucciones.png");
    
    // Cargar imágenes de coleccionables
    heartImage = loadImage("assets/corazon.png");
    shieldImage = loadImage("assets/escudo.png");
    trashImage = loadImage("assets/basura.png");
    doublePointsImage = loadImage("assets/doblepunto.png");
    speedBoostImage = loadImage("assets/dobleVelocidad2.png");
    
    // Cargar otras imágenes
    characterImage = loadImage("assets/personaje.png");
    shadowImage = loadImage("assets/sombra.png");
    
    // Cargar imágenes de obstáculos
    factoryObstacleImage = loadImage("assets/fabricaContaminante.png");
    trashObstacleImage = loadImage("assets/basura.png");  // Cargar basura.png como obstáculo
    
    // Pre-redimensionar para mejor rendimiento
    resizeAssets();
  }
  
  // Escalar los assets para rendimiento
  void resizeAssets() {
    // Redimensionar coleccionables para un tamaño estándar
    heartImage.resize(STD_SIZE, 0);
    shieldImage.resize(STD_SIZE, 0);
    trashImage.resize(STD_SIZE, 0);
    doublePointsImage.resize(STD_SIZE, 0);
    speedBoostImage.resize(STD_SIZE, 0);
    
    // Redimensionar imágenes de personaje
    if (characterImage != null) {
      // Personaje con un tamaño mayor ahora (60px)
      characterImage.resize(0, int(STD_SIZE * 1.5));
    }
    
    // Ajuste de sombra para que coincida con el tamaño del personaje
    if (shadowImage != null) {
      shadowImage.resize(0, int(STD_SIZE * 0.6));
    }
    
    // Redimensionar obstáculos
    if (factoryObstacleImage != null) {
      factoryObstacleImage.resize(0, int(STD_SIZE * 2));
    }
    if (trashObstacleImage != null) {
      trashObstacleImage.resize(0, int(STD_SIZE * 1.5));
    }
  }
  
  // Escalar fondo a tamaño específico
  void scaleBackground(int w, int h) {
    if (backgroundImage != null) {
      scaledBackground = backgroundImage.copy();
      scaledBackground.resize(w, h);
    }
  }
  
  // GETTERS para acceder a las imágenes
  
  PImage getBackgroundImage() {
    return backgroundImage;
  }
  
  PImage getScaledBackground() {
    return scaledBackground;
  }
  
  PImage getMenuBackground() {
    return menuBackground;
  }
  
  PImage getFinalBackground() {
    return finalBackground;
  }
  
  PImage getInstructionsImage() {
    return instructionsImage;
  }
  
  PImage getHeartImage() {
    return heartImage;
  }
  
  PImage getShieldImage() {
    return shieldImage;
  }
  
  PImage getTrashImage() {
    return trashImage;
  }
  
  PImage getDoublePointsImage() {
    return doublePointsImage;
  }
  
  PImage getSpeedBoostImage() {
    return speedBoostImage;
  }
  
  PImage getCharacterImage() {
    return characterImage;
  }
  
  PImage getShadowImage() {
    return shadowImage;
  }
  
  PImage getFactoryObstacleImage() {
    return factoryObstacleImage;
  }
  
  PImage getTrashObstacleImage() {
    return trashObstacleImage;
  }
  
  // Obtener la imagen de obstáculo según el tipo
  PImage getObstacleImage(int obstacleType) {
    switch (obstacleType) {
      case 0: // Estándar
        return factoryObstacleImage;
      case 1: // Bajo (saltar) - usar basura.png
        return trashObstacleImage;
      case 2: // Alto
        return factoryObstacleImage;
      case 3: // Móvil
        return factoryObstacleImage;
      default:
        return factoryObstacleImage;
    }
  }
  
  // Obtener la imagen correspondiente según el tipo de coleccionable
  PImage getCollectibleImage(int collectibleType) {
    switch (collectibleType) {
      case Collectible.HEART:
        return heartImage;
      case Collectible.SHIELD:
        return shieldImage;
      case Collectible.ECO_NEGATIVE:
        return trashImage;
      case Collectible.DOUBLE_POINTS:
        return doublePointsImage;
      case Collectible.SPEED_BOOST:
        return speedBoostImage;
      default:
        return null; // Para otros tipos que no tienen imagen
    }
  }
} 