//
//  Done.swift
//  memo
//
//  Created by Jongbum Lee on 2023/08/02.
//

import UIKit
import CoreData

class DoneViewController: UIViewController {
    
    private var tableView: UITableView!
    private var doneTodos: [Task] {
        return CoreDataHelper.shared.readCompletedTasks()
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
    
    private func configureCell(_ cell: UITableViewCell, with task: Task) {
        cell.textLabel?.text = task.title
        // 기타 Task 객체의 속성을 활용하여 셀을 구성하세요.
    }
}

extension DoneViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return doneTodos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "doneCell", for: indexPath)
        let task = doneTodos[indexPath.row]
        configureCell(cell, with: task)
        return cell
    }
}

extension DoneViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let todoDetailViewController = storyboard.instantiateViewController(withIdentifier: "TodoDetailViewController") as? TodoDetailViewController else { return }
        todoDetailViewController.todoItem = doneTodos[indexPath.row]
        navigationController?.pushViewController(todoDetailViewController, animated: true)
    }
}
