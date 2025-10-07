//
//  TaskCell.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 04.10.2025.
//

import UIKit

final class TaskCell: UITableViewCell {
    static let reuseId = "TaskCell"

    private let checkboxButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .systemGray3
        button.setImage(UIImage(systemName: "circle"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .light)
        label.textColor = .systemGray2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var toggleHandler: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        backgroundColor = .clear
        selectionStyle = .none
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {

        contentView.addSubview(checkboxButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(dateLabel)

        NSLayoutConstraint.activate([
            checkboxButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            checkboxButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            checkboxButton.widthAnchor.constraint(equalToConstant: 22),
            checkboxButton.heightAnchor.constraint(equalToConstant: 22),

            titleLabel.leadingAnchor.constraint(equalTo: checkboxButton.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),

            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),

            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 4),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])

        checkboxButton.addTarget(self, action: #selector(didTapCheckbox), for: .touchUpInside)
    }

    @objc private func didTapCheckbox() {
        toggleHandler?()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.attributedText = nil
        titleLabel.text = nil
        descriptionLabel.text = nil
        dateLabel.text = nil
        checkboxButton.setImage(UIImage(systemName: "circle"), for: .normal)
        checkboxButton.tintColor = .systemGray3
        toggleHandler = nil
    }


    func configure(with task: Task, onToggle: @escaping () -> Void) {
        toggleHandler = onToggle

        let imageName = task.isCompleted ? "checkmark.circle.fill" : "circle"
        checkboxButton.setImage(UIImage(systemName: imageName), for: .normal)
        checkboxButton.tintColor = task.isCompleted ? .systemYellow : .systemGray3

        titleLabel.text = task.name

        if task.isCompleted {
            let attributedTitle = NSMutableAttributedString(string: task.name)
            attributedTitle.addAttribute(.strikethroughStyle,
                                         value: NSUnderlineStyle.single.rawValue,
                                         range: NSRange(location: 0, length: task.name.count))
            titleLabel.attributedText = attributedTitle
            titleLabel.textColor = .systemGray2
            descriptionLabel.textColor = .systemGray
            //contentView.alpha = 0.7

        } else {
            titleLabel.attributedText = nil
            titleLabel.textColor = .white
            titleLabel.text = task.name
            descriptionLabel.textColor = .white
            //contentView.alpha = 1.0
        }

        descriptionLabel.text = task.description?.isEmpty == false ? task.description : "Без описания"
        dateLabel.textColor = .systemGray
        dateLabel.text = DateFormatter.ddMMYY.string(from: task.createdAt)
    }
}
