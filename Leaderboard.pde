/**
 * Leaderboard.pde
 * 
 * Sistema de clasificación que muestra los mejores puntajes de los jugadores.
 * Permite visualizar los 20 mejores puntajes ordenados de mayor a menor.
 */
class Leaderboard {
  // Pila de records para la tabla de clasificación (usamos Stack en lugar de ArrayList)
  Stack<LeaderboardRecord> records;
  
  // Propiedades de visualización
  int maxRecordsToShow = 20;
  int visibleRecords = 10; // Cantidad de registros visibles sin desplazamiento
  int scrollOffset = 0; // Desplazamiento actual para mostrar más registros
  
  // Archivo para almacenamiento persistente
  String leaderboardFile = "leaderboard.txt";
  
  // Variables para el scrollbar
  boolean isDraggingScrollbar = false; // Para saber si estamos arrastrando el scrollbar
  float scrollbarMouseOffset = 0; // Offset del mouse relativo al scrollbar cuando empezamos a arrastrar
  float lastMouseY = 0; // Última posición Y del mouse para calcular movimiento
  
  // Iconos para los 3 primeros lugares
  PImage goldIcon;
  PImage silverIcon;
  PImage bronzeIcon;
  
  // Referencias a otras clases necesarias
  AccessibilityManager accessManager;
  AssetManager assetManager;
  
  // Botón para volver - usando la misma clase Button del menú principal
  Button backButton;
  
  // Coordenadas del scrollbar para detección de mouse (se actualizan en display())
  float scrollbarX, scrollbarY, scrollbarWidth, scrollbarHeight;
  float scrollAreaHeight, scrollAreaStartY;
  float arrowUpY, arrowDownY;
  
  // Constructor
  Leaderboard(AccessibilityManager accessManager, AssetManager assetManager) {
    this.accessManager = accessManager;
    this.assetManager = assetManager;
    records = new Stack<LeaderboardRecord>();
    
    // Inicializar botón de continuar
    backButton = new Button(width/2, height/2 + (height * 0.7)/2 - 35, 180, 45, "CONTINUAR", accessManager);
    
    // Cargar datos del archivo antes de generar datos de ejemplo
    loadLeaderboardData();
    
    // Solo generar datos de ejemplo si no se cargaron datos del archivo
    loadIcons();
    if (records.isEmpty()) {
      generateSampleData();
    }
  }
  
  // Cargar datos del leaderboard desde el archivo
  void loadLeaderboardData() {
    try {
      // Intentar cargar el archivo de texto
      String[] lines = loadStrings(leaderboardFile);
      
      if (lines != null && lines.length > 0) {
        println("Cargando " + lines.length + " registros del leaderboard...");
        
        for (String line : lines) {
          // Saltar líneas vacías
          if (line.trim().length() == 0) continue;
          
          // Dividir la línea por comas (formato CSV prácticamente)
          String[] parts = split(line.trim(), ',');
          
          // Verificar que tenga los 4 campos esperados
          if (parts.length == 4) {
            try {
              String playerName = parts[0].trim();
              int score = Integer.parseInt(parts[1].trim());
              String date = parts[2].trim();
              String playtime = parts[3].trim();
              
              // Validar que los campos no estén vacíos
              if (playerName.length() > 0 && date.length() > 0 && playtime.length() > 0 && score >= 0) {
                // Crear y añadir el record usando push() en lugar de add()
                LeaderboardRecord record = new LeaderboardRecord(playerName, score, date, playtime);
                records.push(record);
              } else {
                println("Registro con datos inválidos ignorado: " + line);
              }
            } catch (NumberFormatException e) {
              println("Error al parsear puntuación en línea: " + line);
            } catch (Exception e) {
              println("Error inesperado al procesar línea: " + line + " - " + e.getMessage());
            }
          } else {
            println("Línea con formato incorrecto ignorada: " + line);
          }
        }
        
        // Ordenar y limitar después de cargar todos los records
        sortRecords();
        trimRecords();
        
        println("Leaderboard cargado exitosamente con " + records.size() + " registros.");
      } else {
        println("Archivo de leaderboard vacío o no encontrado. Iniciando con lista vacía.");
      }
    } catch (Exception e) {
      println("Error al cargar leaderboard: " + e.getMessage());
      println("Iniciando con leaderboard vacío.");
      records.clear(); // Asegurar que la pila esté vacía en caso de error
    }
  }
  
