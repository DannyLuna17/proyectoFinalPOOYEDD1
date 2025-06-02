/**
 * GameStateManager.pde
 * 
 * Gestiona las transiciones entre estados del juego y proporciona una forma centralizada
 * de manejar cambios de estado. Coordina los componentes cuando ocurren cambios.
 */

class GameStateManager {
  // Estado actual del juego
  int currentState = STATE_INTRO_VIDEO;
  int previousState = STATE_INTRO_VIDEO;
  
  // Variable para rastrear el origen del leaderboard - súper importante para el comportamiento correcto
  boolean leaderboardFromMainMenu = false; // true = abierto desde menú principal, false = abierto después de partida
  
  // Callback para notificar cambios de estado
  private Runnable onStateChangeCallback;
  
  GameStateManager() {
    this.currentState = STATE_INTRO_VIDEO; // Estado inicial predeterminado
  }
  
  int getState() {
    return currentState;
  }
  
  int getPreviousState() {
    return previousState;
  }
  
  // Establecer una función de callback para notificar cambios de estado
  void setOnStateChangeCallback(Runnable callback) {
    this.onStateChangeCallback = callback;
  }
  
  // Método principal para cambiar estados
  void setState(int newState) {
    // Guardar el estado anterior antes de cambiar
    previousState = currentState;
    
    // Detectar automáticamente desde dónde se abre el leaderboard para comportamiento inteligente
    if (newState == STATE_LEADERBOARD) {
      // Si venimos del menú principal, marcar que es desde menú
      if (currentState == STATE_MAIN_MENU) {
        leaderboardFromMainMenu = true;
      } else {
        // Si venimos de cualquier otro estado (partida, entrada de nombre, etc.), es desde juego
        leaderboardFromMainMenu = false;
      }
    }
    
    currentState = newState;
    
    // Notificar cambio de estado si es necesario
    if (onStateChangeCallback != null) {
      onStateChangeCallback.run();
    }
  }
  
  // Método especial para abrir leaderboard desde menú principal
  void openLeaderboardFromMenu() {
    previousState = currentState;
    currentState = STATE_LEADERBOARD;
    leaderboardFromMainMenu = true; 
  }
  
  // Método especial para abrir leaderboard después de partida  
  void openLeaderboardFromGame() {
    previousState = currentState;
    currentState = STATE_LEADERBOARD;
    leaderboardFromMainMenu = false; 
  }
  
  // Getter para saber el origen del leaderboard
  boolean isLeaderboardFromMainMenu() {
    return leaderboardFromMainMenu;
  }
  
  boolean isGameplayState() {
    return currentState == STATE_GAME;
  }
  
  boolean isMenuState() {
    return currentState == STATE_MAIN_MENU || 
           currentState == STATE_INSTRUCTIONS || 
           currentState == STATE_SETTINGS || 
           currentState == STATE_PAUSED ||
           currentState == STATE_GAME_OVER ||
           currentState == STATE_LEADERBOARD ||
           currentState == STATE_NAME_INPUT ||
           currentState == STATE_XP_SUMMARY;
  }
  
  boolean isPausedState() {
    return currentState == STATE_PAUSED;
  }
  
  boolean isGameOverState() {
    return currentState == STATE_GAME_OVER;
  }
} 