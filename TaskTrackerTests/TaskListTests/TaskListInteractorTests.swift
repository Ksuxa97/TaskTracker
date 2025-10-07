//
//  TaskListInteractorTests.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 07.10.2025.
//

import XCTest
@testable import TaskTracker

final class TaskListInteractorTests: XCTestCase {

    private var interactor: TaskListInteractor!
    private var mockStorage: MockStorage!
    private var mockApiService: MockApiService!

    override func setUp() {
        super.setUp()
        mockStorage = MockStorage()
        mockApiService = MockApiService()
        interactor = TaskListInteractor(storage: mockStorage, apiService: mockApiService)
    }

    // MARK: - Tests

    func testLoadTasksFromAPIWhenStorageIsEmpty() {
        // given
        mockStorage.isEmpty = true
        mockApiService.shouldFail = false

        let expectation = XCTestExpectation(description: "Load tasks from API")

        // when
        interactor.loadTasks { tasks in
            // then
            XCTAssertFalse(tasks.isEmpty, "Задачи должны быть загружены из API")
            XCTAssertEqual(tasks.count, self.mockApiService.tasks.count)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testLoadTasksSavesTasksToStorageAfterAPISuccess() {
        // given
        mockStorage.isEmpty = true
        mockApiService.shouldFail = false
        let initialCount = mockStorage.tasks.count

        let expectation = XCTestExpectation(description: "Tasks saved to storage after API load")

        // when
        interactor.loadTasks { _ in
            // then
            XCTAssertGreaterThan(self.mockStorage.tasks.count, initialCount, "Задачи должны быть сохранены в хранилище")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testLoadTasksReturnsStoredTasksWhenStorageIsNotEmpty() {
        // given
        mockStorage.isEmpty = false
        mockStorage.tasks = TaskStubFactory.makeTaskList(count: 3)

        let expectation = XCTestExpectation(description: "Load tasks from storage")

        // when
        interactor.loadTasks { tasks in
            // then
            XCTAssertEqual(tasks.count, 3)
            XCTAssertEqual(tasks.first?.name, "Task 1")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testLoadTasksReturnsEmptyListWhenAPIAndStorageFail() {
        // given
        mockStorage.isEmpty = true
        mockApiService.shouldFail = true

        let expectation = XCTestExpectation(description: "Load tasks failure")

        // when
        interactor.loadTasks { tasks in
            // then
            XCTAssertTrue(tasks.isEmpty, "При ошибке API и пустом сторе должен вернуться пустой список")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testGetTasksReturnsTaskListWithQuery() {
        // given
        mockStorage.isEmpty = false
        mockStorage.tasks = TaskStubFactory.makeTaskList(count: 5)

        let query = "Task 2"
        let expectation = XCTestExpectation(description: "Filter tasks by query")

        // when
        interactor.getTasks(with: query) { tasks in
            // then
            XCTAssertEqual(tasks.count, 1, "Должна вернуться только одна задача с именем Task 2")
            XCTAssertEqual(tasks.first?.name, "Task 2")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testDeleteTaskRemovesTaskFromStorage() {
        // given
        let taskToDelete = TaskStubFactory.makeTask(name: "To Delete")
        mockStorage.tasks = [taskToDelete]
        mockStorage.isEmpty = false

        let expectation = XCTestExpectation(description: "Delete task from storage")

        // when
        interactor.deleteTask(taskToDelete) { tasks in
            // then
            XCTAssertTrue(tasks.isEmpty, "Задача должна быть удалена из списка")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testUpdateTask_callsStorageUpdate() {
        // given
        let existingTask = TaskStubFactory.makeTask(name: "To Update")
        mockStorage.tasks = [existingTask]
        var didComplete = false

        let expectation = XCTestExpectation(description: "Update task state called")

        // when
        interactor.updateTaskState(existingTask) {
            didComplete = true
            expectation.fulfill()
        }

        // then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(didComplete, "completion должен быть вызван")
    }
}
