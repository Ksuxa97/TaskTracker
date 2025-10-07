//
//  TestStorageManager.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 07.10.2025.
//

import CoreData
@testable import TaskTracker

import Foundation
import XCTest

final class TestStorageManager: StorageManagerProtocol {
    private var tasks: [Task] = []
    private let queue = DispatchQueue(label: "TestStorageManager", attributes: .concurrent)

    var isEmpty: Bool {
        queue.sync {
            tasks.isEmpty
        }
    }

    init(container: NSPersistentContainer) {
        // Игнорируем container, так как используем in-memory хранилище
    }

    func fetch(query: String?, completion: @escaping (Result<[Task], Error>) -> Void) {
        queue.async {
            let filteredTasks: [Task]

            if let query = query, !query.isEmpty {
                filteredTasks = self.tasks.filter { task in
                    task.name.localizedCaseInsensitiveContains(query) ||
                    (task.description?.localizedCaseInsensitiveContains(query) ?? false)
                }
            } else {
                filteredTasks = self.tasks
            }

            DispatchQueue.main.async {
                completion(.success(filteredTasks))
            }
        }
    }

    func save(taskList: [Task], completion: @escaping (Result<[Task], Error>) -> Void) {
        queue.async(flags: .barrier) {
            self.tasks = taskList
            DispatchQueue.main.async {
                completion(.success(taskList))
            }
        }
    }

    func create(task: Task, completion: @escaping () -> Void) {
        queue.async(flags: .barrier) {
            self.tasks.append(task)
            DispatchQueue.main.async {
                completion()
            }
        }
    }

    func update(task: Task, completion: @escaping (Result<Void, Error>) -> Void) {
        queue.async(flags: .barrier) {
            if let index = self.tasks.firstIndex(where: { $0.id == task.id }) {
                self.tasks[index] = task
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } else {
                let error = NSError(domain: "TestStorageManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Task not found"])
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func delete(task: Task, completion: @escaping (Result<Void, Error>) -> Void) {
        queue.async(flags: .barrier) {
            self.tasks.removeAll { $0.id == task.id }
            DispatchQueue.main.async {
                completion(.success(()))
            }
        }
    }
}

extension NSPersistentContainer {
    static func inMemoryContainer(name: String) -> NSPersistentContainer {
        let container = NSPersistentContainer(name: name)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load in-memory store: \(error)")
            }
        }
        return container
    }
}
