/**
 * Clase SoundManager - Maneja toda la retroalimentación de audio para el juego
 * Controla tanto los efectos de sonido como la música de fondo
 */
class SoundManager {
  // Indicadores de sonido
  boolean isSoundOn = true;
  boolean isMusicOn = true;
  
  // Objetos de sonido (comentados hasta que se añadan los archivos de sonido)
  // import processing.sound.*;
  // SoundFile buttonSound;
  // SoundFile menuSound;
  // SoundFile gameOverSound;
  // SoundFile jumpSound;
  // SoundFile collisionSound;
  // SoundFile collectSound;
  // SoundFile powerUpSound;
  // SoundFile backgroundMusic;
  
  // Posiciones de la fuente de efectos de sonido (para audio posicional y señales visuales)
  float lastSoundX = 0;
  float lastSoundY = 0;
  String lastSoundType = "";
  
  // Referencia al gestor de accesibilidad
  AccessibilityManager accessManager;
  
  // Constructor predeterminado
  SoundManager() {
    // Inicializar con gestor de accesibilidad predeterminado
    this.accessManager = new AccessibilityManager();
    
    // Inicializar archivos de sonido (comentados hasta que se añadan los archivos de sonido)
    // buttonSound = new SoundFile(proyFinalPOO.this, "button.wav");
    // menuSound = new SoundFile(proyFinalPOO.this, "menu.wav");
    // gameOverSound = new SoundFile(proyFinalPOO.this, "gameover.wav");
    // jumpSound = new SoundFile(proyFinalPOO.this, "jump.wav");
    // collisionSound = new SoundFile(proyFinalPOO.this, "collision.wav");
    // collectSound = new SoundFile(proyFinalPOO.this, "collect.wav");
    // powerUpSound = new SoundFile(proyFinalPOO.this, "powerup.wav");
    // backgroundMusic = new SoundFile(proyFinalPOO.this, "bgmusic.wav");
    
    // Iniciar música de fondo
    // playBackgroundMusic();
    
    println("Sound Manager initialized");
  }
  
  // Constructor con parámetro AccessibilityManager
  SoundManager(AccessibilityManager accessManager) {
    this.accessManager = accessManager;
    
    // Inicializar archivos de sonido (comentados hasta que se añadan los archivos de sonido)
    // buttonSound = new SoundFile(proyFinalPOO.this, "button.wav");
    // menuSound = new SoundFile(proyFinalPOO.this, "menu.wav");
    // gameOverSound = new SoundFile(proyFinalPOO.this, "gameover.wav");
    // jumpSound = new SoundFile(proyFinalPOO.this, "jump.wav");
    // collisionSound = new SoundFile(proyFinalPOO.this, "collision.wav");
    // collectSound = new SoundFile(proyFinalPOO.this, "collect.wav");
    // powerUpSound = new SoundFile(proyFinalPOO.this, "powerup.wav");
    // backgroundMusic = new SoundFile(proyFinalPOO.this, "bgmusic.wav");
    
    // Iniciar música de fondo
    // playBackgroundMusic();
    
    println("Sound Manager initialized with AccessibilityManager");
  }
  
  // Activar/desactivar efectos de sonido
  void toggleSound() {
    isSoundOn = !isSoundOn;
    println("Sound effects: " + (isSoundOn ? "ON" : "OFF"));
  }
  
  // Activar/desactivar música de fondo
  void toggleMusic() {
    isMusicOn = !isMusicOn;
    println("Music: " + (isMusicOn ? "ON" : "OFF"));
    
    // if (isMusicOn) {
    //   playBackgroundMusic();
    // } else {
    //   if (backgroundMusic.isPlaying()) {
    //     backgroundMusic.stop();
    //   }
    // }
  }
  
  // Reproducir sonido de clic de botón
  void playButtonSound() {
    if (isSoundOn) {
      // if (buttonSound != null) {
      //   buttonSound.play();
      // }
      println("Button sound");
      
      // Recordar propiedades del sonido para señales visuales
      lastSoundType = "button";
      lastSoundX = mouseX;
      lastSoundY = mouseY;
    }
  }
  
  // Reproducir sonido de navegación del menú
  void playMenuSound() {
    if (isSoundOn) {
      // if (menuSound != null) {
      //   menuSound.play();
      // }
      println("Menu sound");
      
      // Recordar propiedades del sonido para señales visuales
      lastSoundType = "menu";
      lastSoundX = width/2;
      lastSoundY = height/2;
    }
  }
  
  // Reproducir sonido de fin de juego
  void playGameOverSound() {
    if (isSoundOn) {
      // if (gameOverSound != null) {
      //   gameOverSound.play();
      // }
      println("Game over sound");
      
      // Recordar propiedades del sonido para señales visuales
      lastSoundType = "gameover";
      lastSoundX = width/2;
      lastSoundY = height/2;
      
      // Mostrar señal visual si está habilitado
      if (accessManager.visualCuesForAudio) {
        accessManager.displaySoundCue(lastSoundType, lastSoundX, lastSoundY);
      }
    }
  }
  
