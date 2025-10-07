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
    func addButtonDidTap()
    func editTask(with index: Int)
    func shareTask(with index: Int)
    func deleteTask(with index: Int)
    func searchTask(by searchText: String)
    func toggleTaskCompletion(at index: Int)
}

protocol TaskListInteractorProtocol {
    func loadTasks(completion: @escaping ([Task]) -> Void)
    func deleteTask(_ task: Task, completion: @escaping ([Task]) -> Void)
    func getTasks(with text: String, completion: @escaping ([Task]) -> Void)
    func updateTaskState(_ task: Task, completion: @escaping () -> Void)
}

protocol TaskListRouterProtocol {
    func navigateToTaskDetails(with task: Task?)
    func navigateToCreateTask()
}

protocol TaskListViewControllerProtocol: AnyObject {
    func updateView()
    func showLoading()
    func hideLoading()
}

protocol TaskAddedDelegate: AnyObject {
    func taskListDidChange()
}
