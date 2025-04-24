/**
 * VideoIntroMenu class - Manages the introductory sequence and menu animation for EcoRunner
 * 
 * Features:
 * 1. Plays an introductory video (menuVideo.mp4) when the game first launches
 * 2. Transitions to a static background image (menuFinal.png) when the video ends
 * 3. Animates menu buttons with scale-in and fade-in effects in a staggered sequence
 * 4. Supports graceful fallback to static image if video file is missing or corrupt
 * 5. Allows skipping the intro video with ESC key
 * 6. Integrates with keyboard/mouse navigation for menu buttons
 * 7. Provides visual feedback (glow/highlight) for active buttons
 * 
 * Implementation Notes:
 * - Uses Processing Video library for video playback when available
 * - Applies accessibility adjustments to all visual elements
 * - Maintains proper layering (background → buttons)
 * - Handles all related resources responsibly (loading and cleanup)
 */
import processing.video.*;
import java.io.File;
import java.io.FileNotFoundException;

class VideoIntroMenu {
  // Video components
  Movie introVideo;
  PImage finalBackground;
  boolean videoFinished = false;
  boolean videoSkipped = false;
  
  // Fallback animation using images when video is not available
  boolean useImageFallback = false;
  PImage[] fallbackFrames;
  int currentFallbackFrame = 0;
  int lastFrameChangeTime = 0;
  int frameDuration = 100; // milliseconds per frame
  int fallbackDuration = 3000; // total animation duration in milliseconds
  int fallbackStartTime = 0;
  
  // Animation properties
  boolean buttonsRevealed = false;
  float[] buttonScales;         // Scale value for each button
  float[] buttonOpacities;      // Opacity value for each button
  int currentRevealingButton = 0;
  float revealTimer = 0;
  float buttonRevealDelay = 200; // Milliseconds between each button reveal
  
  // Constants
  final float BUTTON_SCALE_TARGET = 1.0;
  final float BUTTON_OPACITY_TARGET = 255;
  final float SCALE_SPEED = 0.1;
  final float OPACITY_SPEED = 15;
  
  VideoIntroMenu() {
    try {
      // First, try to load the final background image which we'll need either way
      try {
        finalBackground = loadImage("assets/menuFinal.png");
        if (finalBackground == null) {
          println("WARNING: Could not load menu background image");
        } else {
          println("Menu background loaded successfully");
        }
      } catch (Exception e) {
        println("ERROR loading background image: " + e.getMessage());
      }
      
      // Try to load and setup the video
      String videoPath = sketchPath("assets/menuVideo.mp4");
      println("Attempting to load video from: " + videoPath);
      
      // Check if the file exists before trying to load it
      File videoFile = new File(videoPath);
      if (!videoFile.exists()) {
        println("WARNING: Video file not found at: " + videoPath);
        throw new FileNotFoundException("Video file not found: " + videoPath);
      }
      
      try {
        introVideo = new Movie(proyFinalPOO.this, videoPath);
        println("Video loaded successfully");
      } catch (Exception e) {
        println("ERROR loading video: " + e.getMessage());
        throw e;
      }
      
      // Initialize animation arrays based on number of main menu buttons
      int buttonCount = menu.mainMenuButtons.size();
      buttonScales = new float[buttonCount];
      buttonOpacities = new float[buttonCount];
      
      // Set initial values
      for (int i = 0; i < buttonCount; i++) {
        buttonScales[i] = 0.0;
        buttonOpacities[i] = 0;
      }
    } catch (FileNotFoundException e) {
      // Video file not found - set up image fallback
      setupImageFallback();
    } catch (NoClassDefFoundError e) {
      // Video library is not installed - set up image fallback
      println("WARNING: Processing Video library not installed. Using image fallback instead.");
      setupImageFallback();
    } catch (Exception e) {
      // Other errors - set up image fallback
      println("ERROR initializing video intro: " + e.getMessage());
      e.printStackTrace();
      setupImageFallback();
    }
  }
  
