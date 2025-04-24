/**
 * SoundManager class - Handles all audio feedback for the game
 * Controls both sound effects and background music
 */
class SoundManager {
  // Sound flags
  boolean isSoundOn = true;
  boolean isMusicOn = true;
  
  // Sound objects (commented out until sound files are added)
  // import processing.sound.*;
  // SoundFile buttonSound;
  // SoundFile menuSound;
  // SoundFile gameOverSound;
  // SoundFile jumpSound;
  // SoundFile collisionSound;
  // SoundFile collectSound;
  // SoundFile powerUpSound;
  // SoundFile backgroundMusic;
  
  // Sound effect source positions (for positional audio and visual cues)
  float lastSoundX = 0;
  float lastSoundY = 0;
  String lastSoundType = "";
  
  SoundManager() {
    // Initialize sound files (commented out until sound files are added)
    // buttonSound = new SoundFile(proyFinalPOO.this, "button.wav");
    // menuSound = new SoundFile(proyFinalPOO.this, "menu.wav");
    // gameOverSound = new SoundFile(proyFinalPOO.this, "gameover.wav");
    // jumpSound = new SoundFile(proyFinalPOO.this, "jump.wav");
    // collisionSound = new SoundFile(proyFinalPOO.this, "collision.wav");
    // collectSound = new SoundFile(proyFinalPOO.this, "collect.wav");
    // powerUpSound = new SoundFile(proyFinalPOO.this, "powerup.wav");
    // backgroundMusic = new SoundFile(proyFinalPOO.this, "bgmusic.wav");
    
    // Start background music
    // playBackgroundMusic();
    
    println("Sound Manager initialized");
  }
  
  // Toggle sound effects on/off
  void toggleSound() {
    isSoundOn = !isSoundOn;
    println("Sound effects: " + (isSoundOn ? "ON" : "OFF"));
  }
  
  // Toggle background music on/off
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
  
  // Play button click sound
  void playButtonSound() {
    if (isSoundOn) {
      // if (buttonSound != null) {
      //   buttonSound.play();
      // }
      println("Button sound");
      
      // Remember sound properties for visual cues
      lastSoundType = "button";
      lastSoundX = mouseX;
      lastSoundY = mouseY;
    }
  }
  
  // Play menu navigation sound
  void playMenuSound() {
    if (isSoundOn) {
      // if (menuSound != null) {
      //   menuSound.play();
      // }
      println("Menu sound");
      
      // Remember sound properties for visual cues
      lastSoundType = "menu";
      lastSoundX = width/2;
      lastSoundY = height/2;
    }
  }
  
  // Play game over sound
  void playGameOverSound() {
    if (isSoundOn) {
      // if (gameOverSound != null) {
      //   gameOverSound.play();
      // }
      println("Game over sound");
      
      // Remember sound properties for visual cues
      lastSoundType = "gameover";
      lastSoundX = width/2;
      lastSoundY = height/2;
      
      // Display sound cue if enabled
      if (accessManager.visualCuesForAudio) {
        accessManager.displaySoundCue(lastSoundType, lastSoundX, lastSoundY);
      }
    }
  }
  
  // Play jump sound
  void playJumpSound() {
    if (isSoundOn) {
      // if (jumpSound != null) {
      //   jumpSound.play();
      // }
      println("Jump sound");
      
      // Remember sound properties for visual cues
      lastSoundType = "jump";
    }
  }
  
  // Play collision sound
  void playCollisionSound() {
    if (isSoundOn) {
      // if (collisionSound != null) {
      //   collisionSound.play();
      // }
      println("Collision sound");
      
      // Remember sound properties for visual cues
      lastSoundType = "collision";
    }
  }
  
  // Play item collection sound
  void playCollectSound() {
    if (isSoundOn) {
      // if (collectSound != null) {
      //   collectSound.play();
      // }
      println("Collect sound");
      
      // Remember sound properties for visual cues
      lastSoundType = "collect";
      
      // Display sound cue if enabled
      if (accessManager.visualCuesForAudio) {
        accessManager.displaySoundCue(lastSoundType, lastSoundX, lastSoundY);
      }
    }
  }
  
  // Play power-up sound
  void playPowerUpSound() {
    if (isSoundOn) {
      // if (powerUpSound != null) {
      //   powerUpSound.play();
      // }
      println("Power-up sound");
      
      // Remember sound properties for visual cues
      lastSoundType = "powerup";
      
      // Display sound cue if enabled
      if (accessManager.visualCuesForAudio) {
        accessManager.displaySoundCue(lastSoundType, lastSoundX, lastSoundY);
      }
    }
  }
  
  // Play background music (looping)
  void playBackgroundMusic() {
    if (isMusicOn) {
      // if (backgroundMusic != null) {
      //   backgroundMusic.loop();
      // }
      println("Background music started");
    }
  }
  
  // Set the position of the sound source (for positional audio and visual cues)
  void setSoundPosition(float x, float y) {
    lastSoundX = x;
    lastSoundY = y;
  }
} 