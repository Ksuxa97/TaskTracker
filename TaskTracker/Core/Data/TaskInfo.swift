//
//  TaskInfo.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 01.10.2025.
//
import Foundation

struct TaskInfo {
    var name: String
    var description: String
}

struct Task {
    let id: String
    let name: String
    let description: String?
    let isCompleted: Bool
    let userId: String
    let createdAt: Date

    func update(with info: TaskInfo) -> Task {
        return Task(
            id: id,
            name: info.name,
            description: info.description,
            isCompleted: isCompleted,
            userId: userId,
            createdAt: createdAt)
    }

    func complete() -> Task {
        return Task(
            id: id,
            name: name,
            description: description,
            isCompleted: true,
            userId: userId,
            createdAt: createdAt)
    }
}