  // Reproducir sonido de salto
  void playJumpSound() {
    if (isSoundOn) {
      // if (jumpSound != null) {
      //   jumpSound.play();
      // }
      println("Jump sound");
      
      // Recordar propiedades del sonido para señales visuales
      lastSoundType = "jump";
    }
  }
  
  // Reproducir sonido de colisión
  void playCollisionSound() {
    if (isSoundOn) {
      // if (collisionSound != null) {
      //   collisionSound.play();
      // }
      println("Collision sound");
      
      // Recordar propiedades del sonido para señales visuales
      lastSoundType = "collision";
    }
  }
  
  // Reproducir sonido de daño cuando el jugador es golpeado
  void playHitSound() {
    if (isSoundOn) {
      // if (collisionSound != null) {  // Podemos reutilizar el sonido de colisión
      //   collisionSound.play();
      // }
      println("Hit sound");
      
      // Recordar propiedades del sonido para señales visuales
      lastSoundType = "hit";
      
      // Mostrar señal visual si está habilitado
      if (accessManager.visualCuesForAudio) {
        accessManager.displaySoundCue("hit", lastSoundX, lastSoundY);
      }
    }
  }
  
  // Reproducir sonido de recolección de objetos
  void playCollectSound() {
    if (isSoundOn) {
      // if (collectSound != null) {
      //   collectSound.play();
      // }
      println("Collect sound");
      
      // Recordar propiedades del sonido para señales visuales
      lastSoundType = "collect";
      
      // Mostrar señal visual si está habilitado
      if (accessManager.visualCuesForAudio) {
        accessManager.displaySoundCue(lastSoundType, lastSoundX, lastSoundY);
      }
    }
  }
  
  // Reproducir sonido de power-up
  void playPowerUpSound() {
    if (isSoundOn) {
      // if (powerUpSound != null) {
      //   powerUpSound.play();
      // }
      println("Power-up sound");
      
      // Recordar propiedades del sonido para señales visuales
      lastSoundType = "powerup";
      
      // Mostrar señal visual si está habilitado
      if (accessManager.visualCuesForAudio) {
        accessManager.displaySoundCue(lastSoundType, lastSoundX, lastSoundY);
      }
    }
  }
  
  // Reproducir sonido de ruptura de escudo
  void playShieldBreakSound() {
    if (isSoundOn) {
      // if (powerUpSound != null) {
      //   powerUpSound.play(0.5, 1.5); // Reproducir con pitch más alto para efecto de ruptura
      // }
      println("Shield break sound");
      
      // Recordar propiedades del sonido para señales visuales
      lastSoundType = "shield_break";
      
      // Mostrar señal visual si está habilitado
      if (accessManager.visualCuesForAudio) {
        accessManager.displaySoundCue("shield_break", lastSoundX, lastSoundY);
      }
    }
  }
  
  // Reproducir sonido de subida de nivel
  void playLevelUpSound() {
    if (isSoundOn) {
      // Podríamos usar el mismo sonido de powerUp hasta tener uno específico
      // if (powerUpSound != null) {
      //   powerUpSound.play();
      // }
      println("Level up sound");
      
      // Recordar propiedades del sonido para señales visuales
      lastSoundType = "levelup";
      lastSoundX = width/2;
      lastSoundY = height/3;
      
      // Mostrar señal visual si está habilitado
      if (accessManager.visualCuesForAudio) {
        accessManager.displaySoundCue(lastSoundType, lastSoundX, lastSoundY);
      }
    }
  }
  
  // Reproducir música de fondo (en bucle)
  void playBackgroundMusic() {
    if (isMusicOn) {
      // if (backgroundMusic != null) {
      //   backgroundMusic.loop();
      // }
      println("Background music started");
    }
  }
  
  // Detener todos los efectos de sonido y música
  void stopAllSounds() {
    // Detener música de fondo si está reproduciéndose
    // if (backgroundMusic != null && backgroundMusic.isPlaying()) {
    //   backgroundMusic.stop();
    // }
    
    // Detener todos los demás efectos de sonido si es necesario
    // if (buttonSound != null && buttonSound.isPlaying()) buttonSound.stop();
    // if (menuSound != null && menuSound.isPlaying()) menuSound.stop();
    // if (gameOverSound != null && gameOverSound.isPlaying()) gameOverSound.stop();
    // if (jumpSound != null && jumpSound.isPlaying()) jumpSound.stop();
    // if (collisionSound != null && collisionSound.isPlaying()) collisionSound.stop();
    // if (collectSound != null && collectSound.isPlaying()) collectSound.stop();
    // if (powerUpSound != null && powerUpSound.isPlaying()) powerUpSound.stop();
    
    println("All sounds stopped");
  }
  
  // Establecer la posición de la fuente de sonido (para audio posicional y señales visuales)
  void setSoundPosition(float x, float y) {
    lastSoundX = x;
    lastSoundY = y;
  }
} 