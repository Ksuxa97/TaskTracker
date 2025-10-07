//
//  TaskListPresenter.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 27.09.2025.
//

import Foundation
import UIKit

final class TaskListPresenter: TaskListPresenterProtocol, TaskAddedDelegate {

    weak var view: TaskListViewControllerProtocol?
    var interactor: TaskListInteractorProtocol
    var router: TaskListRouterProtocol

    var numberOfItems: Int {
        return tasks.count
    }

    private var tasks: [Task] = []

    init(interactor: TaskListInteractorProtocol, router: TaskListRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

    func getItem(with index: Int) -> Task {
        return tasks[index]
    }

    func editTask(with index: Int) {
        router.navigateToTaskDetails(with: tasks[index])
    }

    func shareTask(with index: Int) {
        /// ToDo
    }

    func updateTaskList() {
        view?.showLoading()
        interactor.loadTasks() { [weak self] result in
            guard let self else { return }
            self.tasks = result

            self.view?.hideLoading()
            self.view?.updateView()
        }
    }

    func addButtonDidTap() {
        router.navigateToTaskDetails(with: nil)
    }

    func deleteTask(with index: Int) {
        interactor.deleteTask(tasks[index]) {[weak self] result in
            guard let self else { return }
            self.tasks = result
            self.view?.updateView()
        }
    }

    func searchTask(by searchText: String) {
        interactor.getTasks(with: searchText) {[weak self] result in
            guard let self else { return }
            self.tasks = result
            self.view?.updateView()
        }
    }

    func toggleTaskCompletion(at index: Int) {
        var task = tasks[index]
        task = task.complete()

        interactor.updateTaskState(task) { [weak self] in
            guard let self else { return }
            self.updateTaskList()
        }
    }

    func taskListDidChange() {
        updateTaskList()
    }
}
