/**
 * Clase VideoIntroMenu - Gestiona la secuencia introductoria y la animación del menú para EcoRunner
 * 
 * Características:
 * 1. Reproduce un video introductorio (menuVideo.mp4) cuando el juego se inicia por primera vez
 * 2. Hace una transición a una imagen de fondo estática (menuFinal.png) cuando termina el video
 * 3. Anima los botones del menú con efectos de escala y aparición gradual en secuencia escalonada
 * 4. Admite una alternativa elegante a imagen estática si el archivo de video falta o está corrupto
 * 5. Permite saltar el video de intro con la tecla ESC
 * 6. Se integra con la navegación por teclado/ratón para los botones del menú
 * 7. Proporciona retroalimentación visual (brillo/resaltado) para los botones activos
 * 
 * Notas de implementación:
 * - Usa la biblioteca Video de Processing para reproducción de video cuando está disponible
 * - Aplica ajustes de accesibilidad a todos los elementos visuales
 * - Mantiene una estratificación adecuada (fondo → botones)
 * - Maneja todos los recursos relacionados de manera responsable (carga y limpieza)
 */
import processing.video.*;
import java.io.File;
import java.io.FileNotFoundException;

class VideoIntroMenu {
  // Componentes de video
  Movie introVideo;
  PImage finalBackground;
  boolean videoFinished = false;
  boolean videoSkipped = false;
  
  // Animación alternativa usando imágenes cuando el video no está disponible
  boolean useImageFallback = false;
  PImage[] fallbackFrames;
  int currentFallbackFrame = 0;
  int lastFrameChangeTime = 0;
  int frameDuration = 100; // milisegundos por frame
  int fallbackDuration = 3000; // duración total de la animación en milisegundos
  int fallbackStartTime = 0;
  
  // Propiedades de animación
  boolean buttonsRevealed = false;
  float[] buttonScales;         // Valor de escala para cada botón
  float[] buttonOpacities;      // Valor de opacidad para cada botón
  int currentRevealingButton = 0;
  float revealTimer = 0;
  float buttonRevealDelay = 200; // Milisegundos entre cada revelación de botón
  
  // Constantes
  final float BUTTON_SCALE_TARGET = 1.0;
  final float BUTTON_OPACITY_TARGET = 255;
  final float SCALE_SPEED = 0.1;
  final float OPACITY_SPEED = 15;
  
  // Navegación del menú
  int selectedMenuItem = 0;
  
  // Referencia al menú
  Menu menu = null;
  // Gestor de accesibilidad
  AccessibilityManager accessManager;
  // Gestor de sonido
  SoundManager soundManager;
  
  VideoIntroMenu() {
    this.accessManager = new AccessibilityManager();
    this.soundManager = new SoundManager(accessManager);
    try {
      // Primero, intentar cargar la imagen de fondo final que necesitaremos de cualquier manera
      try {
        finalBackground = loadImage("assets/menuFinal.png");
        if (finalBackground == null) {
          println("ADVERTENCIA: No se pudo cargar la imagen de fondo del menú");
        } else {
          println("Fondo del menú cargado correctamente");
        }
      } catch (Exception e) {
        println("ERROR al cargar la imagen de fondo: " + e.getMessage());
      }
      
      // Intentar cargar y configurar el video
      String videoPath = sketchPath("assets/menuVideo.mp4");
      println("Intentando cargar video desde: " + videoPath);
      
      // Comprobar si el archivo existe antes de intentar cargarlo
      File videoFile = new File(videoPath);
      if (!videoFile.exists()) {
        println("ADVERTENCIA: Archivo de video no encontrado en: " + videoPath);
        throw new FileNotFoundException("Archivo de video no encontrado: " + videoPath);
      }
      
      try {
        introVideo = new Movie(proyFinalPOO.this, videoPath);
        println("Video cargado correctamente");
      } catch (Exception e) {
        println("ERROR al cargar el video: " + e.getMessage());
        throw e;
      }
      
      // Inicializar con arrays vacíos predeterminados hasta que se establezca el menú
      buttonScales = new float[0];
      buttonOpacities = new float[0];
      
    } catch (FileNotFoundException e) {
      // Archivo de video no encontrado - configurar alternativa de imagen
      setupImageFallback();
    } catch (NoClassDefFoundError e) {
      // La biblioteca de video no está instalada - configurar alternativa de imagen
      println("ADVERTENCIA: Biblioteca de Video de Processing no instalada. Usando alternativa de imagen en su lugar.");
      setupImageFallback();
    } catch (Exception e) {
      // Otros errores - configurar alternativa de imagen
      println("ERROR al inicializar la introducción de video: " + e.getMessage());
      e.printStackTrace();
      setupImageFallback();
    }
  }
  
