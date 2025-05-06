/**
 * GameStateManager.pde
 * 
 * Gestiona las transiciones entre estados del juego y proporciona una forma centralizada
 * de manejar cambios de estado. Coordina los componentes cuando ocurren cambios.
 */

class GameStateManager {
  // Estado
  private int currentState;
  
  // Callback para notificar cambios de estado
  private Runnable onStateChangeCallback;
  
  GameStateManager() {
    this.currentState = STATE_INTRO_VIDEO; // Estado inicial predeterminado
  }
  
  int getState() {
    return currentState;
  }
  
  // Establecer una función de callback para notificar cambios de estado
  void setOnStateChangeCallback(Runnable callback) {
    this.onStateChangeCallback = callback;
  }
  
  void setState(int newState) {
    // Realizar acciones específicas al cambiar estado
    if (newState == STATE_MAIN_MENU && (currentState == STATE_PAUSED || currentState == STATE_GAME_OVER)) {
      // Cuando volvemos al menú principal desde el menú de pausa o fin de juego
      // realizar una limpieza adicional para evitar elementos residuales
      cleanupBeforeMainMenu();
    }
    
    this.currentState = newState;
    
    // Notificar cambio de estado si es necesario
    if (onStateChangeCallback != null) {
      onStateChangeCallback.run();
    }
  }
  
  // Método para limpiar específicamente al volver al menú principal
  void cleanupBeforeMainMenu() {
    // Forzar una limpieza visual completa para evitar elementos residuales
    // que puedan quedar en pantalla
    clear();
    
    // No usamos background(0) para evitar problemas con las imágenes de fondo
    
    // Asegurarse de que los gestores clave estén limpios
    // (la implementación específica depende del juego)
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