//
//  Task.swift
//  ToDoList
//
//  Created by Матвей Авдеев on 31.01.2025.
//

import UIKit

struct Todo: Codable, Equatable {
    let id: Int
    var todo: String
    var completed: Bool
    let userId: Int
    var dateCreated: Date?
    var title: String?
    
    // MARK: - Equatable
    static func == (lhs: Todo, rhs: Todo) -> Bool {
        return lhs.id == rhs.id &&
               lhs.todo == rhs.todo &&
               lhs.completed == rhs.completed &&
               lhs.userId == rhs.userId &&
               lhs.dateCreated == rhs.dateCreated &&
               lhs.title == rhs.title
    }
}

struct TodoResponse: Codable {
    let todos: [Todo]
    let total: Int
    let skip: Int
    let limit: Int
}
