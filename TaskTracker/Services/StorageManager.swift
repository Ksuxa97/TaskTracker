//
//  DataManager.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 29.09.2025.
//

import CoreData
import Foundation

protocol StorageManagerProtocol {
    var isEmpty: Bool { get }
    func fetch(query: String?, completion: @escaping (Result<[Task], Error>) -> Void)
    func save(taskList: [Task], completion: @escaping (Result<[Task], Error>) -> Void)
    func create(task: Task, completion: @escaping () -> Void)
    func update(task: Task, completion: @escaping (Result<Void, Error>) -> Void)
    func delete(task: Task, completion: @escaping (Result<Void, Error>) -> Void)
}

final class StorageManager: StorageManagerProtocol {

    static let shared = StorageManager()

    private let viewContext: NSManagedObjectContext
    private let backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)

    private init() {
        let container = NSPersistentContainer(name: "TaskTracker")
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Core Data init failed: \(error)")
            }
        }
        viewContext = container.viewContext
        viewContext.automaticallyMergesChangesFromParent = true

        backgroundContext.parent = viewContext
        backgroundContext.automaticallyMergesChangesFromParent = true
        backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

    }

    var isEmpty: Bool {
       (try? self.viewContext.count(for: TaskEntity.fetchRequest())) ?? 0 == 0
    }

    func fetch(query: String? = nil, completion: @escaping (Result<[Task], Error>) -> Void) {
        backgroundContext.perform { [weak self] in

            guard let self else { return }
            let fetchRequest = TaskEntity.fetchRequest()

            if let text = query {
                fetchRequest.predicate = NSPredicate(
                    format: "name CONTAINS[cd] %@ OR taskDescription CONTAINS[cd] %@",
                    text, text
                )
            }
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            backgroundContext.refreshAllObjects()

            do {
                let entities = try backgroundContext.fetch(fetchRequest)
                let tasks = entities.map { $0.toTask() }
                DispatchQueue.main.async {
                    completion(.success(tasks))
                }
            } catch let error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func save(taskList: [Task], completion: @escaping (Result<[Task], Error>) -> Void) {
        let group = DispatchGroup()

        taskList.forEach { [weak self] task in
            guard let self else { return }
            group.enter()
            create(task: task) {
                group.leave()
            }
        }

        group.notify(queue: .global()) { [weak self] in
            guard let self else { return }
            fetch { result in
                switch result {
                case .success(let tasks):
                    completion(.success(tasks))
                case .failure(let error):
                    completion(.failure(error))
                }

            }
        }
    }

    func create(task: Task, completion: @escaping () -> Void) {
        backgroundContext.perform { [weak self] in
            guard let self else { return }
            let entity = TaskEntity(context: backgroundContext)
            entity.id = task.id
            entity.name = task.name
            entity.taskDescription = task.description
            entity.isCompleted = task.isCompleted
            entity.userId = task.userId
            entity.createdAt = task.createdAt

            do {
                try backgroundContext.save()
                viewContext.performAndWait{
                    try? self.viewContext.save()
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            } catch {
                print("Ошибка обновления: \(error)")
            }
        }
    }

    func delete(task: Task, completion: @escaping (Result<Void, Error>) -> Void) {
        backgroundContext.perform { [weak self] in
            guard let self else { return }
            let fetchRequest = TaskEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", task.id)
            backgroundContext.refreshAllObjects()

            do {
                guard let entity = try backgroundContext.fetch(fetchRequest).first else {
                    print("Couldn't find task with such id")
                    return
                }
                backgroundContext.delete(entity)

                try backgroundContext.save()
                saveParentContext() {
                    DispatchQueue.main.async {
                        completion(.success(()))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func update(task: Task, completion: @escaping (Result<Void, Error>) -> Void) {
        backgroundContext.perform { [weak self] in
            guard let self else { return }
            let fetchRequest = TaskEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", task.id)
            backgroundContext.refreshAllObjects()

            do {
                guard let entity = try backgroundContext.fetch(fetchRequest).first else {
                    print("Couldn't find task with such id")
                    return
                }
                entity.update(from: task)
                try backgroundContext.save()
                saveParentContext() {
                    DispatchQueue.main.async {
                        completion(.success(()))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }

            }
        }
    }

    private func saveParentContext(completion: @escaping () -> Void) {
        viewContext.performAndWait {
            if viewContext.hasChanges {
                try? viewContext.save()
                completion()
            }
        }
    }
}
