//
//  Done.swift
//  memo
//
//  Created by Jongbum Lee on 2023/08/02.
//
import UIKit

class DoneViewController: UIViewController {
    
    private var tableView: UITableView!
    
    private var doneTodos: [TodoItem] {
        return UserDefaults.standard.getTodoList().filter { $0.isCompleted }
    }
    
    private var groupedDoneTodos: [String: [TodoItem]] {
        let items = doneTodos
        return Dictionary(grouping: items, by: { $0.category.rawValue })
    }
    
    private var sectionTitles: [String] {
        return groupedDoneTodos.keys.sorted()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        NotificationCenter.default.addObserver(self, selector: #selector(handleTodoItemDeleted), name: Notification.Name("TodoItemDeleted"), object: nil)
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "doneCell")
        view.addSubview(tableView)
    }
    
    @objc private func handleTodoItemDeleted() {
        tableView.reloadData()
    }
    
    private func configureCell(_ cell: UITableViewCell, with todo: TodoItem) {
        cell.textLabel?.text = todo.title
        cell.detailTextLabel?.text = "Category: \(todo.category.rawValue)"
    }
}

extension DoneViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = sectionTitles[section]
        return groupedDoneTodos[category]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "doneCell", for: indexPath)
        let category = sectionTitles[indexPath.section]
        if let todoItem = groupedDoneTodos[category]?[indexPath.row] {
            configureCell(cell, with: todoItem)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
}

// MARK: - UITableViewDelegate
extension DoneViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let todoDetailViewController = storyboard.instantiateViewController(withIdentifier: "TodoDetailViewController") as? TodoDetailViewController else { return }
        let category = sectionTitles[indexPath.section]
        todoDetailViewController.todoItem = groupedDoneTodos[category]?[indexPath.row]
        navigationController?.pushViewController(todoDetailViewController, animated: true)
    }
}


