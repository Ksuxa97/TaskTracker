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

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .systemGray
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private let loadingView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        setupLoadingView()
        presenter.updateTaskList()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.updateTaskList()
    }

    func updateView() {
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
        navigationItem.backButtonDisplayMode = .minimal
        navigationItem.backButtonTitle = "" 
    }
}

// MARK: Navigation to other views
extension TaskListViewController {
    @objc private func addButtonTapped() {
        presenter.addButtonDidTap()
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
        let title = NSAttributedString(string: "\(item.name ?? "No name")\n", attributes: [.font: UIFont.systemFont(ofSize: 18, weight: .medium)])
        let description = NSAttributedString(string: "\(item.taskDescription ?? "No description")\n", attributes: [.font: UIFont.systemFont(ofSize: 17, weight: .regular)])
        let createdDate = NSAttributedString(string: "\(item.createdAt?.formatted() ?? "No open date")\n", attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .light)])
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

// MARK: Loader
extension TaskListViewController {

    private func setupLoadingView() {
        view.addSubview(loadingView)
        loadingView.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor, constant: -20)
        ])
    }

    func showLoading() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            self.loadingView.isHidden = false
            self.loadingIndicator.startAnimating()

            self.tableView.isUserInteractionEnabled = false
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }

    func hideLoading() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            self.loadingIndicator.stopAnimating()
            self.loadingView.isHidden = true
            
            self.tableView.isUserInteractionEnabled = true
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
}
