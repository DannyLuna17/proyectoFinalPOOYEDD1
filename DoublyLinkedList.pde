/**
 * DoublyLinkedList.pde
 * Implementación de una lista doblemente enlazada.
 */

class Node<T> {
  T data;
  Node<T> next;
  Node<T> prev;
  
  // Constructor
  Node(T data) {
    this.data = data;
    this.next = null;
    this.prev = null;
  }
}

class DoublyLinkedList<T> {
  private Node<T> head;
  private Node<T> tail;
  private int size;
  
  // Constructor
  DoublyLinkedList() {
    this.head = null;
    this.tail = null;
    this.size = 0;
  }
  
  // Añadir al final de la lista
  void addLast(T data) {
    Node<T> newNode = new Node<T>(data);
    
    if (head == null) {
      // Lista vacía
      head = newNode;
      tail = newNode;
    } else {
      // Añadir al final
      tail.next = newNode;
      newNode.prev = tail;
      tail = newNode;
    }
    
    size++;
  }
  
  // Añadir al principio de la lista
  void addFirst(T data) {
    Node<T> newNode = new Node<T>(data);
    
    if (head == null) {
      // Lista vacía
      head = newNode;
      tail = newNode;
    } else {
      // Añadir al principio
      newNode.next = head;
      head.prev = newNode;
      head = newNode;
    }
    
    size++;
  }
  
  // Eliminar el primer elemento
  T removeFirst() {
    if (head == null) {
      return null; // Lista vacía
    }
    
    T data = head.data;
    
    if (head == tail) {
      // Solo hay un elemento
      head = null;
      tail = null;
    } else {
      // Más de un elemento
      head = head.next;
      head.prev = null;
    }
    
    size--;
    return data;
  }
  
  // Eliminar el último elemento
  T removeLast() {
    if (tail == null) {
      return null; // Lista vacía
    }
    
    T data = tail.data;
    
    if (head == tail) {
      // Solo hay un elemento
      head = null;
      tail = null;
    } else {
      // Más de un elemento
      tail = tail.prev;
      tail.next = null;
    }
    
    size--;
    return data;
  }
  
  // Obtener el primer elemento sin eliminarlo
  T getFirst() {
    return head == null ? null : head.data;
  }
  
  // Obtener el último elemento sin eliminarlo
  T getLast() {
    return tail == null ? null : tail.data;
  }
  
  // Comprobar si la lista está vacía
  boolean isEmpty() {
    return size == 0;
  }
  
  // Obtener el tamaño de la lista
  int size() {
    return size;
  }
  
  // Limpiar la lista
  void clear() {
    head = null;
    tail = null;
    size = 0;
  }
} 