import UIKit

extension UIApplication {
    override open var next: UIResponder? {
        UITextField.appearance().inputAssistantItem.leadingBarButtonGroups = []
        UITextField.appearance().inputAssistantItem.trailingBarButtonGroups = []

        UITextView.appearance().inputAssistantItem.leadingBarButtonGroups = []
        UITextView.appearance().inputAssistantItem.trailingBarButtonGroups = []

        return super.next
    }
}
