import Foundation

final class TodoViewModel {
    // MARK: - Properties
    private let networkManager = NetworkManager.shared
    private let coreDataManager = CoreDataManager.shared
    
    // MARK: - Completion Handler Type
    typealias TodosCompletion = (Result<[Todo], Error>) -> Void
    
    // MARK: - Public Methods
    func fetchTodos(completion: @escaping TodosCompletion) {
        // Сначала возвращаем локальные данные
        let localTodos = coreDataManager.fetchTodos()
        if !localTodos.isEmpty {
            completion(.success(localTodos))
        }
        
        // В любом случае проверяем обновления с сервера
        networkManager.fetchTodos { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                // Модифицируем данные
                let modifiedTodos = response.todos.map { todo in
                    var modifiedTodo = todo
                    modifiedTodo.title = "My task"
                    modifiedTodo.dateCreated = self.generateRandomDate()
                    return modifiedTodo
                }
                
                // Сохраняем в CoreData (существующие и неудаленные задачи не будут дублироваться)
                self.coreDataManager.saveTodos(modifiedTodos)
                
                // Получаем обновленный список задач из CoreData
                let updatedTodos = self.coreDataManager.fetchTodos()
                if !localTodos.isEmpty {
                    // Если это обновление данных, отправляем новый результат только если есть изменения
                    if updatedTodos != localTodos {
                        completion(.success(updatedTodos))
                    }
                } else {
                    // Если это первая загрузка, отправляем результат в любом случае
                    completion(.success(updatedTodos))
                }
                
            case .failure(let error):
                // Сообщаем об ошибке только если у нас нет локальных данных
                if localTodos.isEmpty {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func updateTodoStatus(todo: Todo, completion: @escaping (Result<Todo, Error>) -> Void) {
        var updatedTodo = todo
        updatedTodo.completed.toggle()
        
        // Обновляем в CoreData
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
        // Обновляем в CoreData
        coreDataManager.updateTodo(todo)
        completion(.success(todo))
    }
    
    func deleteTodo(_ todo: Todo, completion: @escaping (Result<Void, Error>) -> Void) {
        // Удаляем из CoreData
        coreDataManager.deleteTodo(todo)
        completion(.success(()))
    }
    
    // Добавьте этот метод в класс TodoViewModel
    func saveTodo(_ todo: Todo, completion: @escaping (Result<Todo, Error>) -> Void) {
        // Сохраняем в CoreData
        coreDataManager.saveTodo(todo)
        completion(.success(todo))
    }
}
