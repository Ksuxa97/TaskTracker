//
//  TaskListViewController.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 27.09.2025.
//

import UIKit
import CoreData

final class TaskListViewController: UIViewController, TaskListViewControllerProtocol, TaskAddedDelegate {

    private let presenter: TaskListPresenterProtocol

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchTextField.backgroundColor = .systemBackground
        searchBar.placeholder = "Поиск"
        searchBar.searchBarStyle = .minimal
        searchBar.showsCancelButton = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()

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

        searchBar.delegate = self
        view.addSubview(searchBar)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        tableView.isUserInteractionEnabled = true

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            searchBar.heightAnchor.constraint(equalToConstant: 44),
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 20),
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
            self.presenter.taskDidSwipe(with: indexPath.row)
            completion(true)
        }

        deleteAction.backgroundColor = .systemRed
        deleteAction.image = UIImage(systemName: "trash")

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    func deleteRow(at index: Int) {
        tableView.performBatchUpdates {
            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
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
        let title = NSAttributedString(string: "\(item.name)\n", attributes: [.font: UIFont.systemFont(ofSize: 18, weight: .medium)])
        let description = NSAttributedString(string: "\(item.description ?? "No description")\n", attributes: [.font: UIFont.systemFont(ofSize: 17, weight: .regular)])
        let createdDate = NSAttributedString(string: "\(item.createdAt.formatted())\n", attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .light)])
        attributedString.append(title)
        attributedString.append(description)
        attributedString.append(createdDate)

        var config = cell.defaultContentConfiguration()
        config.attributedText = attributedString
        config.secondaryTextProperties.numberOfLines = 0
        cell.contentConfiguration = config
        return cell
    }

    func taskListDidChange() {
        presenter.updateTaskList()
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
    }
}
