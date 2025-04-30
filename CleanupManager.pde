/**
 * CleanupManager.pde
 * 
 * Responsable de limpiar los recursos cuando la aplicación se cierra.
 * Esto incluye detener videos, cerrar archivos y liberar memoria.
 */

class CleanupManager {
  VideoIntroMenu videoIntroMenu;
  SoundManager soundManager;
  
  CleanupManager() {
    // El constructor está vacío ya que la inicialización se realiza cuando es necesario
  }
  
  void performCleanup() {
    // Detener y liberar los recursos de video
    if (videoIntroMenu != null) {
      videoIntroMenu.cleanup();
    }
    
    // Otras operaciones de limpieza
    cleanupSoundResources();
    
    println("Limpieza completada - saliendo de la aplicación");
  }
  
  void cleanupSoundResources() {
    if (soundManager != null) {
      soundManager.stopAllSounds();
    }
  }
} 