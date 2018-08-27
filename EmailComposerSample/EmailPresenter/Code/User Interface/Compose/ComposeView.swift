//
//  ComposeView.swift
//  EmailPresenter
//
//  Created by Tyson on 2018-08-24.
//  Copyright © 2018 Sprout Yard. All rights reserved.
//

import UIKit

class ComposeView: UIView {

    init() {
        super.init(frame: .zero)

        addLayoutGuide(middleGuide)
        addSubview(composeButton)
        addSubview(openEmailButton)
        addSubview(attributionLabel)

        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    private func setupConstraints() {

        var constraints: [NSLayoutConstraint] = [

            middleGuide.centerXAnchor.constraint(equalTo: centerXAnchor),
            middleGuide.centerYAnchor.constraint(equalTo: centerYAnchor),
            middleGuide.heightAnchor.constraint(equalToConstant: 20),

            composeButton.bottomAnchor.constraint(equalTo: middleGuide.topAnchor),
            openEmailButton.topAnchor.constraint(equalTo: middleGuide.bottomAnchor),

            attributionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            attributionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            attributionLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ]

        for button in [composeButton, openEmailButton] as [UIButton] {

            let buttonConstraints: [NSLayoutConstraint] = [
                button.centerXAnchor.constraint(equalTo: centerXAnchor),
                button.heightAnchor.constraint(equalToConstant: 45),
                button.widthAnchor.constraint(equalToConstant: 180)
            ]

            constraints.append(contentsOf: buttonConstraints)
        }

        NSLayoutConstraint.activate(constraints)
    }

    // MARK: - Properties

    private let middleGuide = UILayoutGuide()

    private(set) lazy var composeButton: UIButton = {

        let button = createButton(title: "Compose")
        button.backgroundColor = UIColor(red: 40 / 255.0, green: 171 / 255.0, blue: 227 / 255.0, alpha: 1)
        return button
    }()

    private(set) lazy var openEmailButton: UIButton = {

        let button = createButton(title: "Open Mail")
        button.backgroundColor = UIColor(red: 31 / 255.0, green: 218 / 255.0, blue: 154 / 255.0, alpha: 1)
        return button
    }()

    private lazy var attributionLabel: UILabel = {

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Avenir-Medium", size: 12)
        label.textAlignment = .center

        let imageAttachment = NSTextAttachment()
        imageAttachment.image = #imageLiteral(resourceName: "mini_email")
        let imageString = NSAttributedString(attachment: imageAttachment)

        let mutableText = NSMutableAttributedString(attributedString: imageString)
        let text = NSAttributedString(string: "  Email icon by Numero Uno from the Noun Project")

        mutableText.append(text)
        label.attributedText = mutableText


        return label
    }()

    private func createButton(title: String) -> UIButton {

        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .highlighted)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 16)
        return button
    }
}
