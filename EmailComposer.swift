//
//  EmailComposer.swift
//  Sprout Yard
//
//  Created by Tyson on 2018-08-17.
//  Copyright © 2018 Sprout Yard Mobile Inc. All rights reserved.
//

import UIKit
import MessageUI

struct AvailableClient {
    let type: EmailClient
    let composeEmail: ComposeEmailAction
}

/// Available EmailClients.
/// NOTE: you must add the query scheme to your info.plist under `LSApplicationQueriesSchemes` for these to work
/// Gmail = googlegmail, Inbox = inbox-gmail, Outlook = ms-outlook, Dispatch = x-dispatch
enum EmailClient: String {

    case iosMail = "iOS Mail" // MailComposeVC
    case gmail = "Gmail" // Gmail
    case inbox = "Inbox" // Also Gmail
    case outlook = "Outlook" // Outlook
    case dispatch = "Dispatch" // Also outlook
    case mail = "Mail" // Generic mail with mailto://

    static var ordered: [EmailClient] = [.iosMail, .gmail, .inbox, .outlook, .dispatch, .mail]

}

typealias ComposeEmailAction = () -> ()

private enum EmailClientActionType {
    case openURL(String)
    case openMailCompose
}

private extension EmailClient {

    var actionType: EmailClientActionType {

        switch self {
        case .iosMail:
            return .openMailCompose
        case .gmail:
            return .openURL("googlegmail:///")
        case .inbox:
            return .openURL("inbox-gmail://")
        case .outlook:
            return .openURL("ms-outlook://")
        case .dispatch:
            return .openURL("x-dispatch:///")
        case .mail:
            return .openURL("mailto:")
        }
    }

}

class EmailComposer {

    let rootViewController: UIViewController
    let sourceView: UIView?
    init(rootViewController: UIViewController, sourceView: UIView? = nil) {
        self.rootViewController = rootViewController
        self.sourceView = sourceView
    }

    /// Returns an array of `AvailableClient`s which can be used to display UI or to directly call `composeEmail`
    ///
    /// - Parameters:
    ///   - email: optional email of the recipient
    ///   - subject: optional subject line for the email
    ///   - body: optional body copy for the email. Note: due to Gmail/Inbox limitations
    ///           line-breaks are turned into spaces
    /// - Returns: an array of `AvailableClient`s
    func availableClients(forRecipient email: String? = nil,
                          subject: String? = nil,
                          body: String? = nil) -> [AvailableClient] {

        let clients = EmailClient.ordered.compactMap { (client) -> AvailableClient? in
            guard let action = self.composeEmailAction(
                forClient: client,
                withEmail: email,
                subject: subject,
                body: body) else { return nil }

            return AvailableClient(type: client, composeEmail: action)
        }

        return clients
    }


    /// Automatically presents email compose when only one client is available
    /// Presents a `UIAlertController` with `.actionSheet` style when there are multiple clients available
    /// Presents a `UIAlertController` with `.alert` style when there are no clients available
    /// Note: see availableClients(forRecipient, ... ) for email, subject, and body details
    func composeEmail(toRecipient email: String?, subject: String?, body: String?) {

        var clients = availableClients(forRecipient: email, subject: subject, body: body)

        let clientTypes = clients.map { (availableClient) -> EmailClient in
            return availableClient.type
        }

        if clientTypes.contains(.iosMail), clientTypes.contains(.mail) {
            clients = clients.filter({ (availableClient) -> Bool in
                availableClient.type != .mail // Don't show .mail if .iosMail already exists
            })
        }

        processAndCompose(clients)
    }


    /// Checks if the user has any AvailableClients on their device
    var isEmailAvailable: Bool {
        return availableClients().count > 0
    }

    /// Automatically opens email compose when only one client is available - filters out MFMailCompose
    func openMail() {

        let clients = availableClients(forRecipient: nil, subject: nil, body: nil).filter { (client) -> Bool in
            guard case EmailClientActionType.openURL(_) = client.type.actionType else { return false }
            return true
        }
        processAndCompose(clients)
    }

