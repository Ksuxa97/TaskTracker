//
//  TaskDetailsPresenterTests.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 07.10.2025.
//

import XCTest
@testable import TaskTracker

final class TaskDetailsPresenterTests: XCTestCase {

    var presenter: TaskDetailsPresenter!
    var interactor: TaskDetailsInteractor!
    var storage: MockStorage!
    var router: TaskDetailsRouter!
    var view: MockTaskDetailsView!

    override func setUp() {
        super.setUp()
        storage = MockStorage()
        interactor = TaskDetailsInteractor(storage: storage)
        router = TaskDetailsRouter()
        presenter = TaskDetailsPresenter(interactor: interactor, router: router)
        view = MockTaskDetailsView()
        presenter.view = view
    }

    // MARK: - Tests
    
    func testDidLoadCallsSetupUI() {
        // when
        presenter.didLoad()

        // then
        XCTAssertTrue(view.setupUICalled)
    }

    func testSaveTaskCreatesTask() {
        // given
        let info = TaskInfo(name: "New Task", description: "Desc")

        // when
        presenter.saveTask(with: info)

        // then
        XCTAssertEqual(storage.tasks.count, 1)
        XCTAssertEqual(storage.tasks.first?.name, info.name)
    }
}