  // Constructor con AccessibilityManager
  VideoIntroMenu(AccessibilityManager accessManager) {
    this();
    this.accessManager = accessManager;
  }
  
  // Constructor con AccessibilityManager y SoundManager
  VideoIntroMenu(AccessibilityManager accessManager, SoundManager soundManager) {
    this();
    this.accessManager = accessManager;
    this.soundManager = soundManager;
  }
  
  // Constructor con AccessibilityManager, SoundManager y AssetManager
  VideoIntroMenu(AccessibilityManager accessManager, SoundManager soundManager, AssetManager assetManager) {
    this.accessManager = accessManager;
    this.soundManager = soundManager;
    
    try {
      // Primero, intentar cargar la imagen de fondo final usando AssetManager
      if (assetManager != null) {
        finalBackground = assetManager.getFinalBackground();
        if (finalBackground == null) {
          println("ADVERTENCIA: No se pudo obtener la imagen de fondo del menú desde AssetManager");
          
          // Intentar cargar directamente si no está disponible en AssetManager
          finalBackground = loadImage("assets/menuFinal.png");
        } else {
          println("Fondo del menú cargado correctamente desde AssetManager");
        }
      } else {
        try {
          finalBackground = loadImage("assets/menuFinal.png");
          if (finalBackground == null) {
            println("ADVERTENCIA: No se pudo cargar la imagen de fondo del menú");
          } else {
            println("Fondo del menú cargado correctamente");
          }
        } catch (Exception e) {
          println("ERROR al cargar la imagen de fondo: " + e.getMessage());
        }
      }
      
      // Intentar cargar y configurar el video
      String videoPath = sketchPath("assets/menuVideo.mp4");
      println("Intentando cargar video desde: " + videoPath);
      
      // Comprobar si el archivo existe antes de intentar cargarlo
      File videoFile = new File(videoPath);
      if (!videoFile.exists()) {
        println("ADVERTENCIA: Archivo de video no encontrado en: " + videoPath);
        throw new FileNotFoundException("Archivo de video no encontrado: " + videoPath);
      }
      
      try {
        introVideo = new Movie(proyFinalPOO.this, videoPath);
        println("Video cargado correctamente");
      } catch (Exception e) {
        println("ERROR al cargar el video: " + e.getMessage());
        throw e;
      }
      
      // Inicializar con arrays vacíos predeterminados hasta que se establezca el menú
      buttonScales = new float[0];
      buttonOpacities = new float[0];
      
    } catch (FileNotFoundException e) {
      // Archivo de video no encontrado - configurar alternativa de imagen
      setupImageFallback();
    } catch (NoClassDefFoundError e) {
      // La biblioteca de video no está instalada - configurar alternativa de imagen
      println("ADVERTENCIA: Biblioteca de Video de Processing no instalada. Usando alternativa de imagen en su lugar.");
      setupImageFallback();
    } catch (Exception e) {
      // Otros errores - configurar alternativa de imagen
      println("ERROR al inicializar la introducción de video: " + e.getMessage());
      e.printStackTrace();
      setupImageFallback();
    }
  }
  
  // Método para establecer la referencia del menú e inicializar arrays de botones
  void setMenu(Menu menu) {
    this.menu = menu;
    
    // Ahora que tenemos el menú, inicializar los arrays de botones
    if (menu != null && menu.mainMenuButtons != null) {
      int buttonCount = menu.mainMenuButtons.size();
      buttonScales = new float[buttonCount];
      buttonOpacities = new float[buttonCount];
      
      // Establecer valores iniciales
      for (int i = 0; i < buttonCount; i++) {
        buttonScales[i] = 0.0;
        buttonOpacities[i] = 0;
      }
    } else {
      // Predeterminar a arrays vacíos si el menú aún no está disponible
      buttonScales = new float[0];
      buttonOpacities = new float[0];
    }
  }
  
  // Método para establecer el gestor de sonido
  void setSoundManager(SoundManager soundManager) {
    this.soundManager = soundManager;
  }
  
