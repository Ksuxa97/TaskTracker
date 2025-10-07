//
//  ToDoList.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 27.09.2025.
//


struct ToDoListResponse: Codable {
    let todos: [ToDo]
    let total: Int
    let skip: Int
    let limit: Int

    var hasMore: Bool {
        return skip + limit < total
    }
}

struct ToDo: Codable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}
