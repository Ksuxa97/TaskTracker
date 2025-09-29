//
//  Task.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 27.09.2025.
//
import Foundation

struct Task: Codable {
    let id: Int
    let name: String
    let description: String?
    let createdAt: Date
    let isCompleted: Bool
    let userId: Int?

//    init(task: ToDo) {
//        self.id = task.id
//        self.name = task.todo
//        self.description = nil
//        self.isCompleted = task.completed
//        self.createdAt = Date()
//        self.userId = task.userId
//    }
}
