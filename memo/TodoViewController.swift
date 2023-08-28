//
//  Todo.swift
//  memo
//
//  Created by Jongbum Lee on 2023/08/02.
//

import UIKit

class TodoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    private var tableView: UITableView!
    
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = Category.allCases[section]
        return todos(in: category).count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Category.allCases.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Category.allCases[section].rawValue
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath)
        let cateogory = Category.allCases[indexPath.section]
        let todo = todos(in: cateogory)[indexPath.row]
        configureCell(cell, with: todo)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let category = Category.allCases[section]
        let count = todos(in: category).count
        return "\(count) tasks in this category"
    }
    
    func todos(in category: Category) -> [TodoItem] {
        return globalTodoList.filter { $0.category == category }
    }
    
    private func configureCell(_ cell: UITableViewCell, with todo: TodoItem) {
        cell.textLabel?.text = todo.title
        cell.accessoryType = todo.isCompleted ? .checkmark : .none
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = Category.allCases[indexPath.section]
        let todoIndex = globalTodoList.firstIndex { $0.id == todos(in: category)[indexPath.row].id }
        if let index = todoIndex {
            globalTodoList[index].isCompleted.toggle()
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)    }
    
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
    
    
    @objc private func addTodo() {
        let alert = UIAlertController(title: "Add Todo", message: "Enter the details of your new todo.", preferredStyle: .alert)
        
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
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self, alert] _ in
            self?.addActionHandler(alert: alert)
        }
        
        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func datePickerValueChanged(sender: UIDatePicker) {
        if let alert = presentedViewController as? UIAlertController,
           let textField = alert.textFields?.last {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
            textField.text = dateFormatter.string(from: sender.date)
        }
    }
    
    private func addActionHandler(alert: UIAlertController) {
        guard let title = alert.textFields?.first?.text, !title.isEmpty,
              let categoryText = alert.textFields?[1].text,
              let category = Category(rawValue: categoryText),
              let dueDateTextField = alert.textFields?.last?.text else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        guard let dueDate = dateFormatter.date(from: dueDateTextField) else { return }
        
        let todo = TodoItem(id: globalTodoList.count, title: title, isCompleted: false, dueDate: dueDate, category: category)
        globalTodoList.append(todo)
        UserDefaults.standard.setTodoList(globalTodoList)
        tableView.reloadData()
    }
}
