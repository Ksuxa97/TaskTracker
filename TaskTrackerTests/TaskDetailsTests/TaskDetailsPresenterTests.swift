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

    func testDidLoadCallsSetupUI() {
        presenter.didLoad()
        XCTAssertTrue(view.setupUICalled)
    }

    func testSaveTaskCreatesTask() {
        let info = TaskInfo(name: "New Task", description: "Desc")
        presenter.saveTask(with: info)
        XCTAssertEqual(storage.tasks.count, 1)
        XCTAssertEqual(storage.tasks.first?.name, info.name)
    }
}
