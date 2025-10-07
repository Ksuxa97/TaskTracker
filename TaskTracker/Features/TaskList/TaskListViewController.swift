//
//  TaskListViewController.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 27.09.2025.
//

import UIKit

final class TaskListViewController: UIViewController, TaskListViewControllerProtocol {

    private let presenter: TaskListPresenterProtocol

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.searchBarStyle = .minimal
        searchBar.showsCancelButton = false
        searchBar.tintColor = .systemYellow
        searchBar.searchTextField.textColor = .white
        searchBar.searchTextField.backgroundColor = .darkGray
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .black
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private let bottomBar: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.1, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let taskCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        button.tintColor = .systemYellow
        return button
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

    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Задачи"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.updateTaskList()
    }

    func updateView() {
        tableView.reloadData()
        taskCountLabel.text = "\(presenter.numberOfItems) Задач"
        taskCountLabel.setNeedsLayout()
        taskCountLabel.layoutIfNeeded()
    }

    // MARK: building List
    private func setupUI() {
        view.backgroundColor = .black
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Назад")
        navigationItem.backBarButtonItem?.tintColor = .systemYellow

        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TaskCell.self, forCellReuseIdentifier: TaskCell.reuseId)
        tableView.isUserInteractionEnabled = true

        view.addSubview(headerLabel)
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(bottomBar)

        bottomBar.addSubview(taskCountLabel)
        bottomBar.addSubview(addButton)

        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            searchBar.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 12),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            searchBar.heightAnchor.constraint(equalToConstant: 44),

            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 56),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 20),
            tableView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            taskCountLabel.centerXAnchor.constraint(equalTo: bottomBar.centerXAnchor),
            taskCountLabel.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),

            addButton.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),
            addButton.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -20),
            addButton.widthAnchor.constraint(equalToConstant: 28),
            addButton.heightAnchor.constraint(equalToConstant: 28)
        ])
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

    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let edit = UIAction(title: "Редактировать", image: UIImage(systemName: "square.and.pencil")) { _ in
                self.presenter.editTask(with: indexPath.row)
            }
            let share = UIAction(title: "Поделиться", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                self.presenter.shareTask(with: indexPath.row)
            }
            let delete = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                self.presenter.deleteTask(with: indexPath.row)
            }

            return UIMenu(title: "", children: [edit, share, delete])
        }
    }
}

extension TaskListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfItems
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskCell.reuseId, for: indexPath) as? TaskCell else {
            return UITableViewCell()
        }
        let item = presenter.getItem(with: indexPath.row)
        cell.configure(with: item) { [weak self] in
            self?.presenter.toggleTaskCompletion(at: indexPath.row)
        }
        
        return cell
    }
}

// MARK: Loader
extension TaskListViewController {

    private func setupLoadingView() {
        view.addSubview(loadingView)
        loadingView.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: tableView.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor),
            loadingView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor, constant: -20)
        ])
    }

    func showLoading() {
        self.loadingView.isHidden = false
        self.loadingIndicator.startAnimating()

        self.tableView.isUserInteractionEnabled = false
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }

    func hideLoading() {
        self.loadingIndicator.stopAnimating()
        self.loadingView.isHidden = true

        self.tableView.isUserInteractionEnabled = true
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
}

// MARK: SearchBar
extension TaskListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            presenter.searchTask(by: searchText)
            searchBar.resignFirstResponder()
        }
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        presenter.updateTaskList()
    }
}
