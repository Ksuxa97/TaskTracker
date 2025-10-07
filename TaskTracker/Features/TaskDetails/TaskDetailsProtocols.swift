//
//  EditTaskProtocols.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 28.09.2025.
//

protocol TaskDetailsPresenterProtocol {
    func didLoad()
    func saveTask(with inputData: TaskInfo)
}

protocol TaskDetailsInteractorProtocol {
    func saveTask(task: Task?, with: TaskInfo, completion: @escaping () -> Void)
}

protocol TaskDetailsRouterProtocol {
    func popToRootVC()
}

protocol TaskDetailsViewControllerProtocol: AnyObject {
    func setupUI(task: Task?)
}
