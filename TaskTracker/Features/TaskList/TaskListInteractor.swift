//
//  TaskListInteractor.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 27.09.2025.
//
import Foundation

// работа с очередями лучше только тут  добавить перезод на мейн тут
//в конструктор передавать сервис с апи и сторедж: убрать синглтон

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
                case .failure(let error):
                    print("Error: \(error)")
                }

                DispatchQueue.main.async {
                    completion(self.tasks)
                }
            }
        }
    }

    func loadTasks(completion: @escaping ([Task]) -> Void) {
        if storage.isEmpty {
            apiService.getToDoList() { [weak self] result in
                guard let self else { return }

                switch result {
                case .success(let todoList):
                    self.saveToCoreData(taskList: todoList)
                case .failure(let error):
                    print("Error: \(error)")
                }

                DispatchQueue.main.async {
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

    private func saveToCoreData(taskList: [ToDo]) {
        taskList.forEach { item in
            storage.create(item) { task in
                self.tasks.append(task)
            }
        }
    }
}
