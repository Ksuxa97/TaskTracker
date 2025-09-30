//
//  DataManager.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 29.09.2025.
//

import CoreData
import Foundation

final class StorageManager {

    static let shared = StorageManager()

    //var tasks: [Task] = []

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

    private init() {
        viewContext = persistentContainer.viewContext
    }

    func fetchData(completion: @escaping (Result<[Task], Error>) -> Void) {
        DispatchQueue.global().async { [weak self] in
            let fetchRequest = Task.fetchRequest()

            do {
                guard let self else { return }
                let tasks = try self.viewContext.fetch(fetchRequest)
                completion(.success(tasks))
            } catch let error {
                completion(.failure(error))
            }
        }
    }

    func create(_ item: ToDo, completion: (Task) -> Void) {
        let task = Task(context: viewContext)
        task.id = Int64(item.id)
        task.name = item.todo
        task.taskDescription = ""
        task.isCompleted = item.completed
        task.userId = Int64(item.userId)
        task.createdAt = Date()
        completion(task)
        saveContext()
    }

    func update(_ task: Task, newName: String) {
        task.name = newName
        saveContext()
    }

    func delete(_ task: Task) {
        viewContext.delete(task)
        saveContext()
    }

    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func isEmpty() -> Bool {
        let request = Task.fetchRequest()
        let count = (try? viewContext.count(for: request)) ?? 0
        return count == 0
    }

}