  // Set up the fallback animation using static images instead of video
  private void setupImageFallback() {
    useImageFallback = true;
    videoFinished = false;
    videoSkipped = false;
    
    // Initialize button arrays
    int buttonCount = menu.mainMenuButtons.size();
    buttonScales = new float[buttonCount];
    buttonOpacities = new float[buttonCount];
    
    for (int i = 0; i < buttonCount; i++) {
      buttonScales[i] = 0.0;
      buttonOpacities[i] = 0;
    }
    
    // Try to load frames for fallback animation from assets
    try {
      // For simplicity, we'll just use the final background as the only frame
      // In a real implementation, you might have multiple frames like "frame_01.png", "frame_02.png", etc.
      fallbackFrames = new PImage[1];
      fallbackFrames[0] = finalBackground;
    } catch (Exception e) {
      println("ERROR setting up image fallback: " + e.getMessage());
      // Set direct to menu if even fallback fails
      setupButtonsForDirectMenu();
    }
  }
  
  // Helper method to set up buttons for direct menu access (skipping animation)
  private void setupButtonsForDirectMenu() {
    // Set buttons to be fully revealed
    int buttonCount = menu.mainMenuButtons.size();
    buttonScales = new float[buttonCount];
    buttonOpacities = new float[buttonCount];
    
    for (int i = 0; i < buttonCount; i++) {
      buttonScales[i] = BUTTON_SCALE_TARGET;
      buttonOpacities[i] = BUTTON_OPACITY_TARGET;
    }
    
    // Mark buttons as revealed
    buttonsRevealed = true;
    videoFinished = true;
    videoSkipped = true;
  }
  
  void startVideo() {
    if (useImageFallback) {
      // Start the fallback animation
      fallbackStartTime = millis();
      currentFallbackFrame = 0;
      lastFrameChangeTime = millis();
      videoFinished = false;
      videoSkipped = false;
      println("Starting fallback image animation");
    } else if (introVideo != null) {
      // Start playing the video
      introVideo.play();
      videoFinished = false;
      videoSkipped = false;
      println("Starting video playback");
    } else {
      // If video is not available, consider it skipped
      videoFinished = true;
      videoSkipped = true;
      buttonsRevealed = true;
      println("No video available, skipping to menu");
      return;
    }
    
    // Reset animation values
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
        // Display fallback animation using images
        displayFallbackAnimation();
      } else if (introVideo != null) {
        try {
          // Display the video during intro
          if (introVideo.available()) {
            introVideo.read();
          }
          
          // Draw the video frame
          image(introVideo, 0, 0, width, height);
          
          // Check if the video is near its end to prepare button reveal
          float videoTime = introVideo.time();
          float videoDuration = introVideo.duration();
          
          // Only proceed if we have valid time/duration values
          if (videoDuration > 0) {
            if (videoTime >= videoDuration - 3) {
              // Start revealing buttons before video fully ends
              startButtonReveal();
            }
            
            // Check if video has finished
            if (videoTime >= videoDuration - 0.1) {
              videoFinished = true;
              println("Video playback complete");
            }
          } else {
            // If we can't get valid duration, consider the video finished after 5 seconds
            if (millis() > 5000) {
              videoFinished = true;
              println("Video considered complete (could not get valid duration)");
            }
          }
        } catch (Exception e) {
          // Handle any video playback errors
          println("ERROR during video playback: " + e.getMessage());
          e.printStackTrace();
          videoFinished = true;
          videoSkipped = true;
        }
      } else {
        // Video is null, so consider it skipped
        videoFinished = true;
        videoSkipped = true;
      }
      
