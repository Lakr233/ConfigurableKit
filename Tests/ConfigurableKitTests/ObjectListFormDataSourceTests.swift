@testable import ConfigurableKit
import Foundation
import Testing

@MainActor
struct ObjectListFormDataSourceTests {
    struct Contact: ObjectListFormItem {
        let id: UUID
        var name: String
        var email: String
        var phone: String

        func matches(query: String) -> Bool {
            name.localizedCaseInsensitiveContains(query)
        }

        static func createDefault() -> Contact {
            Contact(id: UUID(), name: "", email: "", phone: "")
        }

        static var formFields: [ObjectListField<Contact>] {
            [
                .text(id: "name", title: "Name", icon: "person", keyPath: \.name),
                .text(id: "email", title: "Email", icon: "envelope", keyPath: \.email),
                .text(id: "phone", title: "Phone", icon: "phone", keyPath: \.phone),
            ]
        }
    }

    @Test func detailShowsEachFieldOnItsOwnLine() {
        let contact = Contact(id: UUID(), name: "Ada", email: "ada@example.com", phone: "555 0100")
        let row = ObjectListFormDataSource(items: [contact]).rowPresentation(for: contact)
        #expect(row.title == "Ada")
        #expect(row.detail == "ada@example.com\n555 0100")
        #expect(!row.detail.contains("\u{00B7}"))
    }

    @Test func emptyFieldsLeaveNoBlankLine() {
        let contact = Contact(id: UUID(), name: "Ada", email: "", phone: "555 0100")
        let row = ObjectListFormDataSource(items: [contact]).rowPresentation(for: contact)
        #expect(row.detail == "555 0100")
    }
}
