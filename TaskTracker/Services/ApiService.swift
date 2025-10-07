//
//  ApiService.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 30.09.2025.
//

import Foundation

protocol ApiServiceProtocol {
    func getTaskList(completion: @escaping (Result<[Task], Error>) -> Void)
}

enum APIConstants {
    static let baseURL: String = "https://dummyjson.com"
}

enum Endpoint {
    case todos(skip: Int, limit: Int)

    var url: URL? {
        switch self {
        case .todos(let skip, let limit):
            var components = URLComponents(string: APIConstants.baseURL + "/todos")
            components?.queryItems = [
                URLQueryItem(name: "skip", value: String(skip)),
                URLQueryItem(name: "limit", value: String(limit))
            ]
            return components?.url

        }
    }
}

final class ApiService: ApiServiceProtocol {

    private let networkService: NetworkServiceProtocol

    private var limit = 30
    private var total = 0

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getTaskList(completion: @escaping (Result<[Task], Error>) -> Void) {

        var allTasks: [ToDo] = []
        getNumberOfPages() { [weak self] pageCount in
            guard let self else { return }
            let group = DispatchGroup()

            for page in 0..<pageCount {
                group.enter()
                self.fetchTaskPage(skip: page * self.limit) { result in
                    switch result {
                    case .success(let todos):
                        allTasks.append(contentsOf: todos)

                    case .failure(let error):
                        print("Couldn't fetch tasks: \(error)")
                        completion(.failure(error))
                    }
                    group.leave()
                }

            }

            group.notify(queue: .main) {
                let tasks = self.taskList(from: allTasks)
                completion(.success(tasks))
            }
        }
    }

    func fetchTaskPage(skip: Int, completion: @escaping (Result<[ToDo], Error>) -> Void) {
        guard let url = Endpoint.todos(skip: skip, limit: limit).url else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        networkService.request(url: url) { (result: Result<ToDoListResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.todos))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func getNumberOfPages(completion: @escaping (Int) -> Void) {
        guard let url = Endpoint.todos(skip: 0, limit: limit).url else {
            completion(0)
            return
        }
        self.networkService.request(url: url) { [weak self] (result: Result<ToDoListResponse, Error>) in
            guard let self else { return }

            switch result {
            case .success(let response):
                total = response.total
                limit = response.limit
                guard limit != 0 else {
                    completion(0)
                    return
                }
                completion(Int(ceil(Double(total) / Double(limit))))
            case .failure:
                total = 0
                limit = 0
                completion(0)
            }
        }
    }

    private func taskList(from todo: [ToDo]) -> [Task] {
        todo.map {
            Task(
                id: String($0.id),
                name: $0.todo,
                description: nil,
                isCompleted: $0.completed,
                userId: String($0.userId),
                createdAt: Date()
            )
        }
    }
}
