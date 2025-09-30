//
//  NetworkService.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 27.09.2025.
//

import Foundation

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

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case noDataFound
}

final class NetworkService {
    func request(url: URL, completion: @escaping (Result<ToDoListResponse, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let response = response as? HTTPURLResponse,
                      (200..<300).contains(response.statusCode) else {
                    completion(.failure(NetworkError.invalidResponse))
                    return
                }

                guard let data = data else {
                    completion(.failure(NetworkError.noDataFound))
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode(ToDoListResponse.self, from: data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}
