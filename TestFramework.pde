/**
 * TestFramework.pde
 * Framework de pruebas automatizadas para el juego
 */
 
class TestFramework {
  // Instancia del juego a probar
  Game gameInstance;
  // Tracking de resultados
  int totalTests = 0;
  int passedTests = 0;
  int failedTests = 0;
  // Test actual
  String currentTestName = "";
  // Log de pruebas
  ArrayList<String> testLog = new ArrayList<String>();
  // Objetos para testing
  Player mockPlayer;
  EcoSystem mockEcoSystem;
  
  // Estado de las pruebas
  boolean isRunningTests = false;
  boolean testMode = false;
  int currentTestIndex = 0;
  ArrayList<Runnable> testCases = new ArrayList<Runnable>();
  int frameDelay = 0;
  
  TestFramework(Game game) {
    this.gameInstance = game;
    initializeTestCases();
  }
  
  // Inicializar lista de casos de prueba
  void initializeTestCases() {
    // Pruebas de movimiento del jugador
    testCases.add(() -> testPlayerJump());
    testCases.add(() -> testPlayerSlide());
    testCases.add(() -> testVariableJumpHeight());
    
    // Pruebas de detección de colisiones
    testCases.add(() -> testObstacleCollision());
    testCases.add(() -> testCollectibleCollection());
    testCases.add(() -> testShieldProtection());
    
    // Pruebas de power-ups
    testCases.add(() -> testSpeedBoostActivation());
    testCases.add(() -> testDoublePointsActivation());
    testCases.add(() -> testShieldActivation());
    
    // Pruebas del ecosistema
    testCases.add(() -> testEcoMeterPositiveUpdate());
    testCases.add(() -> testEcoMeterNegativeUpdate());
    testCases.add(() -> testEcoSystemStateChanges());
    
    // Pruebas de puntuación
    testCases.add(() -> testScoreIncrement());
    testCases.add(() -> testBonusPointsActivation());
  }
  
  // Ejecutar todas las pruebas
  void runAllTests() {
    isRunningTests = true;
    currentTestIndex = 0;
    passedTests = 0;
    failedTests = 0;
    totalTests = testCases.size();
    testLog.clear();
    logMessage("Iniciando batería de pruebas");
    logMessage("Total de pruebas: " + totalTests);
    
    int previousGameState = gameState;
    gameState = STATE_PAUSED;
    
    frameDelay = 30;
  }
  
  // Update cada frame mientras las pruebas están en ejecución
  void update() {
    if (!isRunningTests) return;
    
    if (frameDelay > 0) {
      frameDelay--;
      return;
    }
    
    if (currentTestIndex < testCases.size()) {
      Runnable testCase = testCases.get(currentTestIndex);
      testCase.run();
      currentTestIndex++;
      frameDelay = 30;
    } else {
      finishTests();
    }
  }
  
  // Finalizar pruebas y mostrar resultados
  void finishTests() {
    isRunningTests = false;
    logMessage("Pruebas completadas");
    logMessage("Resultados: " + passedTests + " pasadas, " + failedTests + " fallidas");
    int totalAssertions = passedTests + failedTests;
    logMessage("Tasa de éxito: " + (int)((float)passedTests / totalAssertions * 100) + "%");
    
    gameState = STATE_MAIN_MENU;
  }
  
  // Helpers para assertions
  boolean assertTrue(String assertion, boolean condition) {
    if (condition) {
      logSuccess(assertion + " - PASADA");
      return true;
    } else {
      logFailure(assertion + " - FALLIDA");
      return false;
    }
  }
  
  boolean assertEquals(String assertion, float expected, float actual, float tolerance) {
    if (abs(expected - actual) <= tolerance) {
      logSuccess(assertion + " - PASADA");
      return true;
    } else {
      logFailure(assertion + " - FALLIDA (Esperado: " + expected + ", Actual: " + actual + ")");
      return false;
    }
  }
  
  boolean assertEquals(String assertion, int expected, int actual) {
    if (expected == actual) {
      logSuccess(assertion + " - PASADA");
      return true;
    } else {
      logFailure(assertion + " - FALLIDA (Esperado: " + expected + ", Actual: " + actual + ")");
      return false;
    }
  }
  
  // Helpers para logs
  void logMessage(String message) {
    testLog.add("[INFO] " + message);
    println("[TEST INFO] " + message);
  }
  
