//
//  DoneViewModel.swift
//  memo
//
//  Created by Jongbum Lee on 2023/09/21.
//

import Foundation
import CoreData

class DoneViewModel {
    
    var dataDidUpdate: (() -> Void)?
    
    var doneTodos: [Task] {
        return CoreDataHelper.shared.readCompletedTasks()
    }
    
    func numberOfRows(in section: Int) -> Int {
        return doneTodos.count
    }
    
    func task(at indexPath: IndexPath) -> Task {
        return doneTodos[indexPath.row]
    }
}
