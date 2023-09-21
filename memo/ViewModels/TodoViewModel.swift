//
//  TodoViewModel.swift
//  memo
//
//  Created by Jongbum Lee on 2023/09/21.
//

import Foundation

class TodoViewModel {
    
    private var todoList: [Task] = []
    
    var dataDidUpdate: (() -> Void)?
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    init() {
        refreshTasks()
    }
    
    func refreshTasks() {
        todoList = CoreDataHelper.shared.fetchTasks()
        self.dataDidUpdate?()
    }
    
    func addTask(title: String, dueDate: Date, category: String) {
        _ = CoreDataHelper.shared.createTask(title: title, dueDate: dueDate, category: category)
        refreshTasks()
    }
    
    func updateTask(task: Task, title: String, dueDate: Date, category: String) {
        task.title = title
        task.dueDate = dueDate
        task.category = category
        _ = CoreDataHelper.shared.updateTask(task, with: title)
        refreshTasks()
    }
    
    func deleteTask(task: Task) {
        _ = CoreDataHelper.shared.deleteTask(task)
        refreshTasks()
    }
    
    func todos(in category: String) -> [Task] {
        return todoList.filter { $0.category == category }
    }
    
    func task(at indexPath: IndexPath) -> Task {
        let category = Category.allCases[indexPath.section]
        return todos(in: category.rawValue)[indexPath.row]
    }
    
    func date(from string: String) -> Date? {
        return dateFormatter.date(from: string)
    }
    
    func dateString(from date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    func toggleCompletion(at indexPath: IndexPath) {
        let task = self.task(at: indexPath)
        task.isCompleted.toggle()
        _ = CoreDataHelper.shared.saveContext()
        self.dataDidUpdate?()
    }

}