  void logSuccess(String message) {
    testLog.add("[PASS] " + message);
    println("[TEST PASS] " + message);
    passedTests++;
  }
  
  void logFailure(String message) {
    testLog.add("[FAIL] " + message);
    println("[TEST FAIL] " + message);
    failedTests++;
  }
  
  void startTest(String testName) {
    currentTestName = testName;
    logMessage("Iniciando prueba: " + testName);
  }
  
  // Mostrar resultados en pantalla
  void displayResults() {
    if (!isRunningTests && testLog.size() > 0) {
      pushStyle();
      fill(0, 180);
      rectMode(CORNER);
      rect(50, 50, width - 100, height - 100);
      
      fill(255);
      textAlign(CENTER, TOP);
      textSize(24);
      text("Resultados", width/2, 70);
      
      textAlign(LEFT, TOP);
      textSize(14);
      float yPos = 120;
      for (int i = 0; i < min(testLog.size(), 15); i++) {
        String log = testLog.get(testLog.size() - 15 + i);
        if (log.contains("[PASS]")) {
          fill(0, 255, 0);
        } else if (log.contains("[FAIL]")) {
          fill(255, 0, 0);
        } else {
          fill(255);
        }
        text(log, 70, yPos);
        yPos += 20;
      }
      
      fill(200, 200, 255);
      textAlign(CENTER, CENTER);
      textSize(14);
      text("Click the button below or anywhere outside the panel to close", width/2, height - 110);
      
      rectMode(CENTER);
      
      fill(30, 30, 30);
      rect(closeButtonX + 2, closeButtonY + 2, closeButtonWidth, closeButtonHeight);
      
      closeButtonHovered = 
        mouseX > closeButtonX - closeButtonWidth/2 && 
        mouseX < closeButtonX + closeButtonWidth/2 && 
        mouseY > closeButtonY - closeButtonHeight/2 && 
        mouseY < closeButtonY + closeButtonHeight/2;
      
      if (closeButtonHovered) {
        fill(100, 149, 237);
      } else {
        fill(70, 130, 180);
      }
      
      rect(closeButtonX, closeButtonY, closeButtonWidth, closeButtonHeight, 5);
      
      noFill();
      stroke(255);
      strokeWeight(2);
      rect(closeButtonX, closeButtonY, closeButtonWidth, closeButtonHeight, 5);
      
      fill(255);
      textAlign(CENTER, CENTER);
      textSize(16);
      text("CLOSE", closeButtonX, closeButtonY);
      
      popStyle();
    }
  }
  
  float closeButtonX = 0;
  float closeButtonY = 0;
  float closeButtonWidth = 0;
  float closeButtonHeight = 0;
  boolean closeButtonHovered = false;
  boolean closeRequested = false;
  
  void checkMousePressed() {
    if (!isRunningTests && testLog.size() > 0) {
      println("DEBUG: Mouse pressed at " + mouseX + "," + mouseY);
      
      float panelLeft = 50;
      float panelTop = 50;
      float panelRight = width - 50;
      float panelBottom = height - 50;
      
      if (mouseX > closeButtonX - closeButtonWidth/2 && 
          mouseX < closeButtonX + closeButtonWidth/2 && 
          mouseY > closeButtonY - closeButtonHeight/2 && 
          mouseY < closeButtonY + closeButtonHeight/2) {
        
        println("DEBUG: Close button clicked! Requesting close.");
        closeRequested = true;
        return;
      }
      
      if (mouseX < panelLeft || mouseX > panelRight || mouseY < panelTop || mouseY > panelBottom) {
        println("DEBUG: Clicked outside results panel. Requesting close.");
        closeRequested = true;
        return;
      }
    }
  }
  
  void testPlayerJump() {
    startTest("Player Jump Mechanics");
    
    Player player = new Player(width * 0.2, height * 0.8);
    float initialY = player.y;
    
    player.jump();
    
    assertTrue("Player enters jumping state", player.isJumping);
    
    for (int i = 0; i < 5; i++) {
      player.update();
    }
    
    assertTrue("Player moves upward when jumping", player.y < initialY);
    
    while (player.isJumping) {
      player.update();
      if (player.y > height) break;
    }
    
    assertEquals("Player lands at ground level", height * 0.8, player.y, 0.1);
    assertTrue("Player exits jumping state", !player.isJumping);
  }
  
