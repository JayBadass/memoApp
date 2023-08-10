//
//  Todo.swift
//  memo
//
//  Created by Jongbum Lee on 2023/08/02.
//

import UIKit

class TodoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTodo))
        
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "todoCell")
        
        view.addSubview(tableView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return globalTodoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath)
        
        let todo = globalTodoList[indexPath.row]
        cell.textLabel?.text = todo.title
        cell.accessoryType = todo.isCompleted ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        globalTodoList[indexPath.row].isCompleted.toggle()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        if let alert = presentedViewController as? UIAlertController,
           let textField = alert.textFields?.last {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
            textField.text = dateFormatter.string(from: sender.date)
        }
    }
    
    @objc func doneDatePicker(alert: UIAlertController) {
        if let textField = alert.textFields?[1],
           let datePicker = textField.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
            textField.text = dateFormatter.string(from: datePicker.date)
            textField.resignFirstResponder()
        }
    }
    
    @objc func addTodo() {
        let alert = UIAlertController(title: "Add Todo", message: "Enter the details of your new todo.", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Todo Title"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Due Date"
            let datePicker = UIDatePicker()
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.addTarget(self, action: #selector(self.datePickerValueChanged(sender:)), for: .valueChanged)
            textField.inputView = datePicker
        }
        
        
        let action = UIAlertAction(title: "Add", style: .default) { [unowned self, alert] _ in
            guard let title = alert.textFields?.first?.text, !title.isEmpty,
                  let dueDateTextField = alert.textFields?.last?.text else { return }
            
            // dateString을 Date로 변환하기 (물론, 올바른 형식이어야 함)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
            guard let dueDate = dateFormatter.date(from: dueDateTextField) else { return }
            
            let todo = TodoItem(id: globalTodoList.count, title: title, isCompleted: false, dueDate: dueDate)
            globalTodoList.append(todo)
            self.tableView.reloadData()
        }
        
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
}