    private func processAndCompose(_ availableClients: [AvailableClient]) {

        if let firstClient = availableClients.first, availableClients.count == 1 {
            firstClient.composeEmail()
        } else if availableClients.count > 1 {

            let emailActionSheet = UIAlertController(title: "Choose email", message: nil, preferredStyle: .actionSheet)
            emailActionSheet.popoverPresentationController?.sourceView = sourceView

            var alertActions = availableClients.compactMap { (availableClient) -> UIAlertAction? in
                return UIAlertAction(title: availableClient.type.rawValue, style: .default, handler: { (alertAction) in
                    availableClient.composeEmail()
                })
            }

            alertActions.append(UIAlertAction(title: "Cancel", style: .cancel))
            alertActions.forEach {
                emailActionSheet.addAction($0)
            }
            rootViewController.present(emailActionSheet, animated: true, completion: nil)
        } else {

            let unavailableAlert = UIAlertController(
                title: "Email unavailable",
                message: "Please check that you're logged in to your email.",
                preferredStyle: .alert
            )

            unavailableAlert.addAction(UIAlertAction(title: "OK", style: .default))
            rootViewController.present(unavailableAlert, animated: true, completion: nil)
        }
    }
}

extension EmailComposer {

    private func composeEmailAction(forClient client: EmailClient,
                                    withEmail email: String?,
                                    subject: String?,
                                    body: String?) -> ComposeEmailAction? {

        switch client.actionType {
        case .openMailCompose:
            return presentMailComposeAction(withEmail: email, subject: subject, body: body)

        case .openURL(let baseURLString):
            guard let url = urlString(
                forClient: client,
                baseURLString: baseURLString,
                email: email,
                subject: subject,
                body: body) else { return nil }

            return openURLAction(withURL: url)
        }
    }

    private func urlString(forClient client: EmailClient,
                           baseURLString: String,
                           email: String?,
                           subject: String?,
                           body: String?) -> URL? {

        let escapedSubjectString: String? = {
            return subject?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        }()

        let escapedBodyString: String? = {
            return body?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        }()

        let composeString: String = {
            switch client {
            case .iosMail, .mail:
                return "?"
            case .gmail, .inbox:
                return "co?"
            case .outlook, .dispatch:
                return "compose?"
            }
        }()

        var baseURLString = baseURLString
        var encodedContentArray = [String]()

        switch client {
        case .iosMail:
            return nil
        case .gmail, .inbox, .outlook, .dispatch:
            let encodedEmail: String? = {
                guard let email = email else { return nil }
                return "to=\(email)"
            }()
            let encodedSubject: String? = {
                guard let subject = escapedSubjectString else { return nil }
                return "subject=\(subject)"
            }()
            let encodedBody: String? = {
                guard let body = escapedBodyString else { return nil }
                return "body=\(body)"
            }()
            encodedContentArray.append(contentsOf: [encodedEmail, encodedSubject, encodedBody].compactMap { $0 } )

        case .mail:
            if let email = escapedSubjectString {
                baseURLString += "\(email)"
            }
            let encodedSubject: String? = {
                guard let subject = escapedSubjectString else { return nil }
                return "subject=\(subject)"
            }()
            let encodedBody: String? = {
                guard let body = escapedBodyString else { return nil }
                return "body=\(body)"
            }()

            encodedContentArray.append(contentsOf: [encodedSubject, encodedBody].compactMap { $0 } )
        }

        let encodedCombined: String = encodedContentArray.joined(separator: "&")
        if !encodedCombined.isEmpty {
            let combinedURLString = baseURLString + "\(composeString)\(encodedCombined)"
            return URL(string: combinedURLString)
        }

        return URL(string: baseURLString)
    }

    fileprivate func presentMailComposeAction(withEmail email: String?,
                                              subject: String?,
                                              body: String?) -> ComposeEmailAction? {
        guard MFMailComposeViewController.canSendMail() else { return nil }

        return { // Do not use [weak self] so EmailComposer isn't kicked out of memory before presentation
            let viewController = MFMailComposeViewController()
            viewController.mailComposeDelegate = self.rootViewController
            if let email = email {
                viewController.setToRecipients([email])
            }
            if let subject = subject {
                viewController.setSubject(subject)
            }
            if let body = body {
                viewController.setMessageBody(body, isHTML: false)
            }

            self.rootViewController.present(viewController, animated: true, completion: nil)
        }
    }

    fileprivate func openURLAction(withURL url: URL) -> ComposeEmailAction? {
        guard UIApplication.shared.canOpenURL(url) else { return nil }

        return {
            UIApplication.shared.open(url, completionHandler: { (success) in })
        }
    }

}

extension UIViewController: MFMailComposeViewControllerDelegate {

    public func mailComposeController(_ controller: MFMailComposeViewController,
                                      didFinishWith result: MFMailComposeResult,
                                      error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

}

