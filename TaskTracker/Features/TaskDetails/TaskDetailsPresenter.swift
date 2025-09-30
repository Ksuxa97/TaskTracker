//
//  EditTaskPresenter.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 28.09.2025.
//

final class TaskDetailsPresenter: TaskDetailsPresenterProtocol {
    weak var view: TaskDetailsViewControllerProtocol?
    var interactor: TaskDetailsInteractorProtocol?
    var router: TaskDetailsRouterProtocol?

    private var task: Task?
    
    init(for task: Task? = nil) {
        self.task = task
    }

    func didLoad() {
        view?.setupUI(taskName: task?.name ?? "", taskDescription: task?.taskDescription ?? "")
    }

    func validateInput() {
//        let isInputDataChanged =
//            prefilledData?.name != inputData.name ||
//            prefilledData?.brand != inputData.brand ||
//            prefilledData?.productionDate != inputData.productionDate ||
//            prefilledData?.openDate != inputData.openDate ||
//            prefilledData?.expiryDate != inputData.expiryDate
//
//        let isValid = [inputData.name, inputData.productionDate, inputData.expiryDate]
//            .map { $0?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "" }
//            .allSatisfy { !$0.isEmpty }
        view?.updateSaveButtonState(isEnabled: true)
    }
}