      // Draw skip message
      textAlign(RIGHT, BOTTOM);
      textSize(accessManager.getAdjustedTextSize(16));
      fill(255, 200);
      text("Press ESC to skip", width - 20, height - 20);
    } else {
      // Video finished or skipped, display final background
      if (finalBackground != null) {
        image(finalBackground, 0, 0, width, height);
      } else {
        // If background image failed to load, just draw a solid color
        background(80, 150, 200);
      }
      
      // Display animated buttons
      displayAnimatedButtons();
    }
  }
  
  // Display the fallback animation using static images
  void displayFallbackAnimation() {
    // Calculate how far we are through the animation
    int currentTime = millis();
    int elapsedTime = currentTime - fallbackStartTime;
    
    // Draw the current frame
    if (fallbackFrames != null && fallbackFrames.length > 0 && fallbackFrames[0] != null) {
      image(fallbackFrames[0], 0, 0, width, height);
    } else {
      // Fallback to a solid color if no images available
      background(80, 150, 200);
    }
    
    // Check if we should start revealing buttons
    if (elapsedTime >= fallbackDuration - 1000) {
      startButtonReveal();
    }
    
    // Check if animation is complete
    if (elapsedTime >= fallbackDuration) {
      videoFinished = true;
    }
  }
  
  void startButtonReveal() {
    // If not already revealing buttons, start the process
    if (currentRevealingButton == 0 && revealTimer == 0) {
      revealTimer = millis();
    }
  }
  
  void displayAnimatedButtons() {
    pushStyle();
    rectMode(CENTER);
    
    // Check if time to reveal a new button
    if (currentRevealingButton < buttonScales.length) {
      if (millis() - revealTimer > buttonRevealDelay) {
        // Start revealing next button
        revealTimer = millis();
        currentRevealingButton++;
      }
    }
    
    // Update and display each button with animation
    for (int i = 0; i < menu.mainMenuButtons.size(); i++) {
      Button button = menu.mainMenuButtons.get(i);
      
      // Only animate buttons that have started their reveal
      if (i < currentRevealingButton) {
        // Update scale and opacity
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
        
        // Draw the button with current scale and opacity
        pushMatrix();
        translate(button.x, button.y);
        scale(buttonScales[i]);
        
        // Update highlight state from the main menu selection
        if (i == selectedMenuItem && buttonsRevealed) {
          button.setHighlighted(true);
        }
        
        // Apply accessibility color adjustments - same as in Button display()
        color currentBaseColor = accessManager.adjustButtonColor(button.baseColor);
        color currentHoverColor = accessManager.adjustButtonHoverColor(button.hoverColor);
        color currentTextColor = accessManager.adjustTextColor(button.textColor);
        
        // Determine which color to use
        color displayColor;
        if (button.isHighlighted || button.isHovered) {
          displayColor = currentHoverColor;
        } else {
          displayColor = currentBaseColor;
        }
        
        // Apply opacity for the animation
        displayColor = color(red(displayColor), green(displayColor), blue(displayColor), buttonOpacities[i]);
        
        // Draw drop shadow for pill-shaped button (matching Button class style)
        if (!accessManager.highContrastMode && !accessManager.reduceAnimations && buttonOpacities[i] > 50) {
          noStroke();
          fill(0, constrain(buttonOpacities[i] * 0.3, 0, 60));
          rect(2, 3, button.w, button.h, button.h/2); // Full rounded corners for pill shape with offset for shadow
        }
        
        // Draw glow effect when highlighted or hovered (matching Button class style)
        if ((button.isHighlighted || button.isHovered) && buttonOpacities[i] > 100 && !accessManager.reduceAnimations) {
          noStroke();
          // Draw multiple layers of semi-transparent outlines for glow effect
          for (int j = 0; j < 3; j++) {
            float alpha = min(buttonOpacities[i] * 0.25, 60) * (3-j) / 3.0;
            float size = j * 3;
            color glowColor = accessManager.highContrastMode ? 
                             color(255, alpha) : // White glow for high contrast
                             color(red(displayColor), green(displayColor), blue(displayColor), alpha); // Color-matched glow
                             
            fill(glowColor);
            rect(0, 0, button.w + size, button.h + size, (button.h + size)/2); // Full pill shape
          }
        }
        
        // Draw button background with pill shape (matching Button class style)
        if (accessManager.highContrastMode) {
          stroke(255, buttonOpacities[i]);
          strokeWeight(3);
        } else {
          stroke(80, 100, 120, buttonOpacities[i]);
          strokeWeight(1);
        }
        fill(displayColor);
        rect(0, 0, button.w, button.h, button.h/2); // Use h/2 for fully rounded corners (pill shape)
        
        // Draw outline for highlighted/hovered buttons (matching Button class style)
        if ((button.isHighlighted || button.isHovered) && buttonOpacities[i] > 150) {
          strokeWeight(2);
          stroke(255, buttonOpacities[i]);
          noFill();
          rect(0, 0, button.w + 4, button.h + 4, (button.h + 4)/2);
        }
        
        // Apply text size adjustment from accessibility manager
        float textSizeValue = accessManager.getAdjustedTextSize(20); // Default size
        textSize(textSizeValue);
        
        // Draw the text with shadow for better legibility (matching Button class style)
        textAlign(CENTER, CENTER);
        
        // Add text shadow 
        if (!accessManager.highContrastMode && buttonOpacities[i] > 150) {
          fill(0, buttonOpacities[i] * 0.2);
          text(button.text, 1, 1);
        }
        
        // Draw main text with current opacity
        fill(red(currentTextColor), green(currentTextColor), blue(currentTextColor), buttonOpacities[i]);
        text(button.text, 0, 0);
        
        // If fully revealed, check for hover and click
        if (buttonScales[i] >= BUTTON_SCALE_TARGET && buttonOpacities[i] >= BUTTON_OPACITY_TARGET) {
          // Update the button's state but draw it ourselves
          if (!accessManager.keyboardOnly) {
            boolean wasHovered = button.isHovered;
            boolean newHoverState = mouseX >= button.x - button.w/2 && mouseX <= button.x + button.w/2 && 
                              mouseY >= button.y - button.h/2 && mouseY <= button.y + button.h/2;
            
            // If we're starting to hover over this button, clear keyboard selection
            if (newHoverState && !wasHovered) {
              menu.clearKeyboardSelection();
            }
            
            button.isHovered = newHoverState;
            
            // Play sound effect when first hovering over a button
            if (!wasHovered && button.isHovered) {
              soundManager.playMenuSound();
            }
          }
        }
        
        popMatrix();
      }
    }
    
    // Check if all buttons are fully revealed
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
    // Allow skipping the intro video with ESC key
    if (!videoFinished && !videoSkipped && keyCode == ESC) {
      videoSkipped = true;
      introVideo.stop();
      
      // Start revealing buttons immediately
      startButtonReveal();
      currentRevealingButton = 1; // Trigger first button to appear
      
      // Prevent ESC from closing the application
      key = 0;
    }
    
    // Handle keyboard navigation when buttons are revealed
    if ((videoFinished || videoSkipped) && buttonsRevealed) {
      // Move selection left with LEFT arrow or A key
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
      // Move selection right with RIGHT arrow or D key
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
      // Activate selected button with ENTER or SPACE
      else if (keyCode == ENTER || keyCode == RETURN || key == ' ') {
        // Simulate button click by processing the appropriate action
        // This will be handled by the main game loop when it transitions to STATE_MAIN_MENU
      }
    }
  }
  
  boolean isComplete() {
    // Return true if intro is complete and all buttons are fully revealed
    return (videoFinished || videoSkipped) && buttonsRevealed;
  }
  
  void cleanup() {
    try {
      // Stop and release video resources
      if (introVideo != null) {
        try {
          introVideo.stop();
          println("Video stopped successfully");
        } catch (Exception e) {
          println("Error stopping video: " + e.getMessage());
        }
      }
      
      // Release image resources
      if (fallbackFrames != null) {
        for (int i = 0; i < fallbackFrames.length; i++) {
          fallbackFrames[i] = null;
        }
        fallbackFrames = null;
      }
      
      // Release background
      //finalBackground = null; // Keep this for menu use
    } catch (Exception e) {
      println("ERROR during cleanup: " + e.getMessage());
    }
  }
} 