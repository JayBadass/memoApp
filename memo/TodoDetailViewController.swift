//
//  DetailViewController.swift
//  memo
//
//  Created by Jongbum Lee on 2023/08/10.
//

import UIKit

class TodoDetailViewController: UIViewController {
    var todoItem: TodoItem?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var dueDateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonTapped(_:)))
        let deleteButton = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(deleteButtonTapped(_:)))
        
        navigationItem.rightBarButtonItems = [editButton, deleteButton]
    }
    
    private func updateUI() {
        updateData()
        print("Updating UI...")
        nameLabel.text = todoItem?.title
        segmentedControl.selectedSegmentIndex = todoItem?.isCompleted ?? false ? 1 : 0
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        if let dueDate = todoItem?.dueDate {
            dueDateLabel.text = dateFormatter.string(from: dueDate)
        }
    }
    
    private func updateData() {
        for (index, item) in globalTodoList.enumerated() {
            if item.id == todoItem?.id {
                todoItem?.title = globalTodoList[index].title
                todoItem?.dueDate = globalTodoList[index].dueDate
            } else {
            }
        }
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Edit Todo", message: "Edit the details of your todo.", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.text = self.todoItem?.title
        }
        
        alertController.addTextField { textField in
            textField.placeholder = "Due Date"
            let datePicker = UIDatePicker()
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.addTarget(self, action: #selector(self.datePickerValueChanged(sender:)), for: .valueChanged)
            if let dueDate = self.todoItem?.dueDate {
                datePicker.date = dueDate
            }
            textField.inputView = datePicker
        }
        
        let editAction = UIAlertAction(title: "Edit", style: .default) { [weak self] _ in
            print("Title from alert: \(alertController.textFields?.first?.text ?? "N/A")")
            print("Due date from alert: \(alertController.textFields?.last?.text ?? "N/A")")
            guard let self = self, let todoItem = self.todoItem else { return }
            let title = alertController.textFields?.first?.text
            let dueDateString = alertController.textFields?.last?.text
            print(title!)
            print(dueDateString!)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
            guard let dueDate = dateFormatter.date(from: dueDateString ?? "") else { return }
            
            print("Searching for todoItem with ID: \(todoItem.id)")
            for (index, item) in globalTodoList.enumerated() {
                if item.id == todoItem.id {
                    print("Found matching ID at index: \(index)")
                    globalTodoList[index].title = title ?? ""
                    globalTodoList[index].dueDate = dueDate
                    print("Updated todoItem: \(globalTodoList[index])")
                } else {
                    print("No match at index \(index), ID: \(item.id)")
                }
            }
            self.updateUI()
        }
        
        alertController.addAction(editAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }
    
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        if let alert = presentedViewController as? UIAlertController,
           let textField = alert.textFields?.last {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
            textField.text = dateFormatter.string(from: sender.date)
        }
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Delete", message: "Are you sure you want to delete this todo?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self, let todoItem = self.todoItem else { return }
            globalTodoList.removeAll { $0.id == todoItem.id } // 전역 할 일 목록에서 삭제
            NotificationCenter.default.post(name: Notification.Name("TodoItemDeleted"), object: nil)
            self.navigationController?.popViewController(animated: true) // 상세 화면 닫기
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }
}

