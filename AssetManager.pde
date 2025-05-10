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
  private Gif coinGif;             // moneda.gif (animado)
  private PImage coinFallbackImage; // Imagen de respaldo para monedas
  private PImage characterImage;   // personaje
  private PImage shadowImage;      // sombra
  
  // Imágenes de obstáculos
  private PImage factoryObstacleImage; // fabricaContaminante.png
  private PImage trashObstacleImage;   // basura.png para obstáculos
  private PImage toxicCloudImage;      // nube.png para obstáculo de nube tóxica
  
  // Dimensiones escaladas estándar para coleccionables
  // Aumentamos el tamaño estándar de los elementos para que todo se vea más grande
  private final int STD_SIZE = 60; // Antes era 40, ahora es 50% más grande
  
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
    
    // Cargar imagen del suelo y optimizarla para mosaico perfecto
    floorImage = loadImage("assets/piso.png");
    optimizeFloorImageForTiling();
    
    // Cargar imágenes de coleccionables
    heartImage = loadImage("assets/corazon.png");
    shieldImage = loadImage("assets/escudo.png");
    trashImage = loadImage("assets/basura.png");
    doublePointsImage = loadImage("assets/doblepunto.png");
    
    // Cargar imagen de respaldo para velocidad - SIEMPRE cargar esta imagen primero
    speedBoostFallbackImage = loadImage("assets/dobleVelocidad2.png");
    
    // Crear imagen de respaldo para monedas
    coinFallbackImage = createCoinFallbackImage();
    
    // Para tener acceso a Processing directamente
    PApplet p = applet;  // Usamos la variable global
    if (p != null) {
      try {
        // Cargar GIF animado para velocidad
        String speedGifPath = p.sketchPath("assets/velocidad.gif");
        println("Intentando cargar velocidad.gif desde: " + speedGifPath);
        
        // Comprobar si el archivo existe
        File speedGifFile = new File(speedGifPath);
        if (speedGifFile.exists()) {
          speedBoostGif = new Gif(p, speedGifPath);
          speedBoostGif.loop(); // GIF en reproducción continua
          println("GIF de velocidad cargado exitosamente");
        } else {
          println("ERROR: No se encontró el archivo GIF en: " + speedGifPath);
          speedBoostGif = null;
        }
        
        // Cargar GIF animado para monedas
        String coinGifPath = p.sketchPath("assets/moneda.gif");
        println("Intentando cargar moneda.gif desde: " + coinGifPath);
        
        // Comprobar si el archivo existe
        File coinGifFile = new File(coinGifPath);
        if (coinGifFile.exists()) {
          coinGif = new Gif(p, coinGifPath);
          coinGif.loop(); // GIF en reproducción continua
          println("GIF de moneda cargado exitosamente");
        } else {
          println("ERROR: No se encontró el archivo GIF en: " + coinGifPath);
          coinGif = null;
        }
        
      } catch (Exception e) {
        // Si falla, cargar una imagen estática de respaldo
        println("Error cargando GIFs: " + e.getMessage());
        e.printStackTrace();
        speedBoostGif = null;
        coinGif = null;
      }
    } else {
      // Si no tenemos acceso a PApplet, no podemos cargar GIFs
      println("No se puede cargar GIF: falta referencia a PApplet");
      speedBoostGif = null;
      coinGif = null;
    }
    
    // Cargar otras imágenes
    characterImage = loadImage("assets/personaje.png");
    shadowImage = loadImage("assets/sombra.png");
    
    // Cargar imágenes de obstáculos
    factoryObstacleImage = loadImage("assets/fabricaContaminante.png");
    trashObstacleImage = loadImage("assets/basura.png");  // Cargar basura.png como obstáculo
    toxicCloudImage = loadImage("assets/nube.png");       // Cargar nube.png para la nube tóxica
    
    // Pre-redimensionar para mejor rendimiento
    resizeAssets();
  }
  
  // Crear una imagen de moneda como respaldo
  PImage createCoinFallbackImage() {
    // Crear una imagen de moneda dorada simple
    PGraphics pg = createGraphics(STD_SIZE, STD_SIZE);
    pg.beginDraw();
    pg.background(0, 0, 0, 0); // Fondo transparente
    pg.fill(255, 215, 0); // Color dorado
    pg.noStroke();
    pg.ellipse(STD_SIZE/2, STD_SIZE/2, STD_SIZE-4, STD_SIZE-4);
    pg.fill(255, 235, 50); // Centro más claro
    pg.ellipse(STD_SIZE/2, STD_SIZE/2, (STD_SIZE-4) * 0.7, (STD_SIZE-4) * 0.7);
    pg.endDraw();
    return pg;
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
      // Personaje con un tamaño mayor ahora (90px)
      characterImage.resize(0, int(STD_SIZE * 1.5));
    }
    
    // Ajuste de sombra para que coincida con el tamaño del personaje
    if (shadowImage != null) {
      shadowImage.resize(0, int(STD_SIZE * 0.6));
    }
    
    // Redimensionar obstáculos
    if (factoryObstacleImage != null) {
      factoryObstacleImage.resize(0, int(STD_SIZE * 2.2));
    }
    if (trashObstacleImage != null) {
      trashObstacleImage.resize(0, int(STD_SIZE * 1.7));
    }
    if (toxicCloudImage != null) {
      toxicCloudImage.resize(0, int(STD_SIZE * 2.0));
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
  
  // Optimizar la imagen del suelo para que funcione perfectamente en mosaico
  void optimizeFloorImageForTiling() {
    if (floorImage == null) return;
    
    // Asegurarse de que los bordes sean compatibles para mosaico
    // Copiamos un pixel del borde izquierdo al derecho y viceversa
    // para garantizar una transición suave
    
    PGraphics optimizedFloor = createGraphics(floorImage.width, floorImage.height);
    optimizedFloor.beginDraw();
    
    // Dibujar la imagen original
    optimizedFloor.image(floorImage, 0, 0);
    
    // Copiar los bordes para un tiling perfecto
    optimizedFloor.loadPixels();
    
    // Copiar los pixeles del borde izquierdo al derecho
    for (int y = 0; y < floorImage.height; y++) {
      // Color del primer pixel de cada fila (borde izquierdo)
      color leftPixel = floorImage.get(0, y);
      
      // Color del último pixel de cada fila (borde derecho)
      color rightPixel = floorImage.get(floorImage.width - 1, y);
      
      // Copiar el color del borde izquierdo al derecho y viceversa
      // para una transición perfecta cuando se repiten las imágenes
      optimizedFloor.set(floorImage.width - 1, y, leftPixel);
      optimizedFloor.set(0, y, rightPixel);
    }
    
    optimizedFloor.updatePixels();
    optimizedFloor.endDraw();
    
    // Reemplazar la imagen original con la optimizada
    floorImage = optimizedFloor;
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
  
  // Método para obtener el GIF de moneda o la imagen de respaldo
  PImage getCoinImage() {
    if (coinGif != null && coinGif.width > 0) {
      // Verificamos que el GIF esté correctamente cargado
      return coinGif;
    } else {
      // Devolver la imagen de respaldo precargada
      return coinFallbackImage;
    }
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
  
  // Getter para acceder al objeto Gif de moneda directamente
  Gif getCoinGif() {
    return coinGif;
  }
  
  // Método para verificar si el GIF está activo
  boolean isSpeedBoostGifActive() {
    return speedBoostGif != null && speedBoostGif.width > 0;
  }
  
  // Método para verificar si el GIF de moneda está activo
  boolean isCoinGifActive() {
    return coinGif != null && coinGif.width > 0;
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
  
  PImage getToxicCloudImage() {
    return toxicCloudImage;
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
      case 4: // Nube tóxica
        return toxicCloudImage;
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
      case Collectible.COIN:
        return getCoinImage();
      default:
        return null; // Para otros tipos que no tienen imagen
    }
  }
} 