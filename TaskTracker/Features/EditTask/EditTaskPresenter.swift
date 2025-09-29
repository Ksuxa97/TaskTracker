//
//  EditTaskPresenter.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 28.09.2025.
//

final class EditTaskPresenter: EditTaskPresenterProtocol {
    weak var view: EditTaskViewControllerProtocol?
    weak var interactor: EditTaskInteractorProtocol?
    weak var router: EditTaskRouterProtocol?

    init() {

    }
}
