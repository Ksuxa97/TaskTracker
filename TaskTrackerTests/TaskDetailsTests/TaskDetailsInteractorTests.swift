//
//  TaskDetailsInteractorTests.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 07.10.2025.
//

import XCTest
@testable import TaskTracker

final class TaskDetailsInteractorTests: XCTestCase {

    private var interactor: TaskDetailsInteractor!
    private var mockStorage: MockStorage!

    override func setUp() {
        super.setUp()
        mockStorage = MockStorage()
        interactor = TaskDetailsInteractor(storage: mockStorage)
    }

    // MARK: - Tests
    func testSaveTaskCreatesNewTask() throws {
        // given
        let info = TaskInfo(name: "New Task", description: "Some description")

        let expectation = XCTestExpectation(description: "Create task completion called")

        // when
        interactor.saveTask(task: nil, with: info) {
            expectation.fulfill()
        }

        // then
        wait(for: [expectation], timeout: 1.0)

        XCTAssertEqual(self.mockStorage.tasks.count, 1, "Должна быть создана новая задача")
        let createdTask = try XCTUnwrap(mockStorage.tasks.first)
        XCTAssertEqual(createdTask.name, info.name)
        XCTAssertEqual(createdTask.description, info.description)
        XCTAssertFalse(createdTask.isCompleted)
    }

    func testSaveTaskUpdatesExistingTask() throws {
        // given
        let existingTask = TaskStubFactory.makeTask(name: "Old Name", description: "Old Desc")
        mockStorage.tasks = [existingTask]
        let info = TaskInfo(name: "Updated Task", description: "Updated description")

        let expectation = XCTestExpectation(description: "Update task completion called")

        // when
        interactor.saveTask(task: existingTask, with: info) {
            expectation.fulfill()
        }

        // then
        wait(for: [expectation], timeout: 1.0)

        XCTAssertEqual(self.mockStorage.tasks.count, 1, "Должна быть только одна задача")
        let updated = try XCTUnwrap(mockStorage.tasks.first)
        XCTAssertEqual(updated.name, "Updated Task")
        XCTAssertEqual(updated.description, "Updated description")
    }

    func testSaveTaskDoesNotDuplicateWhenUpdatingTask() throws {
        // given
        let task = TaskStubFactory.makeTask()
        mockStorage.tasks = [task]
        let info = TaskInfo(name: "Renamed", description: "New description")

        let expectation = XCTestExpectation(description: "Update existing task")

        // when
        interactor.saveTask(task: task, with: info) {
            expectation.fulfill()
        }

        // then
        wait(for: [expectation], timeout: 1.0)

        XCTAssertEqual(mockStorage.tasks.count, 1, "Не должно появляться дубликатов")
        XCTAssertEqual(mockStorage.tasks.first?.name, "Renamed")
    }
}
