//
//  TaskListRouter.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 27.09.2025.
//
import UIKit

final class TaskListRouter: TaskListRouterProtocol {

    func navigateToTaskDetails(from view: UIViewController, with task: Task?) {
        let TaskDetailsPresenter = TaskDetailsPresenter(for: task)
        let TaskDetailsVC = TaskDetailsViewController(presenter: TaskDetailsPresenter, title: "Редактирать задачу")
        let TaskDetailsRouter = TaskDetailsRouter()
        let TaskDetailsInteractor = TaskDetailsInteractor()
        TaskDetailsPresenter.view = TaskDetailsVC
        TaskDetailsPresenter.interactor = TaskDetailsInteractor
        TaskDetailsPresenter.router = TaskDetailsRouter

        view.navigationController?.pushViewController(TaskDetailsVC, animated: true)
    }

    func navigateToCreateTask(from view: UIViewController) {
        let TaskDetailsPresenter = TaskDetailsPresenter()
        let TaskDetailsVC = TaskDetailsViewController(presenter: TaskDetailsPresenter, title: "Создать задачу")
        let TaskDetailsRouter = TaskDetailsRouter()
        let TaskDetailsInteractor = TaskDetailsInteractor()
        TaskDetailsPresenter.view = TaskDetailsVC
        TaskDetailsPresenter.interactor = TaskDetailsInteractor
        TaskDetailsPresenter.router = TaskDetailsRouter

        view.navigationController?.pushViewController(TaskDetailsVC, animated: true)
    }

}
