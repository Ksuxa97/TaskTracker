//
//  TaskListInteractor.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 27.09.2025.
//
import Foundation

final class TaskListInteractor: TaskListInteractorProtocol {

    private var tasks: [Task] = []
    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func loadTasks(completion: @escaping ([Task]) -> Void) {

        if StorageManager.shared.isEmpty() {
            loadDataFromApi { result in
                switch result {
                case .success(let taskList):
                    self.saveToCoreData(taskList: taskList.todos)
                    self.loadFromCoreData() { taskList in
                        completion(taskList)
                    }

                case .failure(let error):
                    print("Error: \(error)")
                    completion([])
                }
                return
            }
        } else {
            self.loadFromCoreData(){ taskList in
                completion(taskList)
            }
        }
    }
    private func saveToCoreData(taskList: [ToDo]) {
        taskList.forEach { item in
            StorageManager.shared.create(item) { task in
                self.tasks.append(task)
            }
        }
    }

    private func loadDataFromApi(completion: @escaping (Result<ToDoListResponse, Error>) -> Void) {
        guard let url = Endpoint.todos.url else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        networkService.request(url: url) { result in
            switch result {
                case .success(let response):
                    completion(.success(response))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }

    private func loadFromCoreData(completion: @escaping ([Task]) -> Void) {
        StorageManager.shared.fetchData { result in
            switch result {
            case .success(let data):
                completion(data)
            case .failure(let error):
                print("Error: \(error)")
                completion([])
            }
        }
    }
}
