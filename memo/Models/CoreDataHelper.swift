//
//  CoreDataHelper.swift
//  memo
//
//  Created by Jongbum Lee on 2023/09/19.
//

import CoreData

class CoreDataHelper {
    
    static let shared = CoreDataHelper()
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Task")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    func saveContext() -> Bool {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                return true
            } catch {
                let error = error as NSError
                print("Unresolved error \(error), \(error.userInfo)")
                return false
            }
        }
        return true
    }
    
    func fetchTasks() -> [Task] {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            print("Failed to fetch tasks: \(error.localizedDescription)")
            return []
        }
    }
    
    func createTask(title: String, dueDate: Date, category: String) -> Bool {
        let task = Task(context: persistentContainer.viewContext)
        task.title = title
        task.createDate = Date()
        task.id = UUID()
        task.isCompleted = false
        task.dueDate = dueDate
        task.category = category
        
        return saveContext()
    }
    
    func readCompletedTasks() -> [Task] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isCompleted == %@", NSNumber(value: true))
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch completed tasks: \(error.localizedDescription)")
            return []
        }
    }
    
    func updateTask(_ task: Task, with title: String) -> Bool {
        task.title = title
        task.modifyDate = Date()
        return saveContext()
    }
    
    func deleteTask(_ task: Task) -> Bool {
        persistentContainer.viewContext.delete(task)
        return saveContext()
    }
    
    func toggleCompletion(_ task: Task) -> Bool {
        task.isCompleted.toggle()
        return saveContext()
    }
}



