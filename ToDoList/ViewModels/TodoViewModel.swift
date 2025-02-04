import Foundation

final class TodoViewModel {
    private let networkManager = NetworkManager.shared
    private let coreDataManager = CoreDataManager.shared
    
    typealias TodosCompletion = (Result<[Todo], Error>) -> Void
    
    func fetchTodos(completion: @escaping TodosCompletion) {
        let localTodos = coreDataManager.fetchTodos()
        if !localTodos.isEmpty {
            completion(.success(localTodos))
        }
        
        networkManager.fetchTodos { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                let modifiedTodos = response.todos.map { todo in
                    var modifiedTodo = todo
                    modifiedTodo.title = "My task"
                    modifiedTodo.dateCreated = self.generateRandomDate()
                    return modifiedTodo
                }
                
                self.coreDataManager.saveTodos(modifiedTodos)
                
                let updatedTodos = self.coreDataManager.fetchTodos()
                if !localTodos.isEmpty {
                    if updatedTodos != localTodos {
                        completion(.success(updatedTodos))
                    }
                } else {
                    completion(.success(updatedTodos))
                }
                
            case .failure(let error):
                if localTodos.isEmpty {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func updateTodoStatus(todo: Todo, completion: @escaping (Result<Todo, Error>) -> Void) {
        var updatedTodo = todo
        updatedTodo.completed.toggle()
        
        coreDataManager.updateTodo(updatedTodo)
        completion(.success(updatedTodo))
    }
    
    func searchTodos(query: String) -> [Todo] {
        let todos = coreDataManager.fetchTodos()
        guard !query.isEmpty else { return todos }
        
        return todos.filter { todo in
            todo.todo.lowercased().contains(query.lowercased()) ||
            (todo.title?.lowercased().contains(query.lowercased()) ?? false)
        }
    }
    
    private func generateRandomDate() -> Date {
        let calendar = Calendar.current
        let currentDate = Date()
        
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)),
              let startOfNextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) else {
            return currentDate
        }
        
        let randomInterval = TimeInterval.random(in: startOfMonth.timeIntervalSince1970...startOfNextMonth.timeIntervalSince1970)
        return Date(timeIntervalSince1970: randomInterval)
    }
    
    func updateTodo(_ todo: Todo, completion: @escaping (Result<Todo, Error>) -> Void) {
        coreDataManager.updateTodo(todo)
        completion(.success(todo))
    }
    
    func deleteTodo(_ todo: Todo, completion: @escaping (Result<Void, Error>) -> Void) {
        coreDataManager.deleteTodo(todo)
        completion(.success(()))
    }
    
    func saveTodo(_ todo: Todo, completion: @escaping (Result<Todo, Error>) -> Void) {
        coreDataManager.saveTodo(todo)
        completion(.success(todo))
    }
}
