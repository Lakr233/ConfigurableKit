//
//  UserListExample.swift
//  ConfigurableExample
//
//  Demonstrates ObjectListFormItem with a user management list.
//  Fields are declared once and drive both cell rendering and edit forms.
//

import Combine
import ConfigurableKit
import UIKit

// MARK: - Model

struct User: ObjectListFormItem {
    let id: UUID
    var name: String
    var email: String
    var role: String
    var isActive: Bool

    func matches(query: String) -> Bool {
        name.localizedCaseInsensitiveContains(query)
            || email.localizedCaseInsensitiveContains(query)
            || role.localizedCaseInsensitiveContains(query)
    }

    static func createDefault() -> User {
        User(id: UUID(), name: "", email: "", role: "viewer", isActive: true)
    }

    static let formFields: [ObjectListField<User>] = [
        .text(
            id: "name",
            title: "Name",
            icon: "person",
            keyPath: \.name,
            placeholder: "Enter name"
        ),
        .text(
            id: "email",
            title: "Email",
            icon: "envelope",
            keyPath: \.email,
            placeholder: "user@example.com"
        ),
        .picker(
            id: "role",
            title: "Role",
            icon: "person.badge.key",
            keyPath: \.role,
            options: [
                (title: "Admin", icon: "shield", value: "admin"),
                (title: "Editor", icon: "pencil", value: "editor"),
                (title: "Viewer", icon: "eye", value: "viewer"),
            ]
        ),
        .toggle(
            id: "active",
            title: "Active",
            icon: "checkmark.circle",
            keyPath: \.isActive
        ),
        .display(
            id: "id",
            title: "User ID",
            icon: "number",
            keyPath: \.id,
            formatter: { $0.uuidString.prefix(8).uppercased() + "..." }
        ),
    ]
}

// MARK: - Data Source

final class UserDataSource: ObjectListFormDataSource<User> {
    override init(items: [User] = []) {
        super.init(items: items)
    }

    override var sortCriteria: [ObjectListSortCriterion<User>] {
        [
            ObjectListSortCriterion(
                id: "name",
                title: "Name",
                icon: "textformat.abc"
            ) { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending },
            ObjectListSortCriterion(
                id: "role",
                title: "Role",
                icon: "person.badge.key"
            ) { $0.role < $1.role },
        ]
    }
}

// MARK: - Seed Data

@MainActor let demoUserDataSource = UserDataSource(items: [
    User(id: UUID(), name: "Alice Chen", email: "alice@example.com", role: "admin", isActive: true),
    User(id: UUID(), name: "Bob Smith", email: "bob@example.com", role: "editor", isActive: true),
    User(id: UUID(), name: "Charlie Davis", email: "charlie@example.com", role: "viewer", isActive: false),
    User(id: UUID(), name: "Diana Park", email: "diana@example.com", role: "editor", isActive: true),
])