  // Guardar datos del leaderboard al archivo
  void saveLeaderboardData() {
    try {
      // Obtener records ordenados para guardar en el orden correcto
      Stack<LeaderboardRecord> sortedRecords = getSortedRecords();
      Stack<LeaderboardRecord> tempStack = new Stack<LeaderboardRecord>();
      ArrayList<String> lines = new ArrayList<String>();
      
      // Convertir cada record a string en formato CSV
      while (!sortedRecords.isEmpty()) {
        LeaderboardRecord record = sortedRecords.pop();
        tempStack.push(record); // Guardar para no perder los datos
        
        // Formato: nombre,puntuación,fecha,tiempo
        String line = record.playerName + "," + record.score + "," + record.date + "," + record.playtime;
        lines.add(line);
      }
      
      // Convertir ArrayList a array para saveStrings()
      String[] linesArray = lines.toArray(new String[lines.size()]);
      
      // Guardar al archivo sobrescribiendo el contenido anterior
      saveStrings(leaderboardFile, linesArray);
      println("Leaderboard guardado exitosamente con " + records.size() + " registros.");
      
    } catch (Exception e) {
      println("Error al guardar leaderboard: " + e.getMessage());
    }
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
      records.push(new LeaderboardRecord("Player1", 10000, "2023-12-01", "10:25"));
      records.push(new LeaderboardRecord("Player2", 8500, "2023-12-02", "08:15"));
      records.push(new LeaderboardRecord("Player3", 7200, "2023-12-03", "12:40"));
      records.push(new LeaderboardRecord("Player4", 6800, "2023-12-04", "05:30"));
      records.push(new LeaderboardRecord("Player5", 5500, "2023-12-05", "14:20"));
      
      // Ordenar los datos de ejemplo
      sortRecords();
      trimRecords();
    }
  }
  
  // Método auxiliar para buscar un record por nombre (case-insensitive)
  // Devuelve el índice del record si lo encuentra, -1 si no existe
  int findRecordByName(String playerName) {
    for (int i = 0; i < getRecordsSize(); i++) {
      LeaderboardRecord record = getRecordAt(i);
      if (record != null && record.playerName.equalsIgnoreCase(playerName)) {
        return i; // Encontramos el record, devolvemos su posición
      }
    }
    return -1; // No se encontró el record
  }
  
  // Método auxiliar para actualizar un record existente en una posición específica
  // Esto es necesario porque Stack no tiene un método directo para actualizar por índice
  void updateRecordAt(int index, String playerName, int score, String date, String playtime) {
    // Crear una lista temporal con todos los records ordenados
    Stack<LeaderboardRecord> sortedStack = getSortedRecords();
    ArrayList<LeaderboardRecord> tempList = new ArrayList<LeaderboardRecord>();
    
    // Convertir el stack a lista para poder modificar por índice
    while (!sortedStack.isEmpty()) {
      tempList.add(sortedStack.pop());
    }
    
    // Actualizar el record en la posición especificada
    if (index >= 0 && index < tempList.size()) {
      LeaderboardRecord updatedRecord = new LeaderboardRecord(playerName, score, date, playtime);
      tempList.set(index, updatedRecord);
    }
    
    // Limpiar el stack original y rebuildearlo con los datos actualizados
    records.clear();
    for (int i = tempList.size() - 1; i >= 0; i--) {
      records.push(tempList.get(i));
    }
  }
  
  // Añadir un nuevo record a la tabla (con manejo de nombres duplicados)
  void addRecord(String playerName, int score, String date, String playtime) {
    // Limitar nombre a 14 caracteres
    if (playerName.length() > 14) {
      playerName = playerName.substring(0, 14);
    }
    
    // Limpiar el nombre del jugador para evitar problemas con el formato CSV
    // Remover comas y caracteres que puedan romper el formato
    playerName = playerName.replace(",", "").replace("\n", "").replace("\r", "");
    
    // Si el nombre queda vacío después de la limpieza, usar un nombre por defecto
    if (playerName.trim().length() == 0) {
      playerName = "Jugador";
    }
    
    // Buscar si ya existe un record con este nombre (case-insensitive)
    int existingIndex = findRecordByName(playerName);
    
    if (existingIndex != -1) {
      // El nombre ya existe, verificar si el nuevo score es mejor
      LeaderboardRecord existingRecord = getRecordAt(existingIndex);
      
      if (score > existingRecord.score) {
        // El nuevo score es mejor, actualizar el record existente
        // Preservamos la capitalización original del nombre del record existente
        updateRecordAt(existingIndex, existingRecord.playerName, score, date, playtime);
        println("🎉 ¡Nuevo record! " + existingRecord.playerName + ": " + existingRecord.score + " → " + score + " puntos");
      } else {
        // El nuevo score es igual o menor, no hacer nada
        println("💭 " + existingRecord.playerName + " ya tiene un score mejor (" + existingRecord.score + " vs " + score + ")");
        return; // Salir sin hacer cambios
      }
    } else {
      // El nombre no existe, crear un nuevo record normalmente
      LeaderboardRecord record = new LeaderboardRecord(playerName, score, date, playtime);
      records.push(record);
      println("✨ Nuevo jugador en el leaderboard: " + playerName + " con " + score + " puntos");
    }
    
    // Ordenar la lista de mayor a menor según puntuación
    sortRecords();
    
    // Mantener solo los mejores 20 registros
    trimRecords();
    
    // Guardar automáticamente los cambios al archivo
    saveLeaderboardData();
  }
  
  // Ordenar los registros por puntuación (de mayor a menor)
  void sortRecords() {
    // Convertir stack a lista temporal para ordenar
    ArrayList<LeaderboardRecord> tempList = new ArrayList<LeaderboardRecord>();
    
    // Sacar todos los elementos del stack
    while (!records.isEmpty()) {
      tempList.add(records.pop());
    }
    
    // Ordenar la lista (mayor a menor puntuación)
    Collections.sort(tempList, (a, b) -> b.score - a.score);
    
    // Volver a meter los elementos en el stack (en orden inverso para mantener el orden correcto)
    for (int i = tempList.size() - 1; i >= 0; i--) {
      records.push(tempList.get(i));
    }
  }
  
  // Mantener solo los mejores 20 registros
  void trimRecords() {
    if (records.size() > maxRecordsToShow) {
      // Obtener records ordenados
      Stack<LeaderboardRecord> sortedRecords = getSortedRecords();
      Stack<LeaderboardRecord> tempStack = new Stack<LeaderboardRecord>();
      
      // Guardar solo los primeros maxRecordsToShow elementos
      int count = 0;
      while (!sortedRecords.isEmpty() && count < maxRecordsToShow) {
        tempStack.push(sortedRecords.pop());
        count++;
      }
      
      // Limpiar el stack original y restaurar los records que queremos mantener
      records.clear();
      while (!tempStack.isEmpty()) {
        records.push(tempStack.pop());
      }
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
    if (scrollOffset < getRecordsSize() - visibleRecords) {
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
    float popupHeight = height * 0.75;
    rect(width/2, height/2, popupWidth, popupHeight + 55, 15);
    
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
    int maxToDisplay = min(visibleRecords, getRecordsSize());
    
    for (int i = 0; i < maxToDisplay; i++) {
      int index = i + scrollOffset;
      if (index < getRecordsSize()) {
        LeaderboardRecord record = getRecordAt(index);
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
    if (getRecordsSize() > visibleRecords) {
      // Calcular dimensiones del scrollbar
      float scrollAreaHeight = popupHeight - 160;
      float scrollbarWidth = 12; 
      float scrollbarX = endX + 12;
      
      // Calcular altura y posición del "thumb" del scrollbar
      float scrollbarHeight = scrollAreaHeight * ((float)visibleRecords / getRecordsSize());
      float maxScrollOffset = getRecordsSize() - visibleRecords;
      float scrollbarY = startY + (scrollAreaHeight - scrollbarHeight) * ((float)scrollOffset / maxScrollOffset);
      
      // Dibujar el fondo del área de scroll (track)
      fill(accessManager.getBackgroundColor(color(60, 60, 60, 180)));
      stroke(accessManager.getTextColor(color(100, 100, 100)));
      strokeWeight(1);
      rect(scrollbarX, startY + scrollAreaHeight/2, scrollbarWidth, scrollAreaHeight, 6);
      
      // Determinar el color del thumb basado en si está siendo hover o arrastrado
      boolean mouseOverScrollbar = isMouseOverScrollbar(scrollbarX, scrollbarY, scrollbarWidth, scrollbarHeight);
      color thumbColor;
      
      if (isDraggingScrollbar) {
        thumbColor = accessManager.getTextColor(color(255, 255, 255)); // Blanco cuando se arrastra
      } else if (mouseOverScrollbar) {
        thumbColor = accessManager.getTextColor(color(220, 220, 220)); // Gris claro en hover
      } else {
        thumbColor = accessManager.getTextColor(color(180, 180, 180)); // Gris normal
      }
      
      // Dibujar el "thumb" del scrollbar con efecto visual
      fill(thumbColor);
      stroke(accessManager.getTextColor(color(120, 120, 120)));
      strokeWeight(1);
      rect(scrollbarX, scrollbarY + scrollbarHeight/2, scrollbarWidth - 2, scrollbarHeight, 5);
      
      // Dibujar botones de flecha arriba y abajo con área clickeable
      noStroke();
      textSize(accessManager.getAdjustedTextSize(14));
      textAlign(CENTER, CENTER);
      
      // Área del botón de arriba
      float arrowUpY = startY - 20;
      boolean mouseOverArrowUp = mouseX >= scrollbarX - 8 && mouseX <= scrollbarX + 8 && 
                                mouseY >= arrowUpY - 8 && mouseY <= arrowUpY + 8;
      
      if (scrollOffset > 0) {
        fill(mouseOverArrowUp ? accessManager.getTextColor(color(255, 255, 255)) : 
                               accessManager.getTextColor(color(200, 200, 200)));
        text("▲", scrollbarX, arrowUpY);
      }
      
      // Área del botón de abajo
      float arrowDownY = startY + scrollAreaHeight + 20;
      boolean mouseOverArrowDown = mouseX >= scrollbarX - 8 && mouseX <= scrollbarX + 8 && 
                                  mouseY >= arrowDownY - 8 && mouseY <= arrowDownY + 8;
      
      if (scrollOffset < maxScrollOffset) {
        fill(mouseOverArrowDown ? accessManager.getTextColor(color(255, 255, 255)) : 
                                 accessManager.getTextColor(color(200, 200, 200)));
        text("▼", scrollbarX, arrowDownY);
      }
      
      // Guardar las coordenadas del scrollbar para uso en los métodos de mouse
      this.scrollbarX = scrollbarX;
      this.scrollbarY = scrollbarY;
      this.scrollbarWidth = scrollbarWidth;
      this.scrollbarHeight = scrollbarHeight;
      this.scrollAreaHeight = scrollAreaHeight;
      this.scrollAreaStartY = startY;
      this.arrowUpY = arrowUpY;
      this.arrowDownY = arrowDownY;
    }
    
    // Botón para volver - usando la clase Button para consistencia con el menú principal
    // Actualizar posición del botón basada en el tamaño actual de la ventana popup
    // Super importante actualizar la posición en cada frame porque si la ventana cambia de tamaño,
    // queremos que el botón siga en el lugar correcto.
    backButton.x = width/2;
    backButton.y = height/2 + popupHeight/2 - 10;
    backButton.display();
    
    popStyle();
  }
  
  // Verificar si se hizo clic en el botón volver
  boolean checkBackButtonClick() {
    return backButton.isClicked();
  }
  
  // Verificar si el mouse está sobre el thumb del scrollbar
  boolean isMouseOverScrollbar(float scrollbarX, float scrollbarY, float scrollbarWidth, float scrollbarHeight) {
    return mouseX >= scrollbarX - scrollbarWidth/2 && mouseX <= scrollbarX + scrollbarWidth/2 &&
           mouseY >= scrollbarY && mouseY <= scrollbarY + scrollbarHeight;
  }
  
  // Manejar el click del mouse en el área del leaderboard
  void handleMousePressed() {
    if (getRecordsSize() <= visibleRecords) return; 
    
    // Verificar si se hizo click en las flechas
    if (mouseX >= scrollbarX - 8 && mouseX <= scrollbarX + 8) {
      if (mouseY >= arrowUpY - 8 && mouseY <= arrowUpY + 8 && scrollOffset > 0) {
        scrollUp();
        return;
      }
      if (mouseY >= arrowDownY - 8 && mouseY <= arrowDownY + 8 && scrollOffset < getRecordsSize() - visibleRecords) { 
        scrollDown();
        return;
      }
    }
    
    // Verificar si se hizo click en el thumb del scrollbar
    if (isMouseOverScrollbar(scrollbarX, scrollbarY, scrollbarWidth, scrollbarHeight)) {
      isDraggingScrollbar = true;
      scrollbarMouseOffset = mouseY - scrollbarY;
      lastMouseY = mouseY;
      return;
    }
    
    // Verificar si se hizo click en el área del track (para saltar páginas)
    if (mouseX >= scrollbarX - scrollbarWidth/2 && mouseX <= scrollbarX + scrollbarWidth/2 &&
        mouseY >= scrollAreaStartY && mouseY <= scrollAreaStartY + scrollAreaHeight) {
      
      // Click arriba del thumb = página arriba
      if (mouseY < scrollbarY) {
        scrollOffset = max(0, scrollOffset - visibleRecords);
      }
      // Click abajo del thumb = página abajo  
      else if (mouseY > scrollbarY + scrollbarHeight) {
        scrollOffset = min(getRecordsSize() - visibleRecords, scrollOffset + visibleRecords); 
      }
    }
  }
  
  // Manejar cuando se suelta el mouse
  void handleMouseReleased() {
    isDraggingScrollbar = false;
    scrollbarMouseOffset = 0;
  }
  
  // Manejar el arrastre del mouse
  void handleMouseDragged() {
    if (!isDraggingScrollbar || getRecordsSize() <= visibleRecords) return; 
    
    // Calcular nueva posición del scrollbar basada en el movimiento del mouse
    float newScrollbarY = mouseY - scrollbarMouseOffset;
    
    // Limitar la posición del scrollbar al área válida
    float minScrollbarY = scrollAreaStartY;
    float maxScrollbarY = scrollAreaStartY + scrollAreaHeight - scrollbarHeight;
    newScrollbarY = constrain(newScrollbarY, minScrollbarY, maxScrollbarY);
    
    // Convertir la posición del scrollbar a offset de scroll
    float scrollPercentage = (newScrollbarY - minScrollbarY) / (maxScrollbarY - minScrollbarY);
    int maxScrollOffset = getRecordsSize() - visibleRecords; 
    scrollOffset = round(scrollPercentage * maxScrollOffset);
    scrollOffset = constrain(scrollOffset, 0, maxScrollOffset);
  }
  
  // Manejar la rueda del mouse para scroll suave
  void handleMouseWheel(float wheelDirection) {
    if (getRecordsSize() <= visibleRecords) return; 
    
    // wheelDirection es positivo cuando se rueda hacia arriba, negativo hacia abajo
    if (wheelDirection > 0) {
      scrollUp();
    } else if (wheelDirection < 0) {
      scrollDown();
    }
  }
  
  // Método auxiliar para convertir Stack a lista temporal ordenada para operaciones complejas
  // Esto nos permite mantener la funcionalidad de ordenamiento sin perder la estructura de Stack
  Stack<LeaderboardRecord> getSortedRecords() {
    // Crear lista temporal para ordenar
    ArrayList<LeaderboardRecord> tempList = new ArrayList<LeaderboardRecord>();
    Stack<LeaderboardRecord> tempStack = new Stack<LeaderboardRecord>();
    
    // Sacar todos los elementos del stack original
    while (!records.isEmpty()) {
      LeaderboardRecord record = records.pop();
      tempList.add(record);
      tempStack.push(record); // Guardar para restaurar después
    }
    
    // Restaurar el stack original
    while (!tempStack.isEmpty()) {
      records.push(tempStack.pop());
    }
    
    // Ordenar la lista temporal (mayor a menor puntuación)
    Collections.sort(tempList, (a, b) -> b.score - a.score);
    
    // Crear stack ordenado y devolverlo
    Stack<LeaderboardRecord> sortedStack = new Stack<LeaderboardRecord>();
    // Añadir en orden inverso para que el mayor quede arriba del stack
    for (int i = tempList.size() - 1; i >= 0; i--) {
      sortedStack.push(tempList.get(i));
    }
    
    return sortedStack;
  }
  
  // Método auxiliar para obtener un record por posición (similar al get de ArrayList)
  // Necesario para mantener la funcionalidad de display y scrolling
  LeaderboardRecord getRecordAt(int index) {
    Stack<LeaderboardRecord> sortedStack = getSortedRecords();
    Stack<LeaderboardRecord> tempStack = new Stack<LeaderboardRecord>();
    LeaderboardRecord result = null;
    
    // Sacar elementos hasta llegar al índice deseado
    int currentIndex = 0;
    while (!sortedStack.isEmpty() && currentIndex <= index) {
      LeaderboardRecord record = sortedStack.pop();
      tempStack.push(record);
      
      if (currentIndex == index) {
        result = record;
      }
      currentIndex++;
    }
    
    return result;
  }
  
  // Método auxiliar para obtener el tamaño del stack (equivalente a size())
  int getRecordsSize() {
    return records.size();
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
