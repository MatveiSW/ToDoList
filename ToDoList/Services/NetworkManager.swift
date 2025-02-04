//
//  NetworkManager.swift
//  ToDoList
//
//  Created by Матвей Авдеев on 31.01.2025.
//

import UIKit

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
}

final class NetworkManager {
    
    static let shared = NetworkManager()
    
    private let queue = DispatchQueue(label: "com.todolist.networkQueue", qos: .userInitiated, attributes: .concurrent)
    
    private init() {}
    
    func fetchTodos(completion: @escaping (Result<TodoResponse, NetworkError>) -> Void) {
        queue.async {
            guard let url = URL(string: "https://dummyjson.com/todos") else {
                completion(.failure(.invalidURL))
                return
            }
            
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data,
                      let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(.invalidResponse))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let todos = try decoder.decode(TodoResponse.self, from: data)
                    completion(.success(todos))
                } catch {
                    completion(.failure(.decodingError))
                }
            }
            task.resume()
        }
    }
}

