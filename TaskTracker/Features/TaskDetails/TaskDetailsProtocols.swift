//
//  EditTaskProtocols.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 28.09.2025.
//

protocol TaskDetailsPresenterProtocol {
    func didLoad()
    func validateInput()
}

protocol TaskDetailsInteractorProtocol {
}

protocol TaskDetailsRouterProtocol {

}

protocol TaskDetailsViewControllerProtocol: AnyObject {
    func setupUI(taskName: String, taskDescription: String)
    func updateSaveButtonState(isEnabled: Bool)
}
