//
//  Todo.swift
//  memo
//
//  Created by Jongbum Lee on 2023/08/02.
//

import UIKit
import CoreData

class TodoViewController: UIViewController {
    
    
    private var tableView: UITableView!
    private var viewModel: TodoViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = TodoViewModel()
        viewModel.dataDidUpdate = { [weak self] in
            self?.tableView.reloadData()
        }
        
        setupTableView()
        setupNavigationBar()
    }
    
    @objc private func addTodo() {
        let alert = UIAlertController(title: "Add Todo", message: "Enter details", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Title"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Category"
            let categoryPicker = UIPickerView()
            categoryPicker.delegate = self
            categoryPicker.dataSource = self
            textField.inputView = categoryPicker
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Due Date (YYYY/MM/DD)"
            
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.addTarget(self, action: #selector(self.datePickerChanged(_:)), for: .valueChanged)
            textField.inputView = datePicker
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let self = self,
                  let title = alert.textFields?.first?.text, !title.isEmpty,
                  let categoryText = alert.textFields?[1].text,
                  let dueDateString = alert.textFields?.last?.text,
                  let dueDate = self.viewModel.date(from: dueDateString) else { return }
            
            self.viewModel.addTask(title: title, dueDate: dueDate, category: categoryText)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func editTodo(at indexPath: IndexPath) {
        let task = viewModel.task(at: indexPath)
        
        let alert = UIAlertController(title: "Edit Todo", message: "Update details", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = task.title
        }
        alert.addTextField { (textField) in
            textField.text = task.category
        }
        alert.addTextField { (textField) in
            textField.text = self.viewModel.dateString(from: task.dueDate!)
        }
        
        let updateAction = UIAlertAction(title: "Update", style: .default) { [weak self] _ in
            guard let self = self,
                  let title = alert.textFields?.first?.text, !title.isEmpty,
                  let categoryText = alert.textFields?[1].text,
                  let dueDateString = alert.textFields?.last?.text,
                  let dueDate = self.viewModel.date(from: dueDateString) else { return }
            
            self.viewModel.updateTask(task: task, title: title, dueDate: dueDate, category: categoryText)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(updateAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "todoCell")
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "To-do List"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTodo))
    }
    
    @objc func datePickerChanged(_ sender: UIDatePicker) {
        if let alert = presentedViewController as? UIAlertController,
           let textField = alert.textFields?.last {
            textField.text = viewModel.dateString(from: sender.date)
        }
    }
}

extension TodoViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Category.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = Category.allCases[section]
        return viewModel.todos(in: category.rawValue).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath)
        
        let task = viewModel.task(at: indexPath)
        cell.textLabel?.text = task.title
        cell.detailTextLabel?.text = viewModel.dateString(from: task.dueDate!)
        
        if task.isCompleted {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Category.allCases[section].rawValue
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.toggleCompletion(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = viewModel.task(at: indexPath)
            viewModel.deleteTask(task: task)
        }
    }
}

extension TodoViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Category.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Category.allCases[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let alert = presentedViewController as? UIAlertController,
           let textField = alert.textFields?[1] {
            textField.text = Category.allCases[row].rawValue
        }
    }
}

