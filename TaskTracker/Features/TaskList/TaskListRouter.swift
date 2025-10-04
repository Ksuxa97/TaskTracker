//
//  TaskListRouter.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 27.09.2025.
//
import UIKit

final class TaskListRouter: TaskListRouterProtocol {

    var view: TaskListViewControllerProtocol?

    init(){
    }

    func navigateToTaskDetails(with task: Task?) {
        let TaskDetailsRouter = TaskDetailsRouter()
        let TaskDetailsInteractor = TaskDetailsInteractor(storage: StorageManager.shared)
        let TaskDetailsPresenter = TaskDetailsPresenter(interactor: TaskDetailsInteractor, router: TaskDetailsRouter, for: task)
        let TaskDetailsVC = TaskDetailsViewController(presenter: TaskDetailsPresenter, title: "Редактирать задачу")

        TaskDetailsPresenter.view = TaskDetailsVC
        TaskDetailsRouter.view = TaskDetailsVC

        guard let taskListVC = view as? UIViewController else { return }
        taskListVC.navigationController?.pushViewController(TaskDetailsVC, animated: true)
    }

    func navigateToCreateTask() {
        let TaskDetailsRouter = TaskDetailsRouter()
        let TaskDetailsInteractor = TaskDetailsInteractor(storage: StorageManager.shared)
        let TaskDetailsPresenter = TaskDetailsPresenter(interactor: TaskDetailsInteractor, router: TaskDetailsRouter)
        let TaskDetailsVC = TaskDetailsViewController(presenter: TaskDetailsPresenter, title: "Создать задачу")

        TaskDetailsPresenter.view = TaskDetailsVC
        TaskDetailsRouter.view = TaskDetailsVC

        guard let taskListVC = view as? UIViewController else { return }
        taskListVC.navigationController?.pushViewController(TaskDetailsVC, animated: true)
    }
}
