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
    func create(_ item: ToDo, completion: @escaping (Task) -> Void)
    func createTask(with info: TaskInfo, completion: @escaping () -> Void)
    func update(task: Task, completion: @escaping (Result<Void, Error>) -> Void)
    func delete(_ task: Task, completion: @escaping (Result<Void, Error>) -> Void)
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

    func create(_ item: ToDo, completion: @escaping (Task) -> Void) {
        backgroundContext.perform { [weak self] in
            guard let self else { return }
            let entity = TaskEntity(context: self.backgroundContext)
            entity.id = Int64(item.id)
            entity.name = item.todo
            entity.taskDescription = ""
            entity.isCompleted = item.completed
            entity.userId = Int64(item.userId)
            entity.createdAt = Date()

            do {
                try backgroundContext.save()
                viewContext.performAndWait{
                    try? self.viewContext.save()
                    DispatchQueue.main.async {
                        completion(entity.toTask())
                    }
                }
            } catch {
                print("Ошибка обновления: \(error)")
            }
        }
    }

    func createTask(with info: TaskInfo, completion: @escaping () -> Void) {
        backgroundContext.perform { [weak self] in
            guard let self else { return }
            let entity = TaskEntity(context: backgroundContext)
            entity.id = self.lastID + 1
            entity.name = info.name
            entity.taskDescription = info.description
            entity.isCompleted = false
            entity.userId = Int64.random(in: 1...Int64.max)
            entity.createdAt = Date()

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

    func delete(_ task: Task, completion: @escaping (Result<Void, Error>) -> Void) {
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
