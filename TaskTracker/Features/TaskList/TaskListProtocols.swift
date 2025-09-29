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
}

protocol TaskListInteractorProtocol: AnyObject {
}

protocol TaskListRouterProtocol: AnyObject {
    func navigateToEditTask(from view: UIViewController, with task: Task)
}

protocol TaskListViewControllerProtocol: AnyObject {

}

protocol TaskAddedDelegate {

}