  void testPlayerSlide() {
    startTest("Player Slide Mechanics");
    
    Player player = new Player(width * 0.2, height * 0.8);
    
    player.slide();
    
    assertTrue("Player enters sliding state", player.isSliding);
    assertEquals("Sliding sets correct color", player.slidingColor, player.currentColor);
    
    for (int i = 0; i < 20; i++) {
      player.update();
    }
    
    assertTrue("Player maintains sliding state", player.isSliding);
    
    player.stopSliding();
    
    assertTrue("Player exits sliding state", !player.isSliding);
    assertEquals("Player color resets after slide", player.normalColor, player.currentColor);
  }
  
  void testVariableJumpHeight() {
    startTest("Variable Jump Height");
    
    Player player = new Player(width * 0.2, height * 0.8);
    
    player.jump();
    player.update();
    player.releaseJump();
    
    float maxHeightShortJump = height * 0.8;
    while (player.vSpeed < 0) {
      player.update();
      maxHeightShortJump = min(maxHeightShortJump, player.y);
    }
    
    player = new Player(width * 0.2, height * 0.8);
    
    player.jump();
    for (int i = 0; i < player.maxJumpHoldTime; i++) {
      player.update();
    }
    player.releaseJump();
    
    float maxHeightLongJump = height * 0.8;
    while (player.vSpeed < 0) {
      player.update();
      maxHeightLongJump = min(maxHeightLongJump, player.y);
    }
    
    assertTrue("Variable jump height works correctly", maxHeightLongJump < maxHeightShortJump);
  }
  
  void testObstacleCollision() {
    startTest("Obstacle Collision Detection");
    
    Player player = new Player(width * 0.2, height * 0.8);
    int initialHealth = player.health;
    
    Obstacle obstacle = new Obstacle(player.x, height * 0.8, 50, 50, 0);
    
    boolean collisionDetected = player.isColliding(obstacle);
    assertTrue("Collision detection identifies overlapping objects", collisionDetected);
    
    if (collisionDetected) {
      player.takeDamage();
    }
    
    assertEquals("Player health decreases upon collision", initialHealth - 1, player.health);
    assertTrue("Player becomes temporarily invincible after collision", player.isInvincible);
  }
  
  void testCollectibleCollection() {
    startTest("Collectible Collection Detection");
    
    Player player = new Player(width * 0.2, height * 0.8);
    
    Collectible collectible = new Collectible(player.x, player.y - player.size/2, 30, 5, Collectible.COIN);
    
    boolean collectionDetected = player.isCollectingItem(collectible);
    assertTrue("Collectible collection detection works", collectionDetected);
    
    collectible = new Collectible(player.x + 100, player.y, 30, 5, Collectible.COIN);
    collectionDetected = player.isCollectingItem(collectible);
    assertTrue("Non-collection detection works", !collectionDetected);
  }
  
  void testShieldProtection() {
    startTest("Shield Protection from Collisions");
    
    Player player = new Player(width * 0.2, height * 0.8);
    int initialHealth = player.health;
    
    player.activateShield(300);
    assertTrue("Shield activates correctly", player.hasShield);
    
    Obstacle obstacle = new Obstacle(player.x, height * 0.8, 50, 50, 0);
    
    boolean collisionDetected = player.isColliding(obstacle);
    if (collisionDetected) {
      player.takeDamage();
    }
    
    assertEquals("Shield prevents health loss", initialHealth, player.health);
    assertTrue("Shield is consumed upon impact", !player.hasShield);
  }
  
  void testSpeedBoostActivation() {
    startTest("Speed Boost Power-up Effect");
    
    Player player = new Player(width * 0.2, height * 0.8);
    float originalMultiplier = player.speedMultiplier;
    
    player.activateSpeedBoost(300);
    
    assertTrue("Speed boost power-up active state", player.hasSpeedBoost);
    assertTrue("Speed boost increases speed multiplier", player.speedMultiplier > originalMultiplier);
    
    player.deactivateSpeedBoost();
    
    assertEquals("Speed returns to normal after boost", originalMultiplier, player.speedMultiplier, 0.01);
    assertTrue("Speed boost deactivates correctly", !player.hasSpeedBoost);
  }
  
