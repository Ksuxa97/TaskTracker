//
//  TaskListViewController.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 27.09.2025.
//

import UIKit

final class TaskListViewController: UIViewController, TaskListViewControllerProtocol, TaskAddedDelegate {
    private let presenter: TaskListPresenterProtocol
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(presenter: TaskListPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //presenter.updateTaskList()
        tableView.reloadData()
    }

    // MARK: building List
    private func setupUI() {
        title = "Список задач"
        view.backgroundColor = .systemBackground
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        tableView.isUserInteractionEnabled = true

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])

        setupNavigationBar()
    }

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
    }
}

// MARK: Navigation to other views
extension TaskListViewController {

    @objc private func addButtonTapped() {
        // переход на экран добавления

        //present(actionSheet, animated: true)
    }

}

// MARK: TableView operations

extension TaskListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.didSelectTask(at: indexPath.row)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _, _, completion in
            guard let self else { return }
//            self.presenter.deleteCosmeticRecord(at: indexPath.row)
//            self.presenter.updateCosmeticList()
            tableView.reloadData()
            completion(true)
        }

        deleteAction.backgroundColor = .systemRed
        deleteAction.image = UIImage(systemName: "trash")

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension TaskListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfItems
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = presenter.getItem(with: indexPath.row)
        
        let attributedString = NSMutableAttributedString()
        let title = NSAttributedString(string: item.name + "\n", attributes: [.font: UIFont.systemFont(ofSize: 18, weight: .medium)])
        let description = NSAttributedString(string: item.description ?? "" + "\n", attributes: [.font: UIFont.systemFont(ofSize: 17, weight: .regular)])
        let createdDate = NSAttributedString(string: item.createdAt.formatted(), attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .light)])
        attributedString.append(title)
        attributedString.append(description)
        attributedString.append(createdDate)

        var config = cell.defaultContentConfiguration()
        config.attributedText = attributedString
        config.secondaryTextProperties.numberOfLines = 0
        cell.contentConfiguration = config
        return cell
    }

    func newTaskDidAdded() {
        presenter.updateTaskList()
        tableView.reloadData()
    }
}
