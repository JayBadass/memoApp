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
    
    private var todoList: [Task] {
        get {
            CoreDataHelper.shared.fetchTasks()
        }
        set {
            tableView.reloadData()
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBar()
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "todoCell")
        view.addSubview(tableView)
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTodo))
    }
    
    @objc private func addTodo() {
        let alert = UIAlertController(title: "Add Todo", message: "Enter the details of your new todo.", preferredStyle: .alert)
        setupAlertFields(for: alert)
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            self?.addActionHandler(alert: alert)
        }
        
        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func addActionHandler(alert: UIAlertController) {
        guard let title = alert.textFields?.first?.text, !title.isEmpty,
              let categoryText = alert.textFields?[1].text,
              let dueDateString = alert.textFields?.last?.text,
              let dueDate = dateFormatter.date(from: dueDateString) else { return }
        
        _ = CoreDataHelper.shared.createTask(title: title, dueDate: dueDate, category: categoryText)
        todoList = CoreDataHelper.shared.fetchTasks() // Refresh the todoList after adding
    }
}

// MARK: - UITableView Delegate & DataSource
extension TodoViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Category.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = Category.allCases[section]
        return todos(in: category.rawValue).count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Category.allCases[section].rawValue
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath)
        let category = Category.allCases[indexPath.section]
        let todo = todos(in: category.rawValue)[indexPath.row]
        configureCell(cell, with: todo)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let category = Category.allCases[section]
        let count = todos(in: category.rawValue).count
        return "\(count) tasks in this category"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = Category.allCases[indexPath.section]
        let tasksInCategory = todoList.filter { $0.category == category.rawValue }
        guard tasksInCategory.indices.contains(indexPath.row) else { return }
        
        let task = tasksInCategory[indexPath.row]
        task.isCompleted.toggle()
        _ = CoreDataHelper.shared.saveContext()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }


    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completionHandler) in
            let todo = self?.todoList[indexPath.row]
            if let todo = todo {
                _ = CoreDataHelper.shared.deleteTask(todo)
                self?.todoList = CoreDataHelper.shared.fetchTasks() // Refresh the todoList after deleting
            }
            completionHandler(true)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (_, _, completionHandler) in
            self?.editTodo(at: indexPath)
            completionHandler(true)
        }
        
        editAction.backgroundColor = .systemBlue
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return configuration
    }
    
    private func editTodo(at indexPath: IndexPath) {
        let category = Category.allCases[indexPath.section]
        let tasksInCategory = CoreDataHelper.shared.fetchTasks().filter { $0.category == category.rawValue }
        guard tasksInCategory.indices.contains(indexPath.row) else { return }
        
        let task = tasksInCategory[indexPath.row]
        let alert = UIAlertController(title: "Edit Todo", message: "Update your todo details.", preferredStyle: .alert)
        setupAlertFields(for: alert, with: task)
        
        let updateAction = UIAlertAction(title: "Update", style: .default) { [weak self] _ in
            self?.updateActionHandler(alert: alert, with: task)
        }
        alert.addAction(updateAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    func setupAlertFields(for alert: UIAlertController, with todo: Task? = nil) {
        alert.addTextField { textField in
            textField.placeholder = "Todo Title"
            textField.text = todo?.title
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Category"
            let categoryPicker = UIPickerView()
            categoryPicker.delegate = self
            categoryPicker.dataSource = self
            if let categoryString = todo?.category,
               let categoryValue = Category(rawValue: categoryString),
               let index = Category.allCases.firstIndex(of: categoryValue) {
                categoryPicker.selectRow(index, inComponent: 0, animated: false)
                textField.text = categoryValue.rawValue
            }
            textField.inputView = categoryPicker
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Due Date"
            let datePicker = UIDatePicker()
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.addTarget(self, action: #selector(self.datePickerValueChanged(sender:)), for: .valueChanged)
            if let date = todo?.dueDate {
                datePicker.date = date
                textField.text = self.dateFormatter.string(from: date)
            }
            textField.inputView = datePicker
        }
    }
    
    private func updateActionHandler(alert: UIAlertController, with task: Task) {
        guard let title = alert.textFields?.first?.text, !title.isEmpty,
              let categoryText = alert.textFields?[1].text,
              let dueDateString = alert.textFields?.last?.text,
              let dueDate = dateFormatter.date(from: dueDateString) else { return }
        
        task.title = title
        task.dueDate = dueDate
        task.category = categoryText
        _ = CoreDataHelper.shared.updateTask(task, with: title)
        todoList = CoreDataHelper.shared.fetchTasks()
        tableView.reloadData()
    }
    
    func todos(in category: String) -> [Task] {
        return todoList.filter { $0.category == category }
    }
    
    private func configureCell(_ cell: UITableViewCell, with task: Task) {
        cell.textLabel?.text = task.title
        cell.accessoryType = task.isCompleted ? .checkmark : .none
    }
}

// MARK: - UIPickerView Delegate & DataSource
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

// MARK: - UIAlertController setup
private extension TodoViewController {
    
    func setupAlertFields(for alert: UIAlertController) {
        alert.addTextField { textField in
            textField.placeholder = "Todo Title"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Category"
            let categoryPicker = UIPickerView()
            categoryPicker.delegate = self
            categoryPicker.dataSource = self
            textField.inputView = categoryPicker
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Due Date"
            let datePicker = UIDatePicker()
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.addTarget(self, action: #selector(self.datePickerValueChanged(sender:)), for: .valueChanged)
            textField.inputView = datePicker
        }
    }
    
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        if let alert = presentedViewController as? UIAlertController,
           let textField = alert.textFields?.last {
            textField.text = dateFormatter.string(from: sender.date)
        }
    }
}
