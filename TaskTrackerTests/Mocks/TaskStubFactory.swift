//
//  TaskStubFactory.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 07.10.2025.
//

import Foundation
@testable import TaskTracker

struct TaskStubFactory {

    static func makeTask(
        id: String = UUID().uuidString,
        name: String = "Test Task",
        description: String? = nil,
        isCompleted: Bool = false,
        userId: String = UUID().uuidString,
        createdAt: Date = Date()
    ) -> Task {
        return Task(
            id: id,
            name: name,
            description: description,
            isCompleted: isCompleted,
            userId: userId,
            createdAt: createdAt
        )
    }

    static func makeTaskList(count: Int = 5) -> [Task] {
        (1...count).map { index in
            makeTask(
                id: UUID().uuidString,
                name: "Task \(index)",
                description: "Description \(index)",
                isCompleted: index % 2 == 0, // чередуем выполненные задачи
                userId: UUID().uuidString
            )
        }
    }
}
