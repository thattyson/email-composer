//
//  ComposeViewController.swift
//  EmailPresenter
//
//  Created by Tyson on 2018-08-21.
//  Copyright © 2018 Sprout Yard. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController {

    private let customView = ComposeView()

    // MARK: - Lifecycle

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = customView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        customView.composeButton.addTarget(self, action: #selector(composeEmail), for: .touchUpInside)
        customView.openEmailButton.addTarget(self, action: #selector(openEmail), for: .touchUpInside)
    }

    // MARK: - Actions

    @objc
    private func composeEmail() {

        let emailComposer = EmailComposer(rootViewController: self, sourceView: customView.composeButton)
        emailComposer.composeEmail(
            toRecipient: "test@test.com",
            subject: "How many emails do you get every day?",
            body: """
            I mean really, how many?

            Does anyone worry about sending sensitive data to this mystery address?

            K bye! ❤️
            """
        )
    }

    @objc
    private func openEmail() {

        let emailComposer = EmailComposer(rootViewController: self, sourceView: customView.openEmailButton)
        emailComposer.openMail()
    }
}