  void testDoublePointsActivation() {
    startTest("Double Points Power-up Effect");
    
    Player player = new Player(width * 0.2, height * 0.8);
    int originalMultiplier = player.pointsMultiplier;
    
    player.activateDoublePoints(300);
    
    assertTrue("Double points power-up active state", player.hasDoublePoints);
    assertEquals("Points multiplier increases correctly", originalMultiplier * 2, player.pointsMultiplier);
    
    player.deactivateDoublePoints();
    
    assertEquals("Points multiplier returns to normal", originalMultiplier, player.pointsMultiplier);
    assertTrue("Double points deactivates correctly", !player.hasDoublePoints);
  }
  
  void testShieldActivation() {
    startTest("Shield Power-up Activation");
    
    Player player = new Player(width * 0.2, height * 0.8);
    
    player.activateShield(300);
    
    assertTrue("Shield activates correctly", player.hasShield);
    
    player.update();
    assertTrue("Shield size is appropriate", player.shieldSize > player.size);
    
    player.deactivateShield();
    
    assertTrue("Shield deactivates correctly", !player.hasShield);
  }
  
  void testEcoMeterPositiveUpdate() {
    startTest("Eco-Meter Positive Update");
    
    EcoSystem ecoSystem = new EcoSystem();
    float initialHealth = ecoSystem.ecoHealth;
    float impactAmount = 10.0;
    
    ecoSystem.applyPositiveImpact(impactAmount);
    
    assertTrue("Eco-meter increases with positive actions", ecoSystem.ecoHealth > initialHealth);
    assertEquals("Eco-meter increases by correct amount", initialHealth + impactAmount, ecoSystem.ecoHealth, 0.1);
    assertTrue("Active effect is shown for positive impact", ecoSystem.hasActiveEffect);
  }
  
  void testEcoMeterNegativeUpdate() {
    startTest("Eco-Meter Negative Update");
    
    EcoSystem ecoSystem = new EcoSystem();
    float initialHealth = ecoSystem.ecoHealth;
    float impactAmount = 10.0;
    
    ecoSystem.applyNegativeImpact(impactAmount);
    
    assertTrue("Eco-meter decreases with negative actions", ecoSystem.ecoHealth < initialHealth);
    assertEquals("Eco-meter decreases by correct amount", initialHealth - impactAmount, ecoSystem.ecoHealth, 0.1);
    assertTrue("Active effect is shown for negative impact", ecoSystem.hasActiveEffect);
  }
  
  void testEcoSystemStateChanges() {
    startTest("Eco-System State Transitions");
    
    EcoSystem ecoSystem = new EcoSystem();
    
    ecoSystem.ecoHealth = ecoSystem.goodThreshold + 5;
    assertTrue("Eco-system correctly identifies good state", ecoSystem.isInGoodState());
    assertTrue("Eco-system correctly identifies non-warning state", !ecoSystem.isInWarningState());
    assertTrue("Eco-system correctly identifies non-critical state", !ecoSystem.isInCriticalState());
    
    ecoSystem.ecoHealth = ecoSystem.warningThreshold - 5;
    assertTrue("Eco-system correctly identifies warning state", ecoSystem.isInWarningState());
    assertTrue("Eco-system correctly identifies non-good state", !ecoSystem.isInGoodState());
    assertTrue("Eco-system correctly identifies non-critical state", !ecoSystem.isInCriticalState());
    
    ecoSystem.ecoHealth = ecoSystem.criticalThreshold - 5;
    assertTrue("Eco-system correctly identifies critical state", ecoSystem.isInCriticalState());
    assertTrue("Eco-system correctly identifies non-good state", !ecoSystem.isInGoodState());
    assertTrue("Eco-system correctly identifies non-warning state", !ecoSystem.isInWarningState());
  }
  
  void testScoreIncrement() {
    startTest("Score Increment System");
    
    Game game = new Game();
    int initialScore = game.score;
    
    for (int i = 0; i < 60; i++) {
      game.updateScore();
    }
    
    assertTrue("Score increases during gameplay", game.score > initialScore);
  }
  
  void testBonusPointsActivation() {
    startTest("Bonus Points Activation");
    
    Game game = new Game();
    int initialScore = game.score;
    
    game.framesSinceLastCollision = game.bonusThreshold + 10;
    
    for (int i = 0; i < 10; i++) {
      game.updateScore();
    }
    
    assertTrue("Bonus points activate after threshold", game.score > initialScore + 10);
  }
}

interface Runnable {
  void run();
} 