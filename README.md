# EcoRunner - Proyecto Final POO y Estructura de Datos I

## Integrantes
- Danny Luna Quintana
- Daniel Monterroza
- Fabian Miranda
- Gabriel Mosquera

## Descripción
EcoRunner es un juego endless runner educativo sobre el cambio climático, donde controlas a un personaje que debe evitar obstáculos mientras recolecta objetos para mejorar el ecosistema y obtener puntos.

## Requisitos
- Processing 3 o superior
- Para la intro de video: Biblioteca Video de Processing
- Para los gif animados: Biblioteca GifAnimation de Processing
- Para los sonidos: Biblioteca Minim de Processing

## Instalación
1. Clona o descarga este repositorio
2. Abre el archivo `proyFinalPOO.pde` con Processing
3. - Abre Processing > Sketch > Import Library > Add Library...
   - Instala las biblioteca "Video", "GifAnimation" y "Minim" de The Processing Foundation
   - Reinicia Processing
   
Si la biblioteca de Video no está instalada, el juego funcionará correctamente pero utilizará una imagen estática en lugar de la introducción animada.

## Controles del juego

### Controles básicos
- **ESPACIO**: Saltar (mantén pulsado para saltar más alto)
- **P**: Pausar el juego
- **R**: Reiniciar (cuando el juego termina)
- **ESC**: Volver o salir (dependiendo del contexto)

### Controles de plataformas
- **ESPACIO** (en plataforma): Saltar entre plataformas (salto más potente)

### Controles de menú
- **Flechas** o **WASD**: Navegar por las opciones
- **ENTER** o **ESPACIO**: Seleccionar opción
- **ESC**: Volver al menú anterior

### Modo de depuración
- **1**: Activar/desactivar visualización de cajas de colisión.

## Mecánicas del juego



### Tipos de plataformas
- **Estándar**: Plataformas normales de color marrón
- **Rebote**: Plataformas verdes que te impulsan automáticamente hacia arriba
- **Móviles verticales**: Plataformas que se mueven arriba y abajo

### Coleccionables y power-ups
Durante el juego, podrás recolectar diferentes ítems:
- **Puntos**: Aumentan tu puntuación
- **Escudo**: Te protege de un impacto
- **Velocidad**: Aumenta temporalmente tu velocidad
- **Corazones**: Recuperan salud perdida
- **Doble puntos**: Multiplica por 2 los puntos que consigas

### Sistema de ecosistema
A medida que juegas, tus acciones afectan a un ecosistema virtual:
- Recolectar ítems mejora la salud del ecosistema
- Chocar con obstáculos contamina el ecosistema
- El estado del ecosistema afecta al clima y a tus habilidades

## Opciones de accesibilidad
El juego incluye varias opciones para mejorar la accesibilidad:

- **Alto contraste**: Mejora la visibilidad usando colores con mayor contraste
- **Modo daltónico**: Usa una paleta de colores diseñada para personas con deficiencias en la visión de colores
- **Navegación por teclado**: Permite navegar todos los menús usando únicamente el teclado

Estas opciones se pueden activar desde el menú de configuración.

## Consejos

1. Mantén pulsado espacio para saltar más alto
2. Las plataformas verdes te dan un impulso extra al saltar
3. El escudo te protege de un obstáculo.
4. Aprende los patrones de los obstáculos para mejorar tu puntuación
5. Recoge todos los coleccionables que puedas para mejorar el ecosistema

