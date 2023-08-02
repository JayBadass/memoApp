//
//  MemoClass.swift
//  memo
//
//  Created by Jongbum Lee on 2023/08/02.
//

import Foundation

var globalTodoList: [TodoItem] = []

struct TodoItem {
    var title: String
    var isCompleted: Bool
}