  // Configurar la animación alternativa usando imágenes estáticas en lugar de video
  private void setupImageFallback() {
    useImageFallback = true;
    videoFinished = false;
    videoSkipped = false;
    
    // Inicializar con arrays vacíos predeterminados hasta que se establezca el menú
    buttonScales = new float[0];
    buttonOpacities = new float[0];
    
    // Intentar cargar frames para animación alternativa desde assets
    try {
      // Para simplificar, usaremos el fondo final como único frame
      // En una implementación real, podrías tener múltiples frames como "frame_01.png", "frame_02.png", etc.
      fallbackFrames = new PImage[1];
      fallbackFrames[0] = finalBackground;
    } catch (Exception e) {
      println("ERROR al configurar alternativa de imagen: " + e.getMessage());
      // Ir directo al menú si incluso la alternativa falla
      setupButtonsForDirectMenu();
    }
  }
  
  // Método auxiliar para configurar botones para acceso directo al menú (saltando animación)
  private void setupButtonsForDirectMenu() {
    // Comprobar si el menú está disponible
    if (menu != null && menu.mainMenuButtons != null) {
    // Configurar botones para que se muestren completamente
    int buttonCount = menu.mainMenuButtons.size();
    buttonScales = new float[buttonCount];
    buttonOpacities = new float[buttonCount];
    
    for (int i = 0; i < buttonCount; i++) {
      buttonScales[i] = BUTTON_SCALE_TARGET;
      buttonOpacities[i] = BUTTON_OPACITY_TARGET;
      }
    } else {
      // Predeterminar a arrays vacíos si el menú aún no está disponible
      buttonScales = new float[0];
      buttonOpacities = new float[0];
    }
    
    // Marcar los botones como revelados
    buttonsRevealed = true;
    videoFinished = true;
    videoSkipped = true;
  }
  
  void startVideo() {
    if (useImageFallback) {
      // Iniciar la animación alternativa
      fallbackStartTime = millis();
      currentFallbackFrame = 0;
      lastFrameChangeTime = millis();
      videoFinished = false;
      videoSkipped = false;
      println("Starting fallback image animation");
    } else if (introVideo != null) {
      // Iniciar reproducción del video
      introVideo.play();
      videoFinished = false;
      videoSkipped = false;
      println("Starting video playback");
    } else {
      // Si el video no está disponible, considerarlo saltado
      videoFinished = true;
      videoSkipped = true;
      buttonsRevealed = true;
      println("No video available, skipping to menu");
      return;
    }
    
    // Reiniciar valores de animación
    buttonsRevealed = false;
    for (int i = 0; i < buttonScales.length; i++) {
      buttonScales[i] = 0.0;
      buttonOpacities[i] = 0;
    }
    
    currentRevealingButton = 0;
    revealTimer = 0;
  }
  
  void display() {
    if (!videoFinished && !videoSkipped) {
      if (useImageFallback) {
        // Mostrar animación alternativa usando imágenes
        displayFallbackAnimation();
      } else if (introVideo != null) {
        try {
          // Mostrar el video durante la intro
          if (introVideo.available()) {
            introVideo.read();
          }
          
          // Dibujar el frame del video
          image(introVideo, 0, 0, width, height);
          
          // Comprobar si el video está cerca de su fin para preparar revelación de botones
          float videoTime = introVideo.time();
          float videoDuration = introVideo.duration();
          
          // Solo continuar si tenemos valores válidos de tiempo/duración
          if (videoDuration > 0) {
            if (videoTime >= videoDuration - 3) {
              // Comenzar a revelar botones antes de que termine el video
              startButtonReveal();
            }
            
            // Comprobar si el video ha terminado
            if (videoTime >= videoDuration - 0.1) {
              videoFinished = true;
              println("Video playback complete");
            }
          } else {
            // Si no podemos obtener una duración válida, considerar el video terminado después de 5 segundos
            if (millis() > 5000) {
              videoFinished = true;
              println("Video considered complete (could not get valid duration)");
            }
          }
        } catch (Exception e) {
          // Manejar cualquier error de reproducción de video
          println("ERROR during video playback: " + e.getMessage());
          e.printStackTrace();
          videoFinished = true;
          videoSkipped = true;
        }
      } else {
        // El video es nulo, así que considerarlo saltado
        videoFinished = true;
        videoSkipped = true;
      }
      
      // Mostrar mensaje para saltar
      textAlign(RIGHT, BOTTOM);
      textSize(accessManager.getAdjustedTextSize(16));
      fill(255, 200);
      text("Press ESC to skip", width - 20, height - 20);
    } else {
      // Video terminado o saltado, mostrar fondo final
      if (finalBackground != null) {
        image(finalBackground, 0, 0, width, height);
      } else {
        // Si la imagen de fondo no se pudo cargar, mostrar un color sólido
        background(80, 150, 200);
      }
      
      // Mostrar botones animados
      displayAnimatedButtons();
    }
  }
  
