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
        storage.delete(task: task) { [weak self] result in
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
                case .success(let tasks):
                    self.storage.saveData(taskList: tasks) { result in
                        switch result {
                        case .success(let tasks):
                            completion(tasks)
                        case .failure(let error):
                            print("Error: \(error)")
                        }
                    }
                case .failure(let error):
                    print("Error: \(error)")
                    completion(self.tasks)
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
}
