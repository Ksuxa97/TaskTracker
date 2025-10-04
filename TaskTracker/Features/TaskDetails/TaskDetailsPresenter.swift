//
//  EditTaskPresenter.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 28.09.2025.
//

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
        view?.setupUI(taskName: task?.name ?? "", taskDescription: task?.description ?? "")
    }

    func saveTask(with inputData: TaskInfo) {
        interactor.saveTask(task: task, with: inputData) {
            self.delegate?.taskListDidChange()
        }
        router.popToRootVC()
    }

    func validateInput(inputData: TaskInfo) {
        let isInputDataChanged =
            task?.name != inputData.name ||
            task?.description != inputData.description

        let isValid = !inputData.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        view?.updateSaveButtonState(isEnabled: isInputDataChanged && isValid)
    }
}
