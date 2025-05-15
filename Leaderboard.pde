/**
 * Leaderboard.pde
 * 
 * Sistema de clasificación que muestra los mejores puntajes de los jugadores.
 * Permite visualizar los 30 mejores puntajes ordenados de mayor a menor.
 */
class Leaderboard {
  // Lista de records para la tabla de clasificación
  ArrayList<LeaderboardRecord> records;
  
  // Propiedades de visualización
  int maxRecordsToShow = 30;
  int visibleRecords = 10; // Cantidad de registros visibles sin desplazamiento
  int scrollOffset = 0; // Desplazamiento actual para mostrar más registros
  
  // Iconos para los 3 primeros lugares
  PImage goldIcon;
  PImage silverIcon;
  PImage bronzeIcon;
  
  // Referencias a otras clases necesarias
  AccessibilityManager accessManager;
  AssetManager assetManager;
  
  // Botón para volver - usando la misma clase Button del menú principal
  Button backButton;
  
  // Constructor
  Leaderboard(AccessibilityManager accessManager, AssetManager assetManager) {
    this.accessManager = accessManager;
    this.assetManager = assetManager;
    records = new ArrayList<LeaderboardRecord>();
    
    // Inicializar botón de volver con el mismo estilo que los botones del menú
    // Usamos la misma clase Button para mantener la consistencia visual en todo el juego
    backButton = new Button(width/2, height/2 + (height * 0.7)/2 - 35, 180, 45, "VOLVER", accessManager);
    
    // Inicializar con datos de ejemplo (se eliminarán cuando haya records reales)
    loadIcons();
    generateSampleData();
  }
  
  // Cargar iconos para los primeros puestos
  void loadIcons() {
    // Intentar cargar iconos desde el AssetManager
    if (assetManager != null) {
      // Intentar cargar las imágenes de medallas si existen
      try {
        goldIcon = loadImage("assets/gold_medal.png");
        silverIcon = loadImage("assets/silver_medal.png");
        bronzeIcon = loadImage("assets/bronze_medal.png");
      } catch (Exception e) {
        println("No se pudieron cargar las imágenes de medallas: " + e.getMessage());
      }
    }
    
    // Si los iconos no se cargan, crear unos por defecto
    if (goldIcon == null) {
      goldIcon = createDefaultIcon(color(255, 215, 0)); // Oro
    }
    if (silverIcon == null) {
      silverIcon = createDefaultIcon(color(192, 192, 192)); // Plata
    }
    if (bronzeIcon == null) {
      bronzeIcon = createDefaultIcon(color(205, 127, 50)); // Bronce
    }
  }
  
  // Crea un icono por defecto si no se pueden cargar las imágenes
  PImage createDefaultIcon(color medalColor) {
    // Crear una imagen pequeña para usar como icono
    PImage icon = createImage(30, 30, ARGB);
    icon.loadPixels();
    
    // Dibujar un círculo del color correspondiente
    for (int y = 0; y < icon.height; y++) {
      for (int x = 0; x < icon.width; x++) {
        // Calcular la distancia desde el centro
        float distance = dist(x, y, icon.width/2, icon.height/2);
        
        if (distance < icon.width/2) {
          // Dentro del círculo
          icon.pixels[y * icon.width + x] = medalColor;
        } else {
          // Fuera del círculo (transparente)
          icon.pixels[y * icon.width + x] = color(0, 0);
        }
      }
    }
    
    icon.updatePixels();
    return icon;
  }
  
  // Genera datos de ejemplo para pruebas
  void generateSampleData() {
    // Solo generar datos si la lista está vacía
    if (records.isEmpty()) {
      // Añadir algunos registros de prueba
      addRecord("Player1", 10000, "2023-12-01", "10:25");
      addRecord("Player2", 8500, "2023-12-02", "08:15");
      addRecord("Player3", 7200, "2023-12-03", "12:40");
      addRecord("Player4", 6800, "2023-12-04", "05:30");
      addRecord("Player5", 5500, "2023-12-05", "14:20");
    }
  }
  
  // Añadir un nuevo record a la tabla
  void addRecord(String playerName, int score, String date, String playtime) {
    // Limitar nombre a 14 caracteres
    if (playerName.length() > 14) {
      playerName = playerName.substring(0, 14);
    }
    
    // Crear y añadir el nuevo record
    LeaderboardRecord record = new LeaderboardRecord(playerName, score, date, playtime);
    records.add(record);
    
    // Ordenar la lista de mayor a menor según puntuación
    sortRecords();
    
    // Mantener solo los mejores 30 registros
    trimRecords();
  }
  
