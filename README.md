# EmailComposer Swift

**EmailComposer** is a Swift convenience class for composing emails both natively and in common 3rd party iOS email client apps.

So far EmailComposer supports Gmail (and Inbox) and Outlook (and Dispatch).

## Implementation

EmailComposer checks which email clients are available on a users device and will:
1. automatically present email compose if only one client is available
2. present an actionSheet of available mail clients if multiple are available
3. present an alert if no clients are available

**NOTE:** you must add query schemes to your info.plist under `LSApplicationQueriesSchemes` for each email client to work
Gmail = googlegmail, Inbox = inbox-gmail, Outlook = ms-outlook, Dispatch = x-dispatch

#### Compose an email

```swift
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
```

#### Open the users email client

```swift
// Opens the application for the available email client
let emailComposer = EmailComposer(rootViewController: self, sourceView: customView.openEmailButton)
emailComposer.openMail()
```

#### Adapt UI to email availability

```swift
let emailComposer = EmailComposer(rootViewController: self)
openMailButton.isHidden = !emailComposer.isEmailAvailable
```

#### Customize alert

```swift
let emailComposer = EmailComposer(rootViewController: self)
let availableClients = emailComposer.availableClients()

if let firstClient = availableClients.first, availableClients.count == 1 {
    firstClient.composeEmail()
} else if availableClients.count > 1 {

    // Optionally update your presented view instead of showing an alert
		// NOTE: `availableClients` will return .iosMail and .mail in some cases. You'll likely want to filter .mail out if .iosMail is returned
    let emailActionSheet = UIAlertController(title: "Choose email", message: "You have too many email clients. What do you want??", preferredStyle: .alert)

    var alertActions = availableClients.compactMap { (availableClient) -> UIAlertAction? in
        return UIAlertAction(title: availableClient.type.rawValue, style: .default, handler: { (alertAction) in
            availableClient.composeEmail()
        })
    }

    alertActions.append(UIAlertAction(title: "Cancel", style: .cancel))
    alertActions.forEach {
        emailActionSheet.addAction($0)
    }
    present(emailActionSheet, animated: true, completion: nil)
} else {

    let unavailableAlert = UIAlertController(
        title: "✉️ Email unavailable",
        message: "We support iOS Mail, Gmail, Inbox, Outlook, and Dispatch. Please log in with one of these.",
        preferredStyle: .alert
    )

    unavailableAlert.addAction(UIAlertAction(title: "OK", style: .default))
    present(unavailableAlert, animated: true, completion: nil)
}
```

#### Custom UI

```swift
let emailComposer = EmailComposer(rootViewController: self)
availableClients = emailComposer.availableClients()

tableView.reloadData()
emptyView.isHidden = availableClients.count != 0
```
