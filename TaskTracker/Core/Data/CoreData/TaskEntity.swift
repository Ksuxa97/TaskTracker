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
            id: Int(self.id),
            name: self.name ?? "Без названия",
            description: self.taskDescription,
            isCompleted: self.isCompleted,
            userId: Int(self.userId),
            createdAt: self.createdAt ?? Date()
        )
    }

    func update(from model: Task) {
        self.name = model.name
        self.taskDescription = model.description
        self.isCompleted = model.isCompleted
    }
}
