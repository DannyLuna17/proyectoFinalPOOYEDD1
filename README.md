# EcoRunner - Proyecto Final POO

### IMPORTANTE

## Nota
Crear una carpta llamada proyFinalPOO, ahí inicializar el repo y ejecutar.

## Requisitos para la intro de video

Para que funcione la intro animada, hay que instalar la biblioteca Video:

1. Abre Processing
2. Ve a Sketch > Import Library > Add Library...
3. Busca "Video"
4. Instala la biblioteca "Video" de The Processing Foundation
5. Reinicia Processing si hace falta

Si no está instalada, el juego usa el menú normal sin la intro.

## Testing

### Atajos

- **T**: Ejecuta tests automáticos
- **D**: Cambia opciones de debug
- **L**: Muestra los logs

### Opciones de debug

- Cajas de colisión: Muestra hitboxes
- Métricas: Muestra FPS y memoria
- Debug del eco-sistema: Muestra estado detallado
- Validación: Activa validación automática

El juego incluye tests automáticos para comprobar que todo funciona bien y un sistema de debug para detectar errores:

1. **Tests**: Verifica las mecánicas básicas
2. **Debug visual**: Muestra hitboxes, métricas, etc.
3. **Manejo de errores**: Evita crashes
4. **Validación**: Comprueba que todo esté bien
5. **Logs**: Con varios niveles

## Framework de testing

### TestFramework

La clase `TestFramework` tiene tests para:

- Movimiento y salto del jugador
- Colisiones con obstáculos y coleccionables
- Power-ups y sus efectos
- Eco-sistema y sus estados
- Puntuación

### DebugSystem

La clase `DebugSystem` tiene herramientas para:

- Ver FPS y memoria
- Ver hitboxes
- Ver estado del eco-sistema
- Sistema de logs
- Validación de estados

### TestRunner

La clase `TestRunner` integra todo:

- Teclas para ejecutar tests
- Muestra resultados
- Maneja errores

### Niveles de log

Hay cuatro niveles:

1. ERROR: Problemas graves
2. WARNING: Problemas menores
3. INFO: Información general
4. DEBUG: Información detallada

## Manejo de errores

El framework:

1. Captura excepciones
2. Intenta recuperarse
3. Evita crashes
4. Muestra errores visualmente
5. Mantiene la integridad del juego

## Consejos

1. Usa la tecla **D** para ver opciones de debug
2. Usa la tecla **L** para ver logs
3. Ejecuta tests con **T** para comprobar si todo funciona
4. Mira la consola para errores detallados

