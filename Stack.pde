/**
 * Stack.pde
 * Implementación de una Pila (Stack) usando una lista doblemente enlazada.
 */

class Stack<T> {
  private DoublyLinkedList<T> list;
  
  // Constructor
  Stack() {
    list = new DoublyLinkedList<T>();
  }
  
  /**
   * Añade un elemento a la cima de la pila.
   */
  void push(T data) {
    list.addFirst(data);
  }
  
  /**
   * Elimina y devuelve el elemento de la cima de la pila.
   * Retorna null si la pila está vacía.
   */
  T pop() {
    return list.removeFirst();
  }
  
  /**
   * Devuelve el elemento de la cima sin eliminarlo.
   * Retorna null si la pila está vacía.
   */
  T peek() {
    return list.getFirst();
  }
  
  /**
   * Comprueba si la pila está vacía.
   */
  boolean isEmpty() {
    return list.isEmpty();
  }
  
  /**
   * Devuelve el número de elementos en la pila.
   */
  int size() {
    return list.size();
  }
  
  /**
   * Elimina todos los elementos de la pila.
   */
  void clear() {
    list.clear();
  }
} 