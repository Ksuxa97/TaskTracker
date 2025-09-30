//
//  TaskListProtocols.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 27.09.2025.
//
import UIKit

protocol TaskListPresenterProtocol {
    var numberOfItems: Int {get}
    func getItem(with index: Int) -> Task
    func updateTaskList()
    func didSelectTask(at index: Int)
    func addButtonDidTap()
}

protocol TaskListInteractorProtocol {
    func loadTasks(completion: @escaping ([Task]) -> Void)
    //func loadData(completion: @escaping (Result<ToDoListResponse, Error>) -> Void)
}

protocol TaskListRouterProtocol {
    func navigateToTaskDetails(from view: UIViewController, with task: Task?)
    func navigateToCreateTask(from view: UIViewController)
}

protocol TaskListViewControllerProtocol: AnyObject {
    func updateView()
    func showLoading()
    func hideLoading()
}

protocol TaskAddedDelegate {

}
