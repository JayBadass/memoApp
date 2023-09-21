//
//  DetailViewController.swift
//  memo
//
//  Created by Jongbum Lee on 2023/08/10.
//

import UIKit
import CoreData

class TodoDetailViewController: UIViewController {
    
    var todoItem: Task?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var dueDateLabel: UILabel!
    
    var viewModel: TodoDetailViewModel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let item = todoItem {
            viewModel = TodoDetailViewModel(todoItem: item)
        }
        
        viewModel.dataDidUpdate = { [weak self] in
            self?.updateUI()
        }
    }
    
    private func setupNavigationBar() {
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonTapped))
        let deleteButton = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(deleteButtonTapped))
        navigationItem.rightBarButtonItems = [editButton, deleteButton]
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension TodoDetailViewController {
    
    @objc private func updateUI() {
        nameLabel.text = viewModel.title
        segmentedControl.selectedSegmentIndex = viewModel.isCompleted ? 1 : 0
        categoryLabel.text = "Category: \(viewModel.category)"
        dueDateLabel.text = formattedDate(viewModel.dueDate)
    }
    
    private func formattedDate(_ date: Date?) -> String? {
        guard let date = date else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        return dateFormatter.string(from: date)
    }
}

extension TodoDetailViewController {
    
    @objc private func editButtonTapped(_ sender: Any) {
        showEditAlert()
    }
    
    private func handleEditAction(in alertController: UIAlertController) {
        let title = alertController.textFields?[0].text
        let dueDateString = alertController.textFields?[1].text
        let categoryString = alertController.textFields?[2].text
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let dueDate = dateFormatter.date(from: dueDateString ?? "")
        
        viewModel.handleEditAction(title: title, dueDate: dueDate, category: categoryString)
    }
    
    @objc private func deleteButtonTapped(_ sender: Any) {
        if let todoItem = self.todoItem {
            _ = CoreDataHelper.shared.deleteTask(todoItem)
            NotificationCenter.default.post(name: Notification.Name("TodoItemDeleted"), object: nil)
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func handleDeleteAction() {
        viewModel.handleDeleteAction()
        navigationController?.popViewController(animated: true)
    }
    
}

extension TodoDetailViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
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
        if let activeTextField = UIResponder.currentFirst as? UITextField {
            activeTextField.text = Category.allCases[row].rawValue
        }
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
            textField.text = self.todoItem?.category
            let pickerView = UIPickerView()
            pickerView.delegate = self
            pickerView.dataSource = self
            if let index = Category.allCases.firstIndex(where: { $0.rawValue == self.todoItem?.category }) {
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
    
    private func showDeleteAlert() {
        let alertController = UIAlertController(title: "Delete", message: "Are you sure you want to delete this todo?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.handleDeleteAction()
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }
    
    private func setupDatePicker(for textField: UITextField) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.date = todoItem?.dueDate ?? Date()
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        textField.inputView = datePicker
    }
    
    @objc private func dateChanged(_ datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        if let activeTextField = UIResponder.currentFirst as? UITextField {
            activeTextField.text = dateFormatter.string(from: datePicker.date)
        }
    }
}

extension UIResponder {
    public static var currentFirst: UIResponder? {
        _currentFirstResponder = nil
        UIApplication.shared.sendAction(#selector(UIResponder._captureCurrentFirstResponder(_:)), to: nil, from: nil, for: nil)
        return _currentFirstResponder
    }
    private static var _currentFirstResponder: UIResponder? = nil
    @objc private func _captureCurrentFirstResponder(_ sender: Any) {
        UIResponder._currentFirstResponder = self
    }
}

extension Notification.Name {
    static let todoItemUpdated = Notification.Name("TodoItemUpdated")
}

