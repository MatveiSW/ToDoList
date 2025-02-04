//
//  CoreDataManager.swift
//  ToDoList
//
//  Created by Матвей Авдеев on 31.01.2025.
//


import CoreData
import UIKit

final class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {
        _ = persistentContainer
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ToDoList")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
        return container
    }()
    
    private var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    // MARK: - CRUD Operations
    func saveTodo(_ todo: Todo) {
        if !todoExists(withId: todo.id) && !isDeleted(todo.id) {
            let todoEntity = TodoEntity(context: context)
            todoEntity.id = Int64(todo.id)
            todoEntity.todo = todo.todo
            todoEntity.completed = todo.completed
            todoEntity.userId = Int64(todo.userId)
            todoEntity.title = todo.title
            todoEntity.dateCreated = todo.dateCreated
            
            saveContext()
        }
    }
    
    func saveTodos(_ todos: [Todo]) {
        todos.forEach { saveTodo($0) }
    }
    
    func fetchTodos() -> [Todo] {
        let fetchRequest: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
        
        do {
            let todoEntities = try context.fetch(fetchRequest)
            return todoEntities.map { Todo(
                id: Int($0.id),
                todo: $0.todo ?? "",
                completed: $0.completed,
                userId: Int($0.userId),
                dateCreated: $0.dateCreated,
                title: $0.title
            )}
        } catch {
            print("Error fetching todos: \(error)")
            return []
        }
    }
    
    func updateTodo(_ todo: Todo) {
        let fetchRequest: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", todo.id)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let todoEntity = results.first {
                todoEntity.completed = todo.completed
                todoEntity.todo = todo.todo
                todoEntity.title = todo.title
                todoEntity.dateCreated = todo.dateCreated
                saveContext()
            }
        } catch {
            print("Error updating todo: \(error)")
        }
    }
    
    func deleteTodo(_ todo: Todo) {
        let fetchRequest: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", todo.id)
        
        do {
            if let todoEntity = try context.fetch(fetchRequest).first {
                context.delete(todoEntity)
                addToDeleted(todo.id)
                saveContext()
            }
        } catch {
            print("Error deleting todo: \(error)")
        }
    }
    
    // MARK: - Deleted Todos Management
    private func addToDeleted(_ todoId: Int) {
        let deletedTodo = DeletedTodoEntity(context: context)
        deletedTodo.taskId = Int64(todoId)
        deletedTodo.deletedAt = Date()
        saveContext()
    }
    
    private func isDeleted(_ todoId: Int) -> Bool {
        let fetchRequest: NSFetchRequest<DeletedTodoEntity> = DeletedTodoEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "taskId == %d", todoId)
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Error checking deleted status: \(error)")
            return false
        }
    }
    
    private func todoExists(withId id: Int) -> Bool {
        let fetchRequest: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Error checking todo existence: \(error)")
            return false
        }
    }
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
}
