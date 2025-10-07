//
//  TaskDetailsPresenter.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 28.09.2025.
//

import Foundation

final class TaskDetailsPresenter: TaskDetailsPresenterProtocol {
    weak var view: TaskDetailsViewControllerProtocol?
    weak var delegate: TaskAddedDelegate?

    private let interactor: TaskDetailsInteractorProtocol
    private let router: TaskDetailsRouterProtocol

    private var task: Task?
    
    init(
        interactor: TaskDetailsInteractorProtocol,
        router: TaskDetailsRouterProtocol,
        for task: Task? = nil
    ) {
        self.task = task
        self.interactor = interactor
        self.router = router
    }

    func didLoad() {
        view?.setupUI(task: task)
    }

    func saveTask(with inputData: TaskInfo) {
        interactor.saveTask(task: task, with: inputData) {
            self.delegate?.taskListDidChange()
        }
        router.popToRootVC()
    }
}