  // Mostrar la animación alternativa usando imágenes estáticas
  void displayFallbackAnimation() {
    // Calcular cuánto hemos avanzado en la animación
    int currentTime = millis();
    int elapsedTime = currentTime - fallbackStartTime;
    
    // Dibujar el frame actual
    if (fallbackFrames != null && fallbackFrames.length > 0 && fallbackFrames[0] != null) {
      image(fallbackFrames[0], 0, 0, width, height);
    } else {
      // Usar un color sólido si no hay imágenes disponibles
      background(80, 150, 200);
    }
    
    // Comprobar si debemos comenzar a revelar botones
    if (elapsedTime >= fallbackDuration - 1000) {
      startButtonReveal();
    }
    
    // Comprobar si la animación está completa
    if (elapsedTime >= fallbackDuration) {
      videoFinished = true;
    }
  }
  
  void startButtonReveal() {
    // Si no estamos revelando botones ya, comenzar el proceso
    if (currentRevealingButton == 0 && revealTimer == 0) {
      revealTimer = millis();
    }
  }
  
  void displayAnimatedButtons() {
    // Comprobar si el menú está disponible
    if (menu == null || menu.mainMenuButtons == null || menu.mainMenuButtons.size() == 0) {
      return; // Nada que mostrar si el menú no está inicializado
    }
    
    pushStyle();
    rectMode(CENTER);
    
    // Comprobar si es momento de revelar un nuevo botón
    if (currentRevealingButton < buttonScales.length) {
      if (millis() - revealTimer > buttonRevealDelay) {
        // Comenzar a revelar el siguiente botón
        revealTimer = millis();
        currentRevealingButton++;
      }
    }
    
    // Actualizar y mostrar cada botón con animación
    for (int i = 0; i < menu.mainMenuButtons.size(); i++) {
      // Asegurar que no excedamos la longitud de los arrays de botones
      if (i >= buttonScales.length) break;
      
      Button button = menu.mainMenuButtons.get(i);
      
      // Solo animar botones que han comenzado su revelación
      if (i < currentRevealingButton) {
        // Actualizar escala y opacidad
        if (buttonScales[i] < BUTTON_SCALE_TARGET) {
          buttonScales[i] += SCALE_SPEED;
          if (buttonScales[i] > BUTTON_SCALE_TARGET) {
            buttonScales[i] = BUTTON_SCALE_TARGET;
          }
        }
        
        if (buttonOpacities[i] < BUTTON_OPACITY_TARGET) {
          buttonOpacities[i] += OPACITY_SPEED;
          if (buttonOpacities[i] > BUTTON_OPACITY_TARGET) {
            buttonOpacities[i] = BUTTON_OPACITY_TARGET;
          }
        }
        
        // Dibujar el botón con la escala y opacidad actuales
        pushMatrix();
        translate(button.x, button.y);
        scale(buttonScales[i]);
        
        // Actualizar estado de resaltado desde la selección del menú principal
        if (i == selectedMenuItem && buttonsRevealed) {
          button.setHighlighted(true);
        }
        
        // Aplicar ajustes de color de accesibilidad - igual que en Button display()
        color currentBaseColor = accessManager.adjustButtonColor(button.baseColor);
        color currentHoverColor = accessManager.adjustButtonHoverColor(button.hoverColor);
        color currentTextColor = accessManager.adjustTextColor(button.textColor);
        
        // Determinar qué color usar
        color displayColor;
        if (button.isHighlighted || button.isHovered) {
          displayColor = currentHoverColor;
        } else {
          displayColor = currentBaseColor;
        }
        
        // Aplicar opacidad para la animación
        displayColor = color(red(displayColor), green(displayColor), blue(displayColor), buttonOpacities[i]);
        
        // Dibujar sombra para botón en forma de píldora (coincidiendo con el estilo de la clase Button)
        if (!accessManager.highContrastMode && !accessManager.reduceAnimations && buttonOpacities[i] > 50) {
          noStroke();
          fill(0, constrain(buttonOpacities[i] * 0.3, 0, 60));
          rect(2, 3, button.width, button.height, button.height/2); // Esquinas completamente redondeadas para forma de píldora con desplazamiento para sombra
        }
        
        // Dibujar efecto de brillo cuando está resaltado o bajo el cursor (coincidiendo con el estilo de la clase Button)
        if ((button.isHighlighted || button.isHovered) && buttonOpacities[i] > 100 && !accessManager.reduceAnimations) {
          noStroke();
          // Dibujar múltiples capas de contornos semitransparentes para efecto de brillo
          for (int j = 0; j < 3; j++) {
            float alpha = min(buttonOpacities[i] * 0.25, 60) * (3-j) / 3.0;
            float size = j * 3;
            color glowColor = accessManager.highContrastMode ? 
                             color(255, alpha) : // Brillo blanco para alto contraste
                             color(red(displayColor), green(displayColor), blue(displayColor), alpha); // Brillo del mismo color
                             
            fill(glowColor);
            rect(0, 0, button.width + size, button.height + size, (button.height + size)/2); // Forma completa de píldora
          }
        }
        
        // Dibujar fondo del botón con forma de píldora (coincidiendo con el estilo de la clase Button)
        if (accessManager.highContrastMode) {
          stroke(255, buttonOpacities[i]);
          strokeWeight(3);
        } else {
          stroke(80, 100, 120, buttonOpacities[i]);
          strokeWeight(1);
        }
        fill(displayColor);
        rect(0, 0, button.width, button.height, button.height/2); // Usar h/2 para esquinas completamente redondeadas (forma de píldora)
        
        // Dibujar contorno para botones resaltados/bajo el cursor (coincidiendo con el estilo de la clase Button)
        if ((button.isHighlighted || button.isHovered) && buttonOpacities[i] > 150) {
          strokeWeight(2);
          stroke(255, buttonOpacities[i]);
          noFill();
          rect(0, 0, button.width + 4, button.height + 4, (button.height + 4)/2);
        }
        
        // Aplicar ajuste de tamaño de texto desde el gestor de accesibilidad
        float textSizeValue = accessManager.getAdjustedTextSize(20); // Tamaño predeterminado
        textSize(textSizeValue);
        
        // Dibujar el texto con sombra para mejor legibilidad (coincidiendo con el estilo de la clase Button)
        textAlign(CENTER, CENTER);
        
        // Añadir sombra al texto
        if (!accessManager.highContrastMode && buttonOpacities[i] > 150) {
          fill(0, buttonOpacities[i] * 0.2);
          text(button.text, 1, 1);
        }
        
        // Dibujar texto principal con opacidad actual
        fill(red(currentTextColor), green(currentTextColor), blue(currentTextColor), buttonOpacities[i]);
        text(button.text, 0, 0);
        
        // Si está completamente revelado, comprobar hover y clic
        if (buttonScales[i] >= BUTTON_SCALE_TARGET && buttonOpacities[i] >= BUTTON_OPACITY_TARGET) {
          // Actualizar el estado del botón pero dibujarlo nosotros mismos
          if (!accessManager.keyboardOnly) {
            boolean wasHovered = button.isHovered;
            boolean newHoverState = mouseX >= button.x - button.width/2 && mouseX <= button.x + button.width/2 && 
                              mouseY >= button.y - button.height/2 && mouseY <= button.y + button.height/2;
            
            // Si comenzamos a pasar el cursor sobre este botón, limpiar selección por teclado
            if (newHoverState && !wasHovered) {
              menu.clearKeyboardSelection();
            }
            
            button.isHovered = newHoverState;
            
            // Reproducir efecto de sonido al pasar el cursor por primera vez sobre un botón
            if (!wasHovered && button.isHovered) {
              soundManager.playMenuSound();
            }
          }
        }
        
        popMatrix();
      }
    }
    
    // Comprobar si todos los botones están completamente revelados
    boolean allRevealed = true;
    for (int i = 0; i < buttonScales.length; i++) {
      if (buttonScales[i] < BUTTON_SCALE_TARGET || buttonOpacities[i] < BUTTON_OPACITY_TARGET) {
        allRevealed = false;
        break;
      }
    }
    
    buttonsRevealed = allRevealed;
    
    popStyle();
  }
  
