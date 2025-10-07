//
//  TaskEntity.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 03.10.2025.
//

import Foundation

extension TaskEntity {
    func toTask() -> Task {
        return Task(
            id: self.id ?? UUID().uuidString,
            name: self.name ?? "Без названия",
            description: self.taskDescription,
            isCompleted: self.isCompleted,
            userId: self.userId ?? UUID().uuidString,
            createdAt: self.createdAt ?? Date()
        )
    }

    func update(from model: Task) {
        self.name = model.name
        self.taskDescription = model.description
        self.isCompleted = model.isCompleted
    }
}
