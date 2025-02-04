//
//  ViewController.swift
//  ToDoList
//
//  Created by Матвей Авдеев on 31.01.2025.
//

import UIKit

final class MainViewController: UIViewController {
    // MARK: - Properties
    private let mainView = MainView()
    private let viewModel = TodoViewModel()
    private var todos: [Todo] = []
    private var filteredTodos: [Todo] = []
    private var isSearching = false
    
    // MARK: - Lifecycle
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true 
        setupTableView()
        setupSearchBar()
        setupTapGesture()
        setupAddButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTodos()
    }
    
    // MARK: - Setup
    private func setupTableView() {
        mainView.tableView.delegate = self
        mainView.tableView.dataSource = self
    }
    
    private func setupSearchBar() {
        mainView.searchBar.delegate = self
    }
    
    private func setupAddButton() {
        mainView.addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false // Позволяет обрабатывать тапы по ячейкам
        mainView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func addButtonTapped() {
        let newTaskVC = NewTaskViewController()
        navigationController?.pushViewController(newTaskVC, animated: true)
    }
    
    // MARK: - Data Loading
    private func loadTodos() {
        viewModel.fetchTodos { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let todos):
                    self?.todos = todos
                    self?.mainView.tableView.reloadData()
                    self?.mainView.updateTaskCount(todos.count)
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isSearching ? filteredTodos.count : todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as? MainTableViewCell else {
            return UITableViewCell()
        }
        
        let todo = isSearching ? filteredTodos[indexPath.row] : todos[indexPath.row]
        cell.configure(with: todo)
        
        cell.onCheckmarkTap = { [weak self] in
            self?.viewModel.updateTodoStatus(todo: todo) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let updatedTodo):
                        if let index = self?.todos.firstIndex(where: { $0.id == updatedTodo.id }) {
                            self?.todos[index] = updatedTodo
                        }
                        if let filteredIndex = self?.filteredTodos.firstIndex(where: { $0.id == updatedTodo.id }) {
                            self?.filteredTodos[filteredIndex] = updatedTodo
                        }
                        tableView.reloadRows(at: [indexPath], with: .automatic)
                    case .failure(let error):
                        print("Error updating todo: \(error)")
                    }
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let todo = isSearching ? filteredTodos[indexPath.row] : todos[indexPath.row]
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: {
            let previewController = UIViewController()
            let previewView = MainTableViewCell(style: .default, reuseIdentifier: nil)
            previewView.configure(with: todo)
            previewView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 100)
            
            previewView.selectionStyle = .none
            previewView.backgroundColor = .clear
            previewView.contentView.backgroundColor = .clear
            
            let containerView = UIView(frame: previewView.frame)
            containerView.backgroundColor = .black
            containerView.addSubview(previewView)
            
            previewController.view = containerView
            previewController.view.backgroundColor = .black
            previewController.preferredContentSize = previewView.frame.size
            return previewController
            
        }) { [weak self] _ in
            let edit = UIAction(title: "Редактировать", image: UIImage(systemName: "pencil")) { _ in
                self?.editTodo(todo)
            }
            
            let share = UIAction(title: "Поделиться", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                self?.shareTodo(todo)
            }
            
            let delete = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), 
                                attributes: .destructive) { _ in
                self?.deleteTodo(todo, at: indexPath)
            }
            
            return UIMenu(title: "", children: [edit, share, delete])
        }
    }
    
    // Отключаем подсветку при тапе
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // Отключаем выделение
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
}

// MARK: - UISearchBarDelegate
extension MainViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredTodos = []
        } else {
            isSearching = true
            filteredTodos = viewModel.searchTodos(query: searchText)
        }
        mainView.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        isSearching = false
        filteredTodos = []
        mainView.tableView.reloadData()
    }
}

// MARK: - Context Menu Actions
private extension MainViewController {
    func editTodo(_ todo: Todo) {
        let newTaskVC = NewTaskViewController(todo: todo)
        navigationController?.pushViewController(newTaskVC, animated: true)
    }
    
    func shareTodo(_ todo: Todo) {
        // Создаем текст для шаринга
        let shareText = "Задача: \(todo.todo)"
        
        let activityViewController = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        // Для iPad
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(activityViewController, animated: true)
    }
    
    func deleteTodo(_ todo: Todo, at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "Удалить задачу?",
            message: "Это действие нельзя будет отменить",
            preferredStyle: .alert
        )
        
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            // Сначала удаляем из локального массива
            if self.isSearching {
                self.filteredTodos.remove(at: indexPath.row)
                if let index = self.todos.firstIndex(where: { $0.id == todo.id }) {
                    self.todos.remove(at: index)
                }
            } else {
                self.todos.remove(at: indexPath.row)
            }
            
            // Обновляем UI
            self.mainView.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.mainView.updateTaskCount(self.todos.count)
            
            // Затем удаляем из CoreData
            self.viewModel.deleteTodo(todo) { result in
                switch result {
                case .success:
                    break // UI уже обновлен
                case .failure(let error):
                    print("Error deleting todo: \(error)")
                    // Можно добавить восстановление удаленной задачи в случае ошибки
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

