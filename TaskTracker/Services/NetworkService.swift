//
//  NetworkService.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 27.09.2025.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case noDataFound
}

final class NetworkService {
    func request<T: Decodable>(url: URL, completion: @escaping (Result<T, Error>) -> Void) {
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
                    let decoded = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}
