//
//  TaskDetailsInteractor.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 28.09.2025.
//
import Foundation

final class TaskDetailsInteractor: TaskDetailsInteractorProtocol {

    private let storage: StorageManagerProtocol

    init(storage: StorageManagerProtocol) {
        self.storage = storage
    }

    func saveTask(task: Task?, with info: TaskInfo, completion: @escaping () -> Void) {
        if let task = task {
            let updatedTask = task.update(with: info)
            storage.update(task: updatedTask) {_ in
                completion()
            }
        } else {
            let task = Task(
                id: Int.random(in: 1...Int.max),
                name: info.name,
                description: info.description,
                isCompleted: false,
                userId: Int.random(in: 1...Int.max),
                createdAt: Date()
            )
            storage.create(task: task) {
                completion()
            }
        }
    }
}
