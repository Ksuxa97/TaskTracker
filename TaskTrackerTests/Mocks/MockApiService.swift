//
//  MockApiService.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 07.10.2025.
//

import Foundation
@testable import TaskTracker

final class MockApiService: ApiServiceProtocol {
    var tasks: [Task] = TaskStubFactory.makeTaskList()
    var shouldFail = false

    func getTaskList(completion: @escaping (Result<[Task], Error>) -> Void) {
        if shouldFail {
            completion(.failure(NSError(domain: "", code: -1)))
        } else {
            completion(.success(tasks))
        }
    }
}
