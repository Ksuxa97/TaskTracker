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
    func fetchData(completion: @escaping (Result<[Task], Error>) -> Void)
    func saveData(taskList: [Task], completion: @escaping (Result<[Task], Error>) -> Void)
    func create(task: Task, completion: @escaping () -> Void)
    func update(task: Task, completion: @escaping (Result<Void, Error>) -> Void)
    func delete(task: Task, completion: @escaping (Result<Void, Error>) -> Void)
    func getEntities(with text: String, completion: @escaping (Result<[Task], Error>) -> Void)
}

final class StorageManager: StorageManagerProtocol {

    static let shared = StorageManager()

    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskTracker")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    private let viewContext: NSManagedObjectContext
    private let backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)

    private init() {
        viewContext = persistentContainer.viewContext
        viewContext.automaticallyMergesChangesFromParent = true

        backgroundContext.parent = viewContext
        backgroundContext.automaticallyMergesChangesFromParent = true
        backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

    }

    private lazy var lastID: Int64 = {
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        fetchRequest.fetchLimit = 1

        return (try? viewContext.fetch(fetchRequest).first?.id) ?? 0
    }()

    var isEmpty: Bool {
       (try? self.viewContext.count(for: TaskEntity.fetchRequest())) ?? 0 == 0
    }

    func fetchData(completion: @escaping (Result<[Task], Error>) -> Void) {
        backgroundContext.perform { [weak self] in
            guard let self else { return }
            let fetchRequest = TaskEntity.fetchRequest()
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(key: "isCompleted", ascending: true),
                NSSortDescriptor(key: "createdAt", ascending: false)
            ]
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

    func saveData(taskList: [Task], completion: @escaping (Result<[Task], Error>) -> Void) {
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
            fetchData { [weak self] result in
                guard let self else { return }
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
            entity.id = Int64(task.id)
            entity.name = task.name
            entity.taskDescription = task.description
            entity.isCompleted = task.isCompleted
            entity.userId = Int64(task.userId)
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
            fetchRequest.predicate = NSPredicate(format: "id == %d", task.id)
            backgroundContext.refreshAllObjects()

            do {
                guard let entity = try backgroundContext.fetch(fetchRequest).first else {
                    return
                }
                backgroundContext.delete(entity)

                try backgroundContext.save()
                viewContext.performAndWait{
                    try? self.viewContext.save()
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
            fetchRequest.predicate = NSPredicate(format: "id == %d", task.id)
            backgroundContext.refreshAllObjects()

            do {
                guard let entity = try backgroundContext.fetch(fetchRequest).first else {
                    return
                }
                entity.update(from: task)
                try backgroundContext.save()
                viewContext.performAndWait{
                    try? self.viewContext.save()
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

    func getEntities(with text: String, completion: @escaping (Result<[Task], Error>) -> Void) {
        backgroundContext.perform { [weak self] in
            guard let self else { return }
            let fetchRequest = TaskEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(
                format: "name CONTAINS[cd] %@ OR taskDescription CONTAINS[cd] %@",
                text, text
            )

            fetchRequest.sortDescriptors = [
                NSSortDescriptor(key: "isCompleted", ascending: true),
                NSSortDescriptor(key: "createdAt", ascending: false)
            ]
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

    private func saveParentContext() {
        viewContext.performAndWait {
            if viewContext.hasChanges {
                try? viewContext.save()
            }
        }
    }
}
