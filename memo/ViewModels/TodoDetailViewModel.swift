//
//  TodoDetailViewModel.swift
//  memo
//
//  Created by Jongbum Lee on 2023/09/21.
//

import Foundation
import CoreData

class TodoDetailViewModel {
    private var todoItem: Task?
    var dataDidUpdate: (() -> Void)?

    init(todoItem: Task?) {
        self.todoItem = todoItem
    }

    func updateTodoItem(task: Task) {
        self.todoItem = task
        dataDidUpdate?()
    }

    var title: String {
        return todoItem?.title ?? ""
    }

    var isCompleted: Bool {
        return todoItem?.isCompleted ?? false
    }

    var category: String {
        return todoItem?.category ?? ""
    }

    var dueDate: Date? {
        return todoItem?.dueDate
    }

    func handleEditAction(title: String?, dueDate: Date?, category: String?) {
        todoItem?.title = title ?? ""
        todoItem?.dueDate = dueDate
        todoItem?.category = category ?? ""

        _ = CoreDataHelper.shared.updateTask(todoItem!, with: title ?? "")
        dataDidUpdate?()
    }

    func handleDeleteAction() {
        guard let todoItemToDelete = todoItem else { return }
        _ = CoreDataHelper.shared.deleteTask(todoItemToDelete)
        NotificationCenter.default.post(name: Notification.Name("TodoItemDeleted"), object: nil)
    }
}