  void handleKeyPressed() {
    // Permitir saltar el video de introducción con la tecla ESC
    if (!videoFinished && !videoSkipped && keyCode == ESC) {
      videoSkipped = true;
      introVideo.stop();
      
      // Comenzar a revelar botones inmediatamente
      startButtonReveal();
      currentRevealingButton = 1; // Activar la aparición del primer botón
      
      // Evitar que ESC cierre la aplicación
      key = 0;
    }
    
    // Manejar navegación por teclado cuando los botones están revelados
    if ((videoFinished || videoSkipped) && buttonsRevealed) {
      // Mover selección a la izquierda con flecha IZQUIERDA o tecla A
      if (keyCode == LEFT || key == 'a' || key == 'A') {
        // Limpiar efectos anteriores
        for (Button button : menu.mainMenuButtons) {
          button.setHighlighted(false);
          button.applyKeyboardHoverEffect(false);
        }
        
        selectedMenuItem--;
        if (selectedMenuItem < 0) {
          selectedMenuItem = menu.mainMenuButtons.size() - 1;
        }
        
        // Aplicar efectos al nuevo botón seleccionado
        Button selectedButton = menu.mainMenuButtons.get(selectedMenuItem);
        selectedButton.setHighlighted(true);
        selectedButton.applyKeyboardHoverEffect(true);
        
        menu.updateSelectedItem(STATE_MAIN_MENU, selectedMenuItem);
        soundManager.playMenuSound();
      }
      // Mover selección a la derecha con flecha DERECHA o tecla D
      else if (keyCode == RIGHT || key == 'd' || key == 'D') {
        // Limpiar efectos anteriores
        for (Button button : menu.mainMenuButtons) {
          button.setHighlighted(false);
          button.applyKeyboardHoverEffect(false);
        }
        
        selectedMenuItem++;
        if (selectedMenuItem >= menu.mainMenuButtons.size()) {
          selectedMenuItem = 0;
        }
        
        // Aplicar efectos al nuevo botón seleccionado
        Button selectedButton = menu.mainMenuButtons.get(selectedMenuItem);
        selectedButton.setHighlighted(true);
        selectedButton.applyKeyboardHoverEffect(true);
        
        menu.updateSelectedItem(STATE_MAIN_MENU, selectedMenuItem);
        soundManager.playMenuSound();
      }
      // Activar botón seleccionado con ENTER o ESPACIO
      else if (keyCode == ENTER || keyCode == RETURN || key == ' ') {
        // Simular clic de botón procesando la acción apropiada
        // Esto será manejado por el bucle principal del juego cuando pase a STATE_MAIN_MENU
      }
    }
  }
  
