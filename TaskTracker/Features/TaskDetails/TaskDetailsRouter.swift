//
//  TaskDetailsRouter.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 28.09.2025.
//
import UIKit

final class TaskDetailsRouter: TaskDetailsRouterProtocol {

    var view: TaskDetailsViewControllerProtocol?

    init(){
    }

    func popToRootVC() {
        guard let taskVC = view as? UIViewController else { return }
        guard let navigationController = taskVC.navigationController else { return }
        navigationController.popToRootViewController(animated: true)
    }
}