  // Ordenar los registros por puntuación (de mayor a menor)
  void sortRecords() {
    records.sort((a, b) -> b.score - a.score);
  }
  
  // Mantener solo los mejores 30 registros
  void trimRecords() {
    if (records.size() > maxRecordsToShow) {
      records = new ArrayList<LeaderboardRecord>(records.subList(0, maxRecordsToShow));
    }
  }
  
  // Añadir un nuevo record desde el juego actual
  void addRecordFromGame(String playerName, int score, int playTimeInSeconds) {
    // Obtener la fecha actual
    String date = getFormattedDate();
    
    // Formatear el tiempo de juego
    String playtime = formatPlayTime(playTimeInSeconds);
    
    // Añadir el record
    addRecord(playerName, score, date, playtime);
  }
  
  // Obtener la fecha actual formateada
  String getFormattedDate() {
    // Obtener la fecha actual con formato YYYY-MM-DD
    return year() + "-" + nf(month(), 2) + "-" + nf(day(), 2);
  }
  
  // Formatear el tiempo de juego en formato MM:SS
  String formatPlayTime(int seconds) {
    int minutes = seconds / 60;
    int remainingSeconds = seconds % 60;
    return nf(minutes, 2) + ":" + nf(remainingSeconds, 2);
  }
  
  // Desplazar la lista hacia arriba
  void scrollUp() {
    if (scrollOffset > 0) {
      scrollOffset--;
    }
  }
  
  // Desplazar la lista hacia abajo
  void scrollDown() {
    if (scrollOffset < records.size() - visibleRecords) {
      scrollOffset++;
    }
  }
  
