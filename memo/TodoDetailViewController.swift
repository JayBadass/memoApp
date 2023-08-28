//
//  DetailViewController.swift
//  memo
//
//  Created by Jongbum Lee on 2023/08/10.
//

import UIKit

class TodoDetailViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    var todoItem: TodoItem?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var dueDateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonTapped))
        let deleteButton = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(deleteButtonTapped))
        navigationItem.rightBarButtonItems = [editButton, deleteButton]
        
        updateUI()
    }
    
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
               let textField = alert.textFields?.last {
                textField.text = Category.allCases[row].rawValue
            }
        }
    
    private func updateUI() {
        nameLabel.text = todoItem?.title
        segmentedControl.selectedSegmentIndex = todoItem?.isCompleted ?? false ? 1 : 0
        categoryLabel.text = "Category: \(todoItem?.category.rawValue ?? "")"
        
        if let dueDate = todoItem?.dueDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            dueDateLabel.text = dateFormatter.string(from: dueDate)
        }
    }

    @objc private func editButtonTapped(_ sender: Any) {
        showEditAlert()
    }
    
    private func showEditAlert() {
        let alertController = UIAlertController(title: "Edit Todo", message: "Edit the details of your todo.", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.text = self.todoItem?.title
        }
        
        alertController.addTextField { textField in
            self.setupDatePicker(for: textField)
        }
        
        alertController.addTextField { textField in
            textField.text = self.todoItem?.category.rawValue
            let pickerView = UIPickerView()
            pickerView.delegate = self
            pickerView.dataSource = self
            if let index = Category.allCases.firstIndex(where: { $0 == self.todoItem?.category }) {
                pickerView.selectRow(index, inComponent: 0, animated: false)
            }
            textField.inputView = pickerView
        }
        
        let editAction = UIAlertAction(title: "Edit", style: .default) { _ in
            self.handleEditAction(in: alertController)
        }
        
        alertController.addAction(editAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }
    
    private func setupDatePicker(for textField: UITextField) {
        textField.placeholder = "Due Date"
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(sender:)), for: .valueChanged)
        if let dueDate = todoItem?.dueDate {
            datePicker.date = dueDate
        }
        textField.inputView = datePicker
    }
    
    private func handleEditAction(in alertController: UIAlertController) {
        let title = alertController.textFields?.first?.text
        let dueDateString = alertController.textFields?.last?.text
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        guard let dueDate = dateFormatter.date(from: dueDateString ?? "") else { return }
        
        for (index, item) in globalTodoList.enumerated() {
            if item.id == todoItem?.id {
                globalTodoList[index].title = title ?? ""
                globalTodoList[index].dueDate = dueDate
            }
        }
        UserDefaults.standard.setTodoList(globalTodoList)
        updateUI()
    }
    
    @objc private func datePickerValueChanged(sender: UIDatePicker) {
        if let alert = presentedViewController as? UIAlertController,
           let textField = alert.textFields?.last {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
            textField.text = dateFormatter.string(from: sender.date)
        }
    }
    
    @objc private func deleteButtonTapped(_ sender: Any) {
        showDeleteAlert()
    }
    
    private func showDeleteAlert() {
        let alertController = UIAlertController(title: "Delete", message: "Are you sure you want to delete this todo?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.handleDeleteAction()
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }
    
    private func handleDeleteAction() {
        guard let todoItem = self.todoItem else { return }
        globalTodoList.removeAll { $0.id == todoItem.id }
        UserDefaults.standard.setTodoList(globalTodoList)
        NotificationCenter.default.post(name: Notification.Name("TodoItemDeleted"), object: nil)
        navigationController?.popViewController(animated: true)
    }
}