  // Método para manejar pulsaciones de ratón en el menú de introducción
  void handleMousePressed() {
    // Saltar intro de video si se está reproduciendo
    if (!videoFinished && !videoSkipped) {
      skipVideo();
      return;
    }
    
    // Si el video ha terminado y los botones están revelados, manejar clics en los botones
    if (buttonsRevealed && menu != null && menu.mainMenuButtons != null) {
      // Comprobar cada botón
      for (int i = 0; i < menu.mainMenuButtons.size(); i++) {
        Button button = menu.mainMenuButtons.get(i);
        if (button.isHovered) {
          // Establecer selección y activar este botón
          selectedMenuItem = i;
          if (menu != null) {
            menu.updateSelectedItem(STATE_MAIN_MENU, selectedMenuItem);
            soundManager.playButtonSound();
          }
          return;
        }
      }
    }
  }
  
  // Método para saltar la introducción de video
  void skipVideo() {
    videoSkipped = true;
    
    // Detener el video si se está reproduciendo
    if (introVideo != null && !videoFinished) {
      try {
        introVideo.stop();
      } catch (Exception e) {
        println("Error stopping video: " + e.getMessage());
      }
    }
    
    // Comenzar a revelar botones inmediatamente
    startButtonReveal();
    currentRevealingButton = 1; // Activar la aparición del primer botón
  }
  
  // Método para comprobar si la introducción de video está completa
  boolean isComplete() {
    return videoFinished || videoSkipped;
  }
  
  void cleanup() {
    try {
      // Detener y liberar recursos de video
      if (introVideo != null) {
        try {
          introVideo.stop();
          println("Video stopped successfully");
        } catch (Exception e) {
          println("Error stopping video: " + e.getMessage());
        }
      }
      
      // Liberar recursos de imágenes
      if (fallbackFrames != null) {
        for (int i = 0; i < fallbackFrames.length; i++) {
          fallbackFrames[i] = null;
        }
        fallbackFrames = null;
      }
      
      // Liberar fondo
      //finalBackground = null; // Mantener esto para uso del menú
    } catch (Exception e) {
      println("ERROR during cleanup: " + e.getMessage());
    }
  }
} 