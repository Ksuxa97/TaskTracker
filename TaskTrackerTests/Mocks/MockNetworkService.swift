//
//  MockNetworkService.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 07.10.2025.
//

import Foundation
@testable import TaskTracker

final class MockNetworkService: NetworkServiceProtocol {
    var shouldFail = false
    var responses: [Result<ToDoListResponse, Error>] = []
    private var responseIndex = 0

    func request<T: Decodable>(url: URL, completion: @escaping (Result<T, Error>) -> Void) {
        if shouldFail {
            completion(.failure(NSError(domain: "network", code: -1)))
            return
        }

        guard responseIndex < responses.count else {
            completion(.failure(NSError(domain: "mock", code: -2, userInfo: [NSLocalizedDescriptionKey: "No more responses configured"])))
            return
        }

        let response = responses[responseIndex]
        responseIndex += 1

        switch response {
        case .success(let todoResponse):
            if let typedResponse = todoResponse as? T {
                completion(.success(typedResponse))
            } else {
                completion(.failure(NSError(domain: "type", code: -3, userInfo: [NSLocalizedDescriptionKey: "Type cast failed"])))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }

    func reset() {
        responseIndex = 0
        responses = []
        shouldFail = false
    }
}
