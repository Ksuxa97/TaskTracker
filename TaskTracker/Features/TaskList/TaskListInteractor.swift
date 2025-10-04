//
//  TaskListInteractor.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 27.09.2025.
//
import Foundation

final class TaskListInteractor: TaskListInteractorProtocol {

    private var tasks: [Task] = []
    private let storage: StorageManagerProtocol
    private let apiService: ApiServiceProtocol

    init(storage: StorageManagerProtocol, apiService: ApiServiceProtocol) {
        self.storage = storage
        self.apiService = apiService
    }

    func deleteTask(_ task: Task, completion: @escaping ([Task]) -> Void) {
        storage.delete(task) { [weak self] result in
            guard let self else { return }
            self.storage.fetchData { [weak self] result in
                guard let self else { return }

                switch result {
                case .success(let taskList):
                    self.tasks = taskList
                    completion(self.tasks)
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }
    }

    func updateTaskState(_ task: Task, completion: @escaping () -> Void) {
        storage.update(task: task) {_ in
            completion()
        }
    }

    func loadTasks(completion: @escaping ([Task]) -> Void) {
        if storage.isEmpty {
            apiService.getToDoList() { [weak self] result in
                guard let self else { return }

                switch result {
                case .success(let todoList):
                    self.saveToCoreData(taskList: todoList) {
                        completion(self.tasks)
                    }
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        } else {
            storage.fetchData { [weak self] result in
                guard let self else { return }

                switch result {
                case .success(let taskList):
                    self.tasks = taskList
                case .failure(let error):
                    print("Error: \(error)")
                }
                completion(self.tasks)
            }
        }
    }

    func getTasks(with text: String, completion: @escaping ([Task]) -> Void) {
        storage.getEntities(with: text) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let taskList):
                self.tasks = taskList
            case .failure(let error):
                print("Error: \(error)")
            }
            completion(self.tasks)
        }
    }

    private func saveToCoreData(taskList: [ToDo], completion: @escaping () -> Void) {
        let group = DispatchGroup()

        taskList.forEach { [weak self] item in
            guard let self else { return }
            group.enter()
            self.storage.create(item) { _ in
                group.leave()
            }
        }

        group.notify(queue: .global()) { [weak self] in
            guard let self else { return }
            self.storage.fetchData { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let tasks):
                    self.tasks = tasks
                case .failure(let error):
                    print("Fetch after save failed:", error)
                }
                completion()
            }
        }
    }
}
