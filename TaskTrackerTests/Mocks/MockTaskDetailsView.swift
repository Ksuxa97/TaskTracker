//
//  MockTaskDetailsView.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 07.10.2025.
//

@testable import TaskTracker

final class MockTaskDetailsView: TaskDetailsViewControllerProtocol {
    var setupUICalled = false

    func setupUI(task: Task?) {
        setupUICalled = true
    }
}
