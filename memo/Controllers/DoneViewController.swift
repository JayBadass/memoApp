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
    private var viewModel: DoneViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = DoneViewModel()
        viewModel.dataDidUpdate = { [weak self] in
            self?.tableView.reloadData()
        }
        
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
}

extension DoneViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "doneCell", for: indexPath)
        let task = viewModel.task(at: indexPath)
        cell.textLabel?.text = task.title
        return cell
    }
}

extension DoneViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let todoDetailViewController = storyboard.instantiateViewController(withIdentifier: "TodoDetailViewController") as? TodoDetailViewController else { return }
        todoDetailViewController.todoItem = viewModel.task(at: indexPath)
        navigationController?.pushViewController(todoDetailViewController, animated: true)
    }
}
