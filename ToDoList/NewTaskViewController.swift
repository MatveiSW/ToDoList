//
//  NewTaskViewController.swift
//  ToDoList
//
//  Created by Матвей Авдеев on 04.02.2025.
//

import UIKit

final class NewTaskViewController: UIViewController {
    private let newTaskView = NewTaskView()
    private let viewModel = TodoViewModel()
    private var existingTodo: Todo?
    private var isTaskSaved = false
    
    init(todo: Todo? = nil) {
        self.existingTodo = todo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = newTaskView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        if let todo = existingTodo {
            setupExistingTodo(todo)
        }
    }
    
    private func setupView() {
        navigationController?.isNavigationBarHidden = true
        
        newTaskView.onBackButtonTap = { [weak self] in
            self?.handleBackButton()
        }
        
        newTaskView.onDoneButtonTap = { [weak self] in
            self?.handleDoneButton()
        }
    }
    
    private func setupExistingTodo(_ todo: Todo) {
        var text = todo.title ?? ""
        if !todo.todo.isEmpty {
            text += "\n\(todo.todo)"
        }
        newTaskView.setText(text)
    }
    
    private func handleBackButton() {
        if newTaskView.hasChanges && !isTaskSaved {
            saveTask()
        }
        navigationController?.popViewController(animated: true)
    }
    
    private func handleDoneButton() {
        if newTaskView.hasChanges && !isTaskSaved {
            saveTask()
        }
        view.endEditing(true)
    }
    
    private func saveTask() {
        guard let title = newTaskView.taskTitle else { return }
        
        if let existingTodo = existingTodo {
            var updatedTodo = existingTodo
            updatedTodo.title = title
            updatedTodo.todo = newTaskView.taskDescription ?? ""
            
            viewModel.updateTodo(updatedTodo) { [weak self] result in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        self?.isTaskSaved = true
                    }
                case .failure(let error):
                    print("Error updating task: \(error)")
                }
            }
        } else {
            let newTodo = Todo(
                id: Int(Date().timeIntervalSince1970),
                todo: newTaskView.taskDescription ?? "",
                completed: false,
                userId: 1,
                dateCreated: Date(),
                title: title
            )
            
            viewModel.saveTodo(newTodo) { [weak self] result in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        self?.isTaskSaved = true
                        self?.existingTodo = newTodo
                    }
                case .failure(let error):
                    print("Error saving task: \(error)")
                }
            }
        }
    }
}
