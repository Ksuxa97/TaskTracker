//
//  DummyAPIService.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 30.09.2025.
//

import Foundation

protocol ApiServiceProtocol {
    func getToDoList(completion: @escaping (Result<[Task], Error>) -> Void)
}

enum APIConstants {
    static let baseURL: String = "https://dummyjson.com"
}

enum Endpoint {
    case todos
    case create
    case update

    var url: URL? {
        switch self {
        case .todos:
            let urlComponents = URLComponents(string: APIConstants.baseURL + "/todos")
            return urlComponents?.url

        case .create: break
        case .update: break
        }
        return nil
    }
}

final class DummyAPIService: ApiServiceProtocol {

    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func getToDoList(completion: @escaping (Result<[Task], Error>) -> Void) {
        guard let url = Endpoint.todos.url else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        networkService.request(url: url) { (result: Result<ToDoListResponse, Error>) in
            switch result {
                case .success(let response):
                    let tasks = self.taskList(from: response.todos)
                    completion(.success(tasks))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }

    private func taskList(from todo: [ToDo]) -> [Task] {
        var tasks: [Task] = []
        todo.forEach { todo in
            let task = Task(
                id: todo.id,
                name: todo.todo,
                description: nil,
                isCompleted: todo.completed,
                userId: todo.userId,
                createdAt: Date()
            )
            tasks.append(task)
        }
        return tasks
    }
}

