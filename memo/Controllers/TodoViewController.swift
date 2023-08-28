//
//  Todo.swift
//  memo
//
//  Created by Jongbum Lee on 2023/08/02.
//

import UIKit

class TodoViewController: UIViewController {
    
    private var tableView: UITableView!
    private var todoList: [TodoItem] {
        get {
            UserDefaults.standard.getTodoList()
        }
        set {
            UserDefaults.standard.setTodoList(newValue)
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
              let category = Category(rawValue: categoryText),
              let dueDateString = alert.textFields?.last?.text,
              let dueDate = dateFormatter.date(from: dueDateString) else { return }
        
        let todo = TodoItem(id: todoList.count, title: title, isCompleted: false, dueDate: dueDate, category: category)
        todoList.append(todo)
    }
}

// MARK: - UITableView Delegate & DataSource
extension TodoViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Category.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = Category.allCases[section]
        return todos(in: category).count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Category.allCases[section].rawValue
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath)
        let category = Category.allCases[indexPath.section]
        let todo = todos(in: category)[indexPath.row]
        configureCell(cell, with: todo)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let category = Category.allCases[section]
        let count = todos(in: category).count
        return "\(count) tasks in this category"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = Category.allCases[indexPath.section]
        if let index = todoList.firstIndex(where: { $0.id == todos(in: category)[indexPath.row].id }) {
            todoList[index].isCompleted.toggle()
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func todos(in category: Category) -> [TodoItem] {
        return todoList.filter { $0.category == category }
    }
    
    private func configureCell(_ cell: UITableViewCell, with todo: TodoItem) {
        cell.textLabel?.text = todo.title
        cell.accessoryType = todo.isCompleted ? .checkmark : .none
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
