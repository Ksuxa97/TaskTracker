//
//  EditTaskViewController.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 28.09.2025.
//
import UIKit

final class EditTaskViewController: UIViewController, EditTaskViewControllerProtocol {

    let presenter: EditTaskPresenterProtocol

    init(presenter: EditTaskPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
