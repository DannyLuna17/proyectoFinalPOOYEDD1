/**
 * AssetManager.pde
 * 
 * Clase que centraliza la carga y gestión de todas las imágenes 
 * del juego para optimizar memoria y rendimiento.
 */
 
// Importamos biblioteca para GIFs animados
import gifAnimation.*;
import java.io.File;

class AssetManager {
  // Imágenes del juego
  private PImage backgroundImage;
  private PImage scaledBackground;
  private PImage menuBackground;
  private PImage finalBackground;
  private PImage instructionsImage; // Imagen para la pantalla de instrucciones
  private PImage floorImage;        // Imagen para el suelo
  
  // Imágenes de coleccionables
  private PImage heartImage;       // corazon.png
  private PImage shieldImage;      // escudo.png
  private PImage trashImage;       // basura.png 
  private PImage doublePointsImage;// doblepunto.png
  private Gif speedBoostGif;       // velocidad.gif (animado)
  private PImage speedBoostFallbackImage; // Imagen de respaldo para cuando el GIF falla
  private PImage coinImage;        // imagen de moneda
  private PImage characterImage;   // personaje
  private PImage shadowImage;      // sombra
  
  // Imágenes de obstáculos
  private PImage factoryObstacleImage; // fabricaContaminante.png
  private PImage trashObstacleImage;   // basura.png para obstáculos
  
  // Dimensiones escaladas estándar para coleccionables
  private final int STD_SIZE = 40;
  
  // Referencia a la aplicación principal
  private PApplet app;
  
  // Constructor
  AssetManager(PApplet app) {
    this.app = app;
    loadAllAssets();
  }
  
  // Constructor sin parámetros para compatibilidad
  AssetManager() {
    // Se usará cuando no se necesiten GIFs animados
    this.app = null;
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
    
    // Cargar imagen del suelo
    floorImage = loadImage("assets/piso.png");
    
    // Cargar imágenes de coleccionables
    heartImage = loadImage("assets/corazon.png");
    shieldImage = loadImage("assets/escudo.png");
    trashImage = loadImage("assets/basura.png");
    doublePointsImage = loadImage("assets/doblepunto.png");
    
    // Cargar imagen de respaldo para velocidad - SIEMPRE cargar esta imagen primero
    speedBoostFallbackImage = loadImage("assets/dobleVelocidad2.png");
    
    // Cargar GIF animado para velocidad
    // Para tener acceso a Processing directamente
    PApplet p = applet;  // Usamos la variable global
    if (p != null) {
      try {
        // Construir ruta absoluta para asegurar que se encuentre el archivo
        String gifPath = p.sketchPath("assets/velocidad.gif");
        println("Intentando cargar velocidad.gif desde: " + gifPath);
        
        // Comprobar si el archivo existe
        File gifFile = new File(gifPath);
        if (gifFile.exists()) {
          speedBoostGif = new Gif(p, gifPath);
          speedBoostGif.loop(); // GIF en reproducción continua
          println("GIF de velocidad cargado exitosamente");
        } else {
          println("ERROR: No se encontró el archivo GIF en: " + gifPath);
          speedBoostGif = null;
        }
      } catch (Exception e) {
        // Si falla, cargar una imagen estática de respaldo
        println("Error cargando GIF: " + e.getMessage());
        e.printStackTrace();
        speedBoostGif = null;
      }
    } else {
      // Si no tenemos acceso a PApplet, no podemos cargar GIFs
      println("No se puede cargar GIF: falta referencia a PApplet");
      speedBoostGif = null;
    }
    
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
    
    // Redimensionar la imagen de respaldo para velocidad
    if (speedBoostFallbackImage != null) {
      speedBoostFallbackImage.resize(STD_SIZE, 0);
    }
    
    // No podemos usar resize en Gif, pero podemos mostrar a escala
    
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
    
    // No redimensionamos el piso para mantener su calidad original
    // y asegurar que se vea bien cuando se escale dinámicamente
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
  
  PImage getFloorImage() {
    return floorImage;
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
  
  // Método para obtener el GIF de velocidad o la imagen de respaldo
  PImage getSpeedBoostImage() {
    if (speedBoostGif != null && speedBoostGif.width > 0) {
      // Verificamos que el GIF esté correctamente cargado
      return speedBoostGif;
    } else {
      // Devolver la imagen de respaldo precargada si el GIF no está disponible
      return speedBoostFallbackImage;
    }
  }
  
  // Getter para acceder al objeto Gif directamente
  Gif getSpeedBoostGif() {
    return speedBoostGif;
  }
  
  // Método para verificar si el GIF está activo
  boolean isSpeedBoostGifActive() {
    return speedBoostGif != null && speedBoostGif.width > 0;
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
        return getSpeedBoostImage();
      default:
        return null; // Para otros tipos que no tienen imagen
    }
  }
} 