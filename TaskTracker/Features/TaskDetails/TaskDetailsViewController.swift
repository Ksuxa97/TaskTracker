//
//  TaskDetailsViewController.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 28.09.2025.
//
import UIKit

final class TaskDetailsViewController: UIViewController, TaskDetailsViewControllerProtocol {

    let presenter: TaskDetailsPresenterProtocol

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let nameTextField: UITextField = {
       let field = UITextField()
       field.font = .systemFont(ofSize: 32, weight: .bold)
       field.textColor = .white
       field.placeholder = "Название"
       field.tintColor = .systemYellow
       field.translatesAutoresizingMaskIntoConstraints = false
       return field
   }()

        private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 18)
        textView.textColor = .white
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        return textView
    }()

    init(presenter: TaskDetailsPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        setupKeyboardObservers()
        presenter.didLoad()
        setupInputAccessory()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if nameTextField.text?.isEmpty == true {
            nameTextField.becomeFirstResponder()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let updatedTaskInfo = TaskInfo(name: nameTextField.text ?? "", description: descriptionTextView.text)
        presenter.saveTask(with: updatedTaskInfo)
    }

    func setupUI(task: Task?) {
        view.backgroundColor = .black

        nameTextField.delegate = self

        nameTextField.text = task?.name
        if let date = task?.createdAt {
            dateLabel.text = DateFormatter.ddMMYY.string(from: date)
        }
        descriptionTextView.text = task?.description ?? ""

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(nameTextField)
        contentView.addSubview(dateLabel)
        contentView.addSubview(descriptionTextView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),

            nameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            dateLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),

            descriptionTextView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            descriptionTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }

    private func setupInputAccessory() {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(doneButtonTapped))

        toolbar.items = [flexibleSpace, doneButton]
        toolbar.tintColor = .systemYellow
        descriptionTextView.inputAccessoryView = toolbar
    }
}

// MARK: Keyboard
extension TaskDetailsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            scrollView.contentInset.bottom = keyboardFrame.height
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
    }

    @objc private func doneButtonTapped() {
        descriptionTextView.resignFirstResponder()
    }
}
