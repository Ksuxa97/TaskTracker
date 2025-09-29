//
//  TaskListRouter.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 27.09.2025.
//
import UIKit

final class TaskListRouter: TaskListRouterProtocol {

    init() {
        
    }

    func navigateToEditTask(from view: UIViewController, with task: Task) {
        let editTaskPresenter = EditTaskPresenter()
        let editTaskVC = EditTaskViewController(presenter: editTaskPresenter)
        let editTaskRouter = EditTaskRouter()
        let editTaskInteractor = EditTaskInteractor()
        editTaskPresenter.view = editTaskVC
        editTaskPresenter.interactor = editTaskInteractor
        editTaskPresenter.router = editTaskRouter

        view.navigationController?.pushViewController(editTaskVC, animated: true)
    }

}
