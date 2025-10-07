//
//  StorageManagerTests.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 07.10.2025.
//

import XCTest
import CoreData
@testable import TaskTracker

final class StorageManagerTests: XCTestCase {

    private var storage: TestStorageManager!

    override func setUp() {
        super.setUp()
        let container = NSPersistentContainer.inMemoryContainer(name: "TaskTracker")
        storage = TestStorageManager(container: container)
    }

    // MARK: - Tests
    func testCreateAndFetch() {
        // given
        let task = TaskStubFactory.makeTask(name: "Test Create")
        let expectation = XCTestExpectation(description: "Create and fetch")

        // when
        storage.create(task: task) {
            self.storage.fetch(query: nil) { result in
                // then
                switch result {
                case .success(let tasks):
                    XCTAssertEqual(tasks.count, 1)
                    XCTAssertEqual(tasks.first?.name, "Test Create")
                case .failure:
                    XCTFail("Fetch failed")
                }
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 2.0) // Увеличим таймаут
    }

    func testUpdate() {
        // given
        var task = TaskStubFactory.makeTask(name: "To Update", isCompleted: false)
        let expectation = XCTestExpectation(description: "Update task")

        storage.create(task: task) {
            task = task.complete()

            // when
            self.storage.update(task: task) { _ in
                self.storage.fetch(query: nil) { result in
                    switch result {
                    case .success(let tasks):
                        XCTAssertTrue(tasks.first?.isCompleted == true)
                    case .failure:
                        XCTFail("Update failed")
                    }
                    expectation.fulfill()
                }
            }
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testDelete() {
        // given
        let task = TaskStubFactory.makeTask(name: "To Delete")
        let expectation = XCTestExpectation(description: "Delete task")

        storage.create(task: task) {
            self.storage.delete(task: task) { _ in
                self.storage.fetch(query: nil) { result in
                    switch result {
                    case .success(let tasks):
                        XCTAssertTrue(tasks.isEmpty)
                    case .failure:
                        XCTFail("Delete failed")
                    }
                    expectation.fulfill()
                }
            }
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testFetchWithQuery() {
        // given
        let tasks = [
            TaskStubFactory.makeTask(name: "Buy milk"),
            TaskStubFactory.makeTask(name: "Do homework")
        ]
        let expectation = XCTestExpectation(description: "Filter tasks")
        let group = DispatchGroup()

        for task in tasks {
            group.enter()
            storage.create(task: task) {
                group.leave()
            }
        }

        group.notify(queue: .main) {
            // when
            self.storage.fetch(query: "milk") { result in
                // then
                switch result {
                case .success(let filtered):
                    XCTAssertEqual(filtered.count, 1)
                    XCTAssertEqual(filtered.first?.name, "Buy milk")
                case .failure:
                    XCTFail("Filtering failed")
                }
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 2.0)
    }
}
