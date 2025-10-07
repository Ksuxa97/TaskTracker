//
//  TaskListPresenterTests.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 07.10.2025.
//

import XCTest
@testable import TaskTracker

final class TaskListPresenterTests: XCTestCase {

    var storage: MockStorage!
    var apiService: MockApiService!
    var interactor: TaskListInteractor!
    var presenter: TaskListPresenter!
    var view: MockTaskListView!

    override func setUp() {
        super.setUp()
        storage = MockStorage()
        apiService = MockApiService()
        interactor = TaskListInteractor(storage: storage, apiService: apiService)
        presenter = TaskListPresenter(interactor: interactor, router: TaskListRouter())
        view = MockTaskListView()
        presenter.view = view
    }

    // MARK: - Tests

    func testUpdateTaskListTriggersViewUpdate() {
        storage.tasks = [Task(id: "1", name: "Task1", description: nil, isCompleted: false, userId: "u1", createdAt: Date())]
        presenter.updateTaskList()
        XCTAssertTrue(view.updateViewCalled)
    }

    func testToggleTaskCompletionMarksTaskCompleted() {
        let task = Task(id: "1", name: "Task1", description: nil, isCompleted: false, userId: "u1", createdAt: Date())
        storage.tasks = [task]
        presenter.updateTaskList()

        presenter.toggleTaskCompletion(at: 0)
        XCTAssertTrue(storage.tasks.first?.isCompleted ?? false)
    }
}
