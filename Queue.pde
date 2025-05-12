/**
 * Queue.pde
 * Implementación de una Cola (Queue) usando una lista doblemente enlazada.
 */

class Queue<T> {
  private DoublyLinkedList<T> list;
  
  // Constructor
  Queue() {
    list = new DoublyLinkedList<T>();
  }
  
  /**
   * Añade un elemento al final de la cola.
   */
  void enqueue(T data) {
    list.addLast(data);
  }
  
  /**
   * Elimina y devuelve el elemento del frente de la cola.
   * Retorna null si la cola está vacía.
   */
  T dequeue() {
    return list.removeFirst();
  }
  
  /**
   * Devuelve el elemento del frente sin eliminarlo.
   * Tiempo de ejecución: O(1)
   * Retorna null si la cola está vacía.
   */
  T peek() {
    return list.getFirst();
  }
  
  /**
   * Comprueba si la cola está vacía.
   */
  boolean isEmpty() {
    return list.isEmpty();
  }
  
  /**
   * Devuelve el número de elementos en la cola.
   */
  int size() {
    return list.size();
  }
  
  /**
   * Elimina todos los elementos de la cola.
   */
  void clear() {
    list.clear();
  }
} 