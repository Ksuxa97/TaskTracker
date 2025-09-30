//
//  TaskListPresenter.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 27.09.2025.
//

import Foundation
import UIKit

final class TaskListPresenter: TaskListPresenterProtocol {

    weak var view: TaskListViewControllerProtocol?
    var interactor: TaskListInteractorProtocol?
    var router: TaskListRouterProtocol?

    var numberOfItems: Int {
        return tasks.count
    }

    private var tasks: [Task] = []

    func getItem(with index: Int) -> Task {
        return tasks[index]
    }

    func didSelectTask(at index: Int) {
        guard let taskListVC = view as? UIViewController else { return }
        if router == nil {
            print("router is not initialized")
        }
        router?.navigateToTaskDetails(from: taskListVC, with: tasks[index])
    }

    func updateTaskList() {
        view?.showLoading()
        interactor?.loadTasks() { [weak self] result in
            guard let self else { return }
            self.tasks = result

            DispatchQueue.main.async {
                self.view?.hideLoading()
                self.view?.updateView()
            }
        }
    }

    func addButtonDidTap() {
        guard let taskListVC = view as? UIViewController else { return }
        router?.navigateToCreateTask(from: taskListVC)
    }
}
