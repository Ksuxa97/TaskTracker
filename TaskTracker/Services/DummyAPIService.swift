//
//  DummyAPIService.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 30.09.2025.
//

import Foundation

protocol ApiServiceProtocol {
    func getToDoList(completion: @escaping (Result<[ToDo], Error>) -> Void)
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

    func getToDoList(completion: @escaping (Result<[ToDo], Error>) -> Void) {
        guard let url = Endpoint.todos.url else {
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
}
