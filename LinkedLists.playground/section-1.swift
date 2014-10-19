import Foundation

class Node <T: Equatable> {
    var value: T?
    var next: Node?
}

class LinkedList <T: Equatable> {
    var head: Node <T>?
    
    func insertAtHead(value: T) {
        var newHead = Node<T>()
        newHead.value = value
        
        if let formerHead = self.head {
            newHead.next = formerHead
        }
        
        self.head = newHead
    }
    
    func insertAtEnd(value: T) {
        if let headNode = self.head {
            
            var currentNode = headNode
            while let nextNode = currentNode.next {
                currentNode = nextNode
            }
            
            var node = Node<T>()
            node.value = value
            node.next = nil
            
            currentNode.next = node
            
        } else {
            var node = Node<T>()
            node.value = value
            node.next = nil
            self.head = node
        }
    }
    
    func removeNodeWithValue(value: T) {
        if let headNode = self.head {
            
            var previousNode: Node<T>?
            var currentNode = headNode
            while let currentNodeValue = currentNode.value {
                if currentNodeValue == value {
                    if let nextNode = currentNode.next {
                        if previousNode == nil {
                            self.head = nextNode
                        } else {
                            previousNode!.next = nextNode
                        }
                    } else {
                        if previousNode == nil {
                            self.head = nil
                        } else {
                            previousNode!.next = nil
                        }
                    }
                    
                    if previousNode == nil {
                        
                    }
                    
                    break
                } else {
                    if let nextNode = currentNode.next {
                        previousNode = currentNode
                        currentNode = nextNode
                    } else {
                        println("Node with value of \(value) not found")
                        break
                    }
                }
            }
            
        } else {
            println("List is empty")
        }
    }
    
    func printNodes() {
        if let headNode = self.head {
            self.printNodesRecursively(headNode)
        }
    }
    
    private func printNodesRecursively(node: Node<T>) {
        if let value = node.value {
            println("\(value)")
        }
        
        if let nextNode = node.next {
            self.printNodesRecursively(nextNode)
        } else {
            println("End of linked list")
        }
    }
}

let linkedList1 = LinkedList<Int>()

linkedList1.removeNodeWithValue(1)

println("")

linkedList1.insertAtEnd(1)
linkedList1.insertAtEnd(2)
linkedList1.insertAtEnd(3)
linkedList1.insertAtEnd(4)
linkedList1.insertAtEnd(5)
linkedList1.printNodes()

println("")

linkedList1.removeNodeWithValue(1)
linkedList1.removeNodeWithValue(3)
linkedList1.removeNodeWithValue(5)
linkedList1.printNodes()

println("")

linkedList1.removeNodeWithValue(7)

println("")

let linkedList2 = LinkedList<String>()

linkedList2.insertAtHead("a")
linkedList2.insertAtHead("b")
linkedList2.insertAtHead("c")
linkedList2.insertAtHead("d")
linkedList2.insertAtHead("e")
linkedList2.printNodes()

println("")

linkedList2.removeNodeWithValue("c")
linkedList2.printNodes()





