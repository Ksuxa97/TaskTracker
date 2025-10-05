//
//  EditTaskViewController.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 28.09.2025.
//
import UIKit

final class TaskDetailsViewController: UIViewController, TaskDetailsViewControllerProtocol {

    let presenter: TaskDetailsPresenterProtocol

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.text = "Название:"
        return label
    }()

    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название"
        textField.borderStyle = .roundedRect
        textField.returnKeyType = .done
        return textField
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.text = "Описание:"
        return label
    }()

    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.textContainerInset = .init(top: 8, left: 8, bottom: 8, right: 8)
        textView.returnKeyType = .done
        return textView
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 8
        button.setTitle("Сохранить", for: .normal)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    init(presenter: TaskDetailsPresenterProtocol, title: String) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.didLoad()
    }

    func setupUI(taskName: String = "", taskDescription: String = "") {
        view.backgroundColor = .systemBackground

        nameTextField.text = taskName
        descriptionTextView.text = taskDescription
        descriptionTextView.delegate = self
        nameTextField.delegate = self

        view.addSubview(stackView)
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(nameTextField)
        stackView.addArrangedSubview(descriptionLabel)
        stackView.addArrangedSubview(descriptionTextView)
        stackView.addArrangedSubview(saveButton)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            stackView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        nameTextField.addTarget(self, action: #selector(fieldDidChange), for: .editingChanged)
        saveButton.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)
    }

    private func getFieldsData() -> TaskInfo {
        return TaskInfo(
            name: nameTextField.text ?? "",
            description: descriptionTextView.text ?? ""
        )
    }

    func updateSaveButtonState(isEnabled: Bool) {
        saveButton.isEnabled = isEnabled
    }

    @objc func fieldDidChange() {
        let inputData = getFieldsData()
        presenter.validateInput(inputData: inputData)
    }

    @objc private func saveButtonPressed() {
        let fieldsData = getFieldsData()
        presenter.saveTask(with: fieldsData)
    }
}

extension TaskDetailsViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let inputData = getFieldsData()
        presenter.validateInput(inputData: inputData)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

extension TaskDetailsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
