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
  
  // Efectos visuales
  private PImage avalancheImage;    
  
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
  
  // Animaciones del jugador
  private Gif jumpAnimationGif;    // salto1.gif (animación de salto)
  private PImage jumpFallbackImage; // Imagen de respaldo para el salto
  
  // Imágenes de obstáculos
  private PImage factoryObstacleImage; // fabricaContaminante.png
  private PImage trashObstacleImage;   // basura.png para obstáculos
  private PImage toxicCloudImage;      // nube.png para obstáculo de nube tóxica
  
  // Efectos de clima
  private PImage rainImage;        // lluvia.gif para efecto de lluvia
  
  // Dimensiones escaladas estándar para coleccionables
  private final int STD_SIZE = 60;
  
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
    
    // Cargar efectos visuales
    avalancheImage = loadImage("assets/avalancha.png");
    
    // Cargar imágenes de coleccionables
    heartImage = loadImage("assets/corazon.png");
    shieldImage = loadImage("assets/escudo.png");
    trashImage = loadImage("assets/basura.png");
    doublePointsImage = loadImage("assets/doblepunto.png");
    
    // Cargar imagen de respaldo para velocidad - SIEMPRE cargar esta imagen primero
    speedBoostFallbackImage = loadImage("assets/dobleVelocidad2.png");
    
    // Crear imagen de respaldo para monedas
    coinFallbackImage = createCoinFallbackImage();
    
    // Cargar imagen de lluvia
    rainImage = loadImage("assets/lluvia.gif");
    
    // Cargar otras imágenes
    characterImage = loadImage("assets/personaje.png");
    shadowImage = loadImage("assets/sombra.png");
    
    // Crear imagen de respaldo para el salto
    jumpFallbackImage = createJumpFallbackImage();
    
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
        
        // Cargar GIF animado para el salto del jugador
        String jumpGifPath = p.sketchPath("assets/salto1.gif");
        println("Intentando cargar salto1.gif desde: " + jumpGifPath);
        
        // Comprobar si el archivo existe
        File jumpGifFile = new File(jumpGifPath);
        if (jumpGifFile.exists()) {
          jumpAnimationGif = new Gif(p, jumpGifPath);
          jumpAnimationGif.loop(); 
          println("GIF de salto cargado exitosamente");
        } else {
          println("ERROR: No se encontró el archivo GIF en: " + jumpGifPath);
          jumpAnimationGif = null;
        }
        
      } catch (Exception e) {
        // Si falla, cargar una imagen estática de respaldo
        println("Error cargando GIFs: " + e.getMessage());
        e.printStackTrace();
        speedBoostGif = null;
        coinGif = null;
        jumpAnimationGif = null;
      }
    } else {
      // Si no tenemos acceso a PApplet, no podemos cargar GIFs
      println("No se puede cargar GIF: falta referencia a PApplet");
      speedBoostGif = null;
      coinGif = null;
      jumpAnimationGif = null;
    }
    
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
  
  // Crear una imagen de salto como respaldo
  PImage createJumpFallbackImage() {
    // Crear una imagen simple del personaje saltando (personaje con líneas de movimiento)
    PGraphics pg = createGraphics(int(STD_SIZE * 1.5), int(STD_SIZE * 1.5));
    pg.beginDraw();
    pg.clear(); // Fondo completamente transparente - esto es mejor que background(0,0,0,0)
    
    // Dibujar el cuerpo del personaje (círculo principal)
    pg.fill(255, 100, 100); // Color rojizo como el personaje original
    pg.noStroke();
    pg.ellipse(pg.width/2, pg.height/2, STD_SIZE, STD_SIZE);
    
    // Dibujar líneas de movimiento para indicar salto (más suaves y transparentes)
    pg.stroke(255, 255, 255, 100); // Líneas más transparentes para evitar artefactos
    pg.strokeWeight(2); // Líneas más finas
    pg.noFill(); // Asegurar que no hay relleno en las líneas
    
    for (int i = 0; i < 3; i++) {
      int lineY = pg.height/2 + 20 + (i * 6);
      // Líneas curvas en lugar de rectas para un efecto más suave
      pg.arc(pg.width/2, lineY, 25 + (i * 5), 8, 0, PI);
    }
    
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
  
  // Getter para la imagen de lluvia
  PImage getRainImage() {
    return rainImage;
  }
  
  // Métodos para la animación de salto
  PImage getJumpAnimationImage() {
    if (jumpAnimationGif != null && jumpAnimationGif.width > 0) {
      // Para GIFs, devolver directamente - el filtro se aplica en Player.pde
      return jumpAnimationGif;
    } else {
      // Devolver la imagen de respaldo precargada
      return jumpFallbackImage;
    }
  }
  
  // Método alternativo que devuelve una imagen limpia del GIF sin fondos negros
  // Esto soluciona el problema del rectángulo negro que parpadea en los pies del personaje
  PImage getCleanJumpAnimationImage() {
    if (jumpAnimationGif != null && jumpAnimationGif.width > 0) {
      // Crear una versión limpia del frame actual del GIF
      PImage cleanFrame = jumpAnimationGif.copy();
      cleanFrame.loadPixels();
      
      // Procesar píxeles para eliminar fondos negros que causan artefactos visuales
      for (int i = 0; i < cleanFrame.pixels.length; i++) {
        color pixel = cleanFrame.pixels[i];
        float brightness = brightness(pixel);
        
        // Hacer transparentes los píxeles negros o muy oscuros (el rectángulo negro problemático)
        if (brightness < 25) { // Umbral para detectar píxeles problemáticos del GIF
          cleanFrame.pixels[i] = color(0, 0); // Completamente transparente - elimina el artefacto
        }
      }
      cleanFrame.updatePixels();
      return cleanFrame;
    } else {
      // Devolver la imagen de respaldo que no tiene problemas de fondo negro
      return jumpFallbackImage;
    }
  }
  
  // Getter para acceder al objeto Gif de salto directamente
  Gif getJumpAnimationGif() {
    return jumpAnimationGif;
  }
  
  // Método para verificar si el GIF de salto está activo
  boolean isJumpAnimationGifActive() {
    return jumpAnimationGif != null && jumpAnimationGif.width > 0;
  }
  
  // Getter para la imagen de avalancha
  PImage getAvalancheImage() {
    return avalancheImage;
  }
} 