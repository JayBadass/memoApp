//
//  Done.swift
//  memo
//
//  Created by Jongbum Lee on 2023/08/02.
//
import UIKit

class DoneViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var tableView: UITableView!
    
    private var doneTodos: [TodoItem] {
        return UserDefaults.standard.getTodoList().filter { $0.isCompleted }
    }
    
    private var categories: [Category] {
        return Category.allCases
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        NotificationCenter.default.addObserver(self, selector: #selector(handleTodoItemDeleted), name: Notification.Name("TodoItemDeleted"), object: nil)
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "doneCell")
        view.addSubview(tableView)
    }
    
    @objc private func handleTodoItemDeleted() {
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return doneTodos.filter { $0.category == categories[section] }.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let category = categories[section]
        return doneTodos.filter { $0.category == category }.isEmpty ? nil : category.rawValue
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "doneCell", for: indexPath)
        
        let category = categories[indexPath.section]
        let todosForCategory = doneTodos.filter { $0.category == category }
        let todo = todosForCategory[indexPath.row]
        
        cell.textLabel?.text = todo.title
        cell.detailTextLabel?.text = "Category: \(todo.category.rawValue)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let todoDetailViewController = storyboard.instantiateViewController(withIdentifier: "TodoDetailViewController") as? TodoDetailViewController else { return }
        
        let category = categories[indexPath.section]
        let todosForCategory = doneTodos.filter { $0.category == category }
        let todo = todosForCategory[indexPath.row]
        
        todoDetailViewController.todoItem = todo
        navigationController?.pushViewController(todoDetailViewController, animated: true)
    }
}

