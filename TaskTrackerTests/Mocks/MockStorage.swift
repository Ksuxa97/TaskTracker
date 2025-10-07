//
//  MockStorage.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 07.10.2025.
//

import Foundation
@testable import TaskTracker

final class MockStorage: StorageManagerProtocol {
    var isEmpty: Bool = true
    var tasks: [Task] = []

    func fetch(query: String?, completion: @escaping (Result<[Task], Error>) -> Void) {
        if let query = query, !query.isEmpty {
            completion(.success(tasks.filter { $0.name.contains(query) }))
        } else {
            completion(.success(tasks))
        }
    }

    func save(taskList: [Task], completion: @escaping (Result<[Task], Error>) -> Void) {
        tasks.append(contentsOf: taskList)
        completion(.success(tasks))
    }

    func create(task: Task, completion: @escaping () -> Void) {
        tasks.append(task)
        completion()
    }

    func update(task: Task, completion: @escaping (Result<Void, Error>) -> Void) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        }
        completion(.success(()))
    }

    func delete(task: Task, completion: @escaping (Result<Void, Error>) -> Void) {
        tasks.removeAll { $0.id == task.id }
        completion(.success(()))
    }
}
