//
//  MockTaskListView.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 07.10.2025.
//

@testable import TaskTracker

final class MockTaskListView: TaskListViewControllerProtocol {
    var updateViewCalled = false
    var showLoadingCalled = false
    var hideLoadingCalled = false

    func updateView() {
        updateViewCalled = true
    }

    func showLoading() {
        showLoadingCalled = true
    }

    func hideLoading() {
        hideLoadingCalled = true
    }
}



