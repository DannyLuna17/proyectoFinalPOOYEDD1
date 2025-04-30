/**
 * GameStateManager.pde
 * 
 * Gestiona las transiciones entre estados del juego y proporciona una forma centralizada
 * de manejar cambios de estado. Coordina los componentes cuando ocurren cambios.
 */

class GameStateManager {
  // Estado
  private int currentState;
  
  GameStateManager() {
    this.currentState = STATE_INTRO_VIDEO; // Estado inicial predeterminado
  }
  
  int getState() {
    return currentState;
  }
  
  void setState(int newState) {
    currentState = newState;
  }
  
  boolean isGameplayState() {
    return currentState == STATE_GAME;
  }
  
  boolean isMenuState() {
    return currentState == STATE_MAIN_MENU || 
           currentState == STATE_INSTRUCTIONS || 
           currentState == STATE_SETTINGS || 
           currentState == STATE_PAUSED ||
           currentState == STATE_GAME_OVER;
  }
  
  boolean isPausedState() {
    return currentState == STATE_PAUSED;
  }
  
  boolean isGameOverState() {
    return currentState == STATE_GAME_OVER;
  }
} 