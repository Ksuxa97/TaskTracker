//
//  ApiServiceTests.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 07.10.2025.
//

import XCTest
@testable import TaskTracker

final class ApiServiceTests: XCTestCase {

    var mockNetwork: MockNetworkService!
    var apiService: ApiService!

    override func setUp() {
        super.setUp()
        mockNetwork = MockNetworkService()
        apiService = ApiService(networkService: mockNetwork)
    }

    // MARK: - Tests
    func testGetTaskListSinglePage() {
        // Given
        let todos = [
            ToDo(id: 1, todo: "Test1", completed: false, userId: 10),
            ToDo(id: 2, todo: "Test2", completed: true, userId: 11)
        ]
        let response = ToDoListResponse(todos: todos, total: 2, skip: 0, limit: 30)
        mockNetwork.responses = [
            .success(response), // Для getNumberOfPages
            .success(response)  // Для fetchTaskPage
        ]

        let expectation = XCTestExpectation(description: "Tasks loaded")

        // When
        apiService.getTaskList { result in
            // Then
            switch result {
            case .success(let tasks):
                XCTAssertEqual(tasks.count, 2)
                XCTAssertEqual(tasks.first?.name, "Test1")
                XCTAssertTrue(tasks.last?.isCompleted ?? false)
            case .failure(let error):
                XCTFail("Expected success but got failure: \(error)")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func testGetTaskListMultiplePages() {
        // Given
        let page1Todos = [ToDo(id: 1, todo: "Page1", completed: false, userId: 1)]
        let page2Todos = [ToDo(id: 2, todo: "Page2", completed: true, userId: 2)]

        let page1Response = ToDoListResponse(todos: page1Todos, total: 2, skip: 0, limit: 1)
        let page2Response = ToDoListResponse(todos: page2Todos, total: 2, skip: 1, limit: 1)

        mockNetwork.responses = [
            .success(page1Response),
            .success(page1Response),
            .success(page2Response)
        ]

        let expectation = XCTestExpectation(description: "Multiple pages loaded")

        // When
        apiService.getTaskList { result in
            // Then
            switch result {
            case .success(let tasks):
                XCTAssertEqual(tasks.count, 2)
                XCTAssertEqual(tasks[0].name, "Page1")
                XCTAssertEqual(tasks[1].name, "Page2")
            case .failure(let error):
                XCTFail("Expected success but got \(error)")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }

    // MARK: - Network Error Tests
    func testGetTaskListFailureInFetchTaskPage() {
        // Given
        let response = ToDoListResponse(todos: [], total: 2, skip: 0, limit: 30)

        mockNetwork.responses = [
            .success(response),
            .failure(NSError(domain: "network", code: -1))
        ]

        let expectation = XCTestExpectation(description: "Network error in fetchTaskPage")

        // When
        apiService.getTaskList { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3.0)
    }

    // MARK: - Edge Cases
    func testGetTaskListEmptyResponse() {
        // Given
        let emptyResponse = ToDoListResponse(todos: [], total: 0, skip: 0, limit: 30)
        mockNetwork.responses = [
            .success(emptyResponse),
            .success(emptyResponse)
        ]

        let expectation = XCTestExpectation(description: "Empty response handled")

        // When
        apiService.getTaskList { result in
            // Then
            switch result {
            case .success(let tasks):
                XCTAssertTrue(tasks.isEmpty)
            case .failure(let error):
                XCTFail("Expected success with empty array but got \(error)")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func testGetTaskListZeroLimit() {
        // Given
        let zeroLimitResponse = ToDoListResponse(todos: [], total: 10, skip: 0, limit: 0)
        mockNetwork.responses = [.success(zeroLimitResponse)]

        let expectation = XCTestExpectation(description: "Zero limit handled")

        // When
        apiService.getTaskList { result in
            // Then
            switch result {
            case .success(let tasks):
                XCTAssertTrue(tasks.isEmpty)
            case .failure(let error):
                XCTFail("Expected success with empty array but got \(error)")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3.0)
    }
}
