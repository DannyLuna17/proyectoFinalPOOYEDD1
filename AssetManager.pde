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
  // Cache optimizado para frames pre-procesados
  private PImage[] processedJumpFrames; // Todos los frames ya procesados
  private int currentJumpFrame = 0;     // Frame actual a mostrar
  private int jumpFrameTimer = 0;       // Timer para cambiar frames
  private int jumpFrameDelay = 6;       // Frames entre cambios (ajustable)
  
  // Animación de corrida del jugador 
  private Gif runningAnimationGif;      // EcoEarthRunning.gif 
  private PImage runningFallbackImage;  // Imagen de respaldo 
  // Cache optimizado para frames de corrida pre-procesados
  private PImage[] processedRunningFrames; // Todos los frames de corrida ya procesados
  private int currentRunningFrame = 0;     // Frame actual de corrida a mostrar
  private int runningFrameTimer = 0;       // Timer para cambiar frames de corrida
  private int runningFrameDelay = 8;       // Frames entre cambios de corrida 
  
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
    
    // Crear imagen de respaldo para la corrida 
    runningFallbackImage = createRunningFallbackImage();
    
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
        String jumpGifPath = p.sketchPath("assets/jump.gif");
        println("Intentando cargar jump.gif desde: " + jumpGifPath);
        
        // Comprobar si el archivo existe
        File jumpGifFile = new File(jumpGifPath);
        if (jumpGifFile.exists()) {
          jumpAnimationGif = new Gif(p, jumpGifPath);
          jumpAnimationGif.loop(); 
          println("GIF de salto cargado exitosamente");
          
          // Pre-procesar todos los frames del GIF para optimización
          preProcessJumpFrames();
        } else {
          println("ERROR: No se encontró el archivo GIF en: " + jumpGifPath);
          jumpAnimationGif = null;
        }
        
        // Cargar GIF animado para la corrida del jugador 
        String runningGifPath = p.sketchPath("assets/running.gif");
        println("Intentando cargar running.gif desde: " + runningGifPath);
        
        // Comprobar si el archivo existe
        File runningGifFile = new File(runningGifPath);
        if (runningGifFile.exists()) {
          runningAnimationGif = new Gif(p, runningGifPath);
          runningAnimationGif.loop(); 
          println("GIF de corrida cargado exitosamente");
          
          // Pre-procesar todos los frames del GIF de correr para optimización
          preProcessRunningFrames();
        } else {
          println("ERROR: No se encontró el archivo GIF en: " + runningGifPath);
          runningAnimationGif = null;
        }
        
      } catch (Exception e) {
        // Si falla, cargar una imagen estática de respaldo
        println("Error cargando GIFs: " + e.getMessage());
        e.printStackTrace();
        speedBoostGif = null;
        coinGif = null;
        jumpAnimationGif = null;
        runningAnimationGif = null; // También resetear el GIF de corrida en caso de error
      }
    } else {
      // Si no tenemos acceso a PApplet, no podemos cargar GIFs
      println("No se puede cargar GIF: falta referencia a PApplet");
      speedBoostGif = null;
      coinGif = null;
      jumpAnimationGif = null;
      runningAnimationGif = null;
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
  
  // Crear una imagen de corrida como respaldo 
  PImage createRunningFallbackImage() {
    // Crear una imagen simple del personaje corriendo 
    PGraphics pg = createGraphics(int(STD_SIZE * 1.2), int(STD_SIZE * 1.2));
    pg.beginDraw();
    pg.clear(); // Fondo completamente transparente
    
    // Dibujar el cuerpo del personaje (círculo principal)
    pg.fill(100, 200, 100); // Color verdoso para diferenciarlo del salto
    pg.stroke(50, 150, 50); // Borde del personaje
    pg.strokeWeight(2);
    pg.ellipse(pg.width/2, pg.height/2, STD_SIZE * 0.9, STD_SIZE * 0.9);
    
    // Dibujar líneas de velocidad horizontal para indicar corrida
    pg.stroke(255, 255, 255, 150); // Líneas de velocidad más visibles
    pg.strokeWeight(3);
    pg.noFill();
    
    // Líneas horizontales que indican movimiento hacia adelante
    for (int i = 0; i < 3; i++) {
      int lineX = pg.width/2 - 30 - (i * 8);  // Líneas hacia atrás del personaje
      int lineY = pg.height/2 - 8 + (i * 8);  // Escalonadas verticalmente
      int lineLength = 20 - (i * 3); // Líneas más cortas conforme se alejan
      
      // Líneas con efecto de desvanecimiento
      float alpha = map(i, 0, 2, 150, 80);
      pg.stroke(255, 255, 255, alpha);
      pg.line(lineX, lineY, lineX + lineLength, lineY);
    }
    
    pg.fill(200, 200, 200, 100);
    pg.noStroke();
    for (int i = 0; i < 4; i++) {
      float dustX = pg.width/2 - 35 - (i * 6) + random(-2, 2);
      float dustY = pg.height/2 + 15 + random(-3, 3);
      float dustSize = 3 + random(2);
      pg.ellipse(dustX, dustY, dustSize, dustSize);
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
  
  // Método optimizado que usa frames pre-procesados (sin procesamiento en tiempo real)
  PImage getCleanJumpAnimationImage() {
    // Si tenemos frames pre-procesados, usarlos para máximo rendimiento
    if (processedJumpFrames != null && processedJumpFrames.length > 0) {
      // Actualizar timer y frame actual
      jumpFrameTimer++;
      if (jumpFrameTimer >= jumpFrameDelay) {
        jumpFrameTimer = 0;
        currentJumpFrame = (currentJumpFrame + 1) % processedJumpFrames.length;
      }
      
      // Devolver el frame pre-procesado actual (SIN procesamiento adicional)
      return processedJumpFrames[currentJumpFrame];
    }
    
    // Fallback: usar GIF original si no hay frames pre-procesados
    if (jumpAnimationGif != null && jumpAnimationGif.width > 0) {
      // Asegurarse de que el GIF esté reproduciéndose
      if (!jumpAnimationGif.isPlaying()) {
        jumpAnimationGif.play();
      }
      return jumpAnimationGif; // Sin procesamiento para mejor rendimiento
    }
    
    // Último fallback: imagen estática
    return jumpFallbackImage;
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
  
  // Pre-procesar todos los frames del GIF de salto para máximo rendimiento
  void preProcessJumpFrames() {
    if (jumpAnimationGif == null) {
      processedJumpFrames = null;
      return;
    }
    
    println("Pre-procesando frames del GIF de salto para optimización...");
    
    try {
      // Pausar el GIF temporalmente para obtener frames individuales
      jumpAnimationGif.pause();
      jumpAnimationGif.jump(0); // Ir al primer frame
      
      // Obtener número total de frames de manera compatible
      ArrayList<PImage> tempFrames = new ArrayList<PImage>();
      int frameIndex = 0;
      int maxFramesToCheck = 200; // Límite de seguridad para evitar bucles infinitos
      
      // Iterar a través de todos los frames disponibles
      while (frameIndex < maxFramesToCheck) {
        try {
          jumpAnimationGif.jump(frameIndex);
          PImage currentFrame = jumpAnimationGif.copy();
          
          // Si conseguimos una imagen válida, agregarla
          if (currentFrame != null && currentFrame.width > 0) {
            tempFrames.add(currentFrame);
            frameIndex++;
          } else {
            // No hay más frames válidos
            break;
          }
        } catch (Exception e) {
          // Si falla al acceder a un frame, hemos llegado al final
          break;
        }
      }
      
      int totalFrames = tempFrames.size();
      if (totalFrames == 0) {
        println("ERROR: No se pudieron obtener frames del GIF");
        processedJumpFrames = null;
        return;
      }
      
      processedJumpFrames = new PImage[totalFrames];
      println("Procesando " + totalFrames + " frames del GIF de salto...");
      
      // Procesar cada frame ya obtenido
      for (int i = 0; i < totalFrames; i++) {
        PImage originalFrame = tempFrames.get(i);
        originalFrame.loadPixels();
        
        // Crear frame procesado
        PImage cleanFrame = createImage(originalFrame.width, originalFrame.height, ARGB);
        cleanFrame.loadPixels();
        
        // Procesar píxeles para eliminar fondos negros
        for (int j = 0; j < originalFrame.pixels.length; j++) {
          color pixel = originalFrame.pixels[j];
          
          // Detectar píxeles negros o muy oscuros (fondo)
          if (red(pixel) < 30 && green(pixel) < 30 && blue(pixel) < 30) {
            cleanFrame.pixels[j] = color(0, 0, 0, 0); // Hacer transparente
          } else {
            cleanFrame.pixels[j] = pixel; // Mantener el pixel original
          }
        }
        
        cleanFrame.updatePixels();
        processedJumpFrames[i] = cleanFrame;
      }
      
      println("✓ Pre-procesamiento completado - " + totalFrames + " frames listos");
      
      // Volver a reproducir el GIF desde el primer frame
      jumpAnimationGif.jump(0);
      jumpAnimationGif.play();
      
    } catch (Exception e) {
      println("ERROR en pre-procesamiento: " + e.getMessage());
      e.printStackTrace();
      processedJumpFrames = null;
    }
  }
  
  // Pre-procesar todos los frames del GIF de corrida para máximo rendimiento 
  void preProcessRunningFrames() {
    if (runningAnimationGif == null) {
      processedRunningFrames = null;
      return;
    }
    
    println("Pre-procesando frames del GIF de corrida para optimización...");
    
    try {
      // Pausar el GIF temporalmente para obtener frames individuales
      runningAnimationGif.pause();
      runningAnimationGif.jump(0); // Ir al primer frame
      
      // Obtener número total de frames de manera compatible
      ArrayList<PImage> tempFrames = new ArrayList<PImage>();
      int frameIndex = 0;
      int maxFramesToCheck = 200; // Límite de seguridad para evitar bucles infinitos
      
      // Iterar a través de todos los frames disponibles
      while (frameIndex < maxFramesToCheck) {
        try {
          runningAnimationGif.jump(frameIndex);
          PImage currentFrame = runningAnimationGif.copy();
          
          // Si conseguimos una imagen válida, agregarla
          if (currentFrame != null && currentFrame.width > 0) {
            tempFrames.add(currentFrame);
            frameIndex++;
          } else {
            // No hay más frames válidos
            break;
          }
        } catch (Exception e) {
          // Si falla al acceder a un frame, hemos llegado al final
          break;
        }
      }
      
      int totalFrames = tempFrames.size();
      if (totalFrames == 0) {
        println("ERROR: No se pudieron obtener frames del GIF de corrida");
        processedRunningFrames = null;
        return;
      }
      
      processedRunningFrames = new PImage[totalFrames];
      println("Procesando " + totalFrames + " frames del GIF de corrida...");
      
      // Procesar cada frame ya obtenido 
      for (int i = 0; i < totalFrames; i++) {
        PImage originalFrame = tempFrames.get(i);
        originalFrame.loadPixels();
        
        // Crear frame procesado
        PImage cleanFrame = createImage(originalFrame.width, originalFrame.height, ARGB);
        cleanFrame.loadPixels();
        
        // Procesar píxeles para eliminar fondos negros/transparentes no deseados
        for (int j = 0; j < originalFrame.pixels.length; j++) {
          color pixel = originalFrame.pixels[j];
          
          // Obtener componentes de color
          float r = red(pixel);
          float g = green(pixel);
          float b = blue(pixel);
          float a = alpha(pixel);
          
          // Detectar píxeles negros, muy oscuros, o con transparencia muy baja (fondo)
          // Usar un umbral más alto para eliminar mejor los fondos negros
          if ((r < 50 && g < 50 && b < 50) || a < 100) {
            cleanFrame.pixels[j] = color(0, 0, 0, 0); // Hacer completamente transparente
          } else {
            // Mantener el pixel original pero asegurar que tenga opacidad completa
            cleanFrame.pixels[j] = color(r, g, b, 255);
          }
        }
        
        cleanFrame.updatePixels();
        processedRunningFrames[i] = cleanFrame;
      }
      
      println("✓ Pre-procesamiento de corrida completado - " + totalFrames + " frames listos");
      
      // Volver a reproducir el GIF desde el primer frame
      runningAnimationGif.jump(0);
      runningAnimationGif.play();
      
    } catch (Exception e) {
      println("ERROR en pre-procesamiento de corrida: " + e.getMessage());
      e.printStackTrace();
      processedRunningFrames = null;
    }
  }
  
  // Métodos para controlar la animación de salto optimizada
  void startJumpAnimation() {
    // Reiniciar la animación desde el primer frame
    currentJumpFrame = 0;
    jumpFrameTimer = 0;
    
    // También controlar el GIF original si está disponible
    if (jumpAnimationGif != null) {
      jumpAnimationGif.jump(0); // Ir al primer frame
      jumpAnimationGif.play();
    }
  }
  
  void stopJumpAnimation() {
    // Pausar en el primer frame
    currentJumpFrame = 0;
    jumpFrameTimer = 0;
    
    // También controlar el GIF original si está disponible
    if (jumpAnimationGif != null) {
      jumpAnimationGif.pause();
      jumpAnimationGif.jump(0); // Volver al primer frame
    }
  }
  
  void pauseJumpAnimation() {
    // Pausar el timer (mantiene el frame actual)
    jumpFrameTimer = 0;
    
    // También controlar el GIF original si está disponible
    if (jumpAnimationGif != null) {
      jumpAnimationGif.pause();
    }
  }
  
  boolean isJumpAnimationPlaying() {
    // Si tenemos frames pre-procesados, siempre puede "reproducirse"
    if (processedJumpFrames != null && processedJumpFrames.length > 0) {
      return true;
    }
    
    // Fallback al GIF original
    if (jumpAnimationGif != null) {
      return jumpAnimationGif.isPlaying();
    }
    
    return false;
  }
  
  // Métodos para la animación de corrida 
  PImage getRunningAnimationImage() {
    if (runningAnimationGif != null && runningAnimationGif.width > 0) {
      // Para GIFs, devolver directamente
      return runningAnimationGif;
    } else {
      // Devolver la imagen de respaldo precargada
      return runningFallbackImage;
    }
  }
  
  // Método optimizado que usa frames pre-procesados 
  PImage getCleanRunningAnimationImage() {
    // Si tenemos frames pre-procesados, usarlos para máximo rendimiento
    if (processedRunningFrames != null && processedRunningFrames.length > 0) {
      // Actualizar timer y frame actual
      runningFrameTimer++;
      if (runningFrameTimer >= runningFrameDelay) {
        runningFrameTimer = 0;
        currentRunningFrame = (currentRunningFrame + 1) % processedRunningFrames.length;
      }
      
      // Asegurar que el índice esté dentro del rango válido
      if (currentRunningFrame >= 0 && currentRunningFrame < processedRunningFrames.length) {
        PImage frame = processedRunningFrames[currentRunningFrame];
        if (frame != null) {
          // Devolver el frame pre-procesado actual 
          return frame;
        }
      }
    }
    
    // Fallback: usar GIF original si no hay frames pre-procesados, pero aplicar filtro
    if (runningAnimationGif != null && runningAnimationGif.width > 0) {
      // Asegurarse de que el GIF esté reproduciéndose
      if (!runningAnimationGif.isPlaying()) {
        runningAnimationGif.play();
      }
      return runningAnimationGif; // Devolver el GIF real, no el fallback
    }
    
    // Último fallback: imagen estática 
    return runningFallbackImage;
  }
  
  // Getter para acceder al objeto Gif de corrida directamente
  Gif getRunningAnimationGif() {
    return runningAnimationGif;
  }
  
  // Método para verificar si el GIF de corrida está activo
  boolean isRunningAnimationGifActive() {
    return runningAnimationGif != null && runningAnimationGif.width > 0;
  }
  
  // Métodos para controlar la animación
  void startRunningAnimation() {
    // Reiniciar la animación desde el primer frame
    currentRunningFrame = 0;
    runningFrameTimer = 0;
    
    // También controlar el GIF original si está disponible
    if (runningAnimationGif != null) {
      runningAnimationGif.jump(0); // Ir al primer frame
      runningAnimationGif.play();
    }
  }
  
  void stopRunningAnimation() {
    // Pausar en el primer frame
    currentRunningFrame = 0;
    runningFrameTimer = 0;
    
    // También controlar el GIF original si está disponible
    if (runningAnimationGif != null) {
      runningAnimationGif.pause();
      runningAnimationGif.jump(0); // Volver al primer frame
    }
  }
  
  void pauseRunningAnimation() {
    // Pausar el timer (mantiene el frame actual)
    runningFrameTimer = 0;
    
    // También controlar el GIF original si está disponible
    if (runningAnimationGif != null) {
      runningAnimationGif.pause();
    }
  }
  
  boolean isRunningAnimationPlaying() {
    // Si tenemos frames pre-procesados, siempre puede "reproducirse"
    if (processedRunningFrames != null && processedRunningFrames.length > 0) {
      return true;
    }
    
    // Fallback al GIF original
    if (runningAnimationGif != null) {
      return runningAnimationGif.isPlaying();
    }
    
    return false;
  }
}