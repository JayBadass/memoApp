//
//  MemoClass.swift
//  memo
//
//  Created by Jongbum Lee on 2023/08/02.
//
import UIKit

var globalTodoList: [TodoItem] = []

struct TodoItem {
    var id: Int
    var title: String
    var isCompleted: Bool
    var dueDate: Date
}
