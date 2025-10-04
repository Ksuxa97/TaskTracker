//
//  TaskDetailsInteractor.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 28.09.2025.
//

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
            storage.createTask(with: info) {
                completion()
            }
        }
    }
}