  // Dibujar la tabla de clasificación
  void display() {
    pushStyle();
    rectMode(CORNER);
    
    // Fondo semi-transparente para el popup
    // Usamos un alpha bajo para que se vea el fondo del juego o menú
    color bgColor = accessManager.getBackgroundColor(color(0, 0, 0, 120));
    fill(bgColor);
    rect(0, 0, width, height);
    
    // Panel de la tabla
    rectMode(CENTER);
    // Usando un color con alpha para que sea semi-transparente
    color panelColor = accessManager.getBackgroundColor(color(30, 30, 30, 220));
    fill(panelColor);
    stroke(accessManager.getTextColor(color(180, 180, 180, 200)));
    strokeWeight(2);
    
    // Tamaño del popup (más pequeño que la pantalla completa)
    float popupWidth = width * 0.7;
    float popupHeight = height * 0.7;
    rect(width/2, height/2, popupWidth, popupHeight, 15);
    
    // Título
    textAlign(CENTER, CENTER);
    textSize(accessManager.getAdjustedTextSize(32));
    fill(accessManager.getTextColor(color(255, 255, 150)));
    text("TABLA DE CLASIFICACIÓN", width/2, height/2 - popupHeight/2 + 40);
    
    // Encabezados de columnas
    float startX = width/2 - popupWidth/2 + 30;
    float endX = width/2 + popupWidth/2 - 30;
    float headerY = height/2 - popupHeight/2 + 80;
    float rowHeight = (popupHeight - 160) / visibleRecords;
    
    textSize(accessManager.getAdjustedTextSize(20));
    textAlign(LEFT, CENTER);
    fill(accessManager.getTextColor(color(200, 200, 200)));
    
    // Dividir el ancho total en columnas proporcionales
    float rankWidth = (endX - startX) * 0.15;
    float nameWidth = (endX - startX) * 0.35;
    float scoreWidth = (endX - startX) * 0.2;
    float dateWidth = (endX - startX) * 0.15;
    float timeWidth = (endX - startX) * 0.15;
    
    // Posiciones X para cada columna
    float rankX = startX;
    float nameX = rankX + rankWidth;
    float scoreX = nameX + nameWidth;
    float dateX = scoreX + scoreWidth;
    float timeX = dateX + dateWidth;
    
    // Encabezados
    text("POS", rankX + 10, headerY);
    text("JUGADOR", nameX + 10, headerY);
    text("PUNTOS", scoreX + 10, headerY);
    text("FECHA", dateX + 10, headerY);
    text("TIEMPO", timeX + 10, headerY);
    
    // Línea separadora bajo los encabezados
    stroke(accessManager.getTextColor(color(150, 150, 150)));
    strokeWeight(2);
    line(startX, headerY + rowHeight/2, endX, headerY + rowHeight/2);
    
    // Mostrar registros
    float startY = headerY + rowHeight;
    
    noStroke();
    int maxToDisplay = min(visibleRecords, records.size());
    
    for (int i = 0; i < maxToDisplay; i++) {
      int index = i + scrollOffset;
      if (index < records.size()) {
        LeaderboardRecord record = records.get(index);
        float rowY = startY + rowHeight * i;
        
        // Alternar colores de filas para mejor legibilidad con transparencia
        if (i % 2 == 0) {
          fill(accessManager.getBackgroundColor(color(40, 40, 40, 180)));
          rect(width/2, rowY, endX - startX, rowHeight);
        } else {
          fill(accessManager.getBackgroundColor(color(60, 60, 60, 180)));
          rect(width/2, rowY, endX - startX, rowHeight);
        }
        
        // Posición (con iconos para los 3 primeros)
        textAlign(LEFT, CENTER);
        textSize(accessManager.getAdjustedTextSize(18));
        
        // Color especial para los 3 primeros lugares
        if (index == 0) {
          fill(accessManager.getTextColor(color(255, 215, 0))); // Oro
        } else if (index == 1) {
          fill(accessManager.getTextColor(color(192, 192, 192))); // Plata
        } else if (index == 2) {
          fill(accessManager.getTextColor(color(205, 127, 50))); // Bronce
        } else {
          fill(accessManager.getTextColor(color(255)));
        }
        
        // Mostrar posición y posiblemente un icono
        String rankText = (index + 1) + "";
        text(rankText, rankX + 10, rowY);
        
        // Mostrar iconos para los 3 primeros lugares
        if (index < 3) {
          PImage icon = null;
          switch (index) {
            case 0: icon = goldIcon; break;
            case 1: icon = silverIcon; break;
            case 2: icon = bronzeIcon; break;
          }
          
          if (icon != null) {
            imageMode(CENTER);
            image(icon, rankX + 45, rowY, 22, 22);
          }
        }
        
        // Nombre del jugador
        text(record.playerName, nameX + 10, rowY);
        
        // Puntuación
        text(record.score + "", scoreX + 10, rowY);
        
        // Fecha
        text(record.date, dateX + 10, rowY);
        
        // Tiempo de juego
        text(record.playtime, timeX + 10, rowY);
      }
    }
    
    // Indicadores de desplazamiento (si hay más records que los visibles)
    if (records.size() > visibleRecords) {
      // Calcular posición y tamaño del "scrollbar"
      float scrollbarHeight = (popupHeight - 160) * ((float)visibleRecords / records.size());
      float scrollbarY = startY + ((popupHeight - 160) - scrollbarHeight) * ((float)scrollOffset / (records.size() - visibleRecords));
      
      // Dibujar fondo del scrollbar
      fill(accessManager.getBackgroundColor(color(80, 80, 80)));
      rect(endX + 15, startY + (popupHeight - 160)/2, 8, popupHeight - 160);
      
      // Dibujar "thumb" del scrollbar
      fill(accessManager.getTextColor(color(200, 200, 200)));
      rect(endX + 15, scrollbarY + scrollbarHeight/2, 8, scrollbarHeight);
      
      // Indicadores de flecha arriba/abajo
      textSize(accessManager.getAdjustedTextSize(18));
      textAlign(CENTER, CENTER);
      
      // Flecha arriba
      if (scrollOffset > 0) {
        text("▲", endX + 15, startY - 15);
      }
      
      // Flecha abajo
      if (scrollOffset < records.size() - visibleRecords) {
        text("▼", endX + 15, startY + (popupHeight - 160) + 15);
      }
    }
    
    // Botón para volver - usando la clase Button para consistencia con el menú principal
    // Actualizar posición del botón basada en el tamaño actual de la ventana popup
    // Super importante actualizar la posición en cada frame porque si la ventana cambia de tamaño,
    // queremos que el botón siga en el lugar correcto.
    backButton.x = width/2;
    backButton.y = height/2 + popupHeight/2 - 35;
    backButton.display();
    
    popStyle();
  }
  
  // Verificar si se hizo clic en el botón volver
  boolean checkBackButtonClick() {
    return backButton.isClicked();
  }
}

/**
 * Clase para representar un registro en la tabla de clasificación
 */
class LeaderboardRecord {
  String playerName;
  int score;
  String date;
  String playtime;
  
  LeaderboardRecord(String playerName, int score, String date, String playtime) {
    this.playerName = playerName;
    this.score = score;
    this.date = date;
    this.playtime = playtime;
  }
} 