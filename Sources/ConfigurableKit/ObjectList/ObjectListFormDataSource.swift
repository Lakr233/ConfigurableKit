//
//  ObjectListFormDataSource.swift
//  ConfigurableKit
//
//  A ready-made data source for ObjectListFormItem types.
//  Auto-generates cell rendering and create/edit forms from field descriptors.
//

import Combine
import Foundation

/// A data source that auto-generates ConfigurableKit forms from
/// `ObjectListFormItem.formFields`. Manages an in-memory array.
///
/// Subclass to customize storage, validation, or persistence.
@MainActor
open class ObjectListFormDataSource<Item: ObjectListFormItem>: ObjectListDataSource {
    open var items: [Item] = [] {
        didSet { changeSubject.send() }
    }

    private let changeSubject = PassthroughSubject<Void, Never>()
    public var dataDidChange: AnyPublisher<Void, Never> {
        changeSubject.eraseToAnyPublisher()
    }

    public init(items: [Item] = []) {
        self.items = items
    }

    // MARK: - Data Access

    open func item(for id: UUID) -> Item? {
        items.first { $0.id == id }
    }

    // MARK: - Row Presentation (auto from fields)

    open func rowPresentation(for item: Item) -> ObjectListRowPresentation {
        let fields = Item.formFields
        guard let primary = fields.first else {
            return .init(title: String(localized: "Untitled"))
        }

        let primaryValue = primary.displayValue(from: item)
        let titleText = primaryValue.isEmpty ? String(localized: "Untitled") : primaryValue

        let details = fields.dropFirst()
            .map { $0.displayValue(from: item) }
            .filter { !$0.isEmpty }
            .joined(separator: " · ")

        return .init(icon: primary.icon, title: titleText, detail: details)
    }

    // MARK: - Sort

    open var sortCriteria: [ObjectListSortCriterion<Item>] {
        []
    }

    // MARK: - CRUD (auto form generation)

    open func createItem(from viewController: CKViewController) async -> Item? {
        let defaultItem = Item.createDefault()
        return await presentForm(for: defaultItem, isNew: true, from: viewController)
    }

    open func editItem(_ item: Item, from viewController: CKViewController) async -> Item? {
        await presentForm(for: item, isNew: false, from: viewController)
    }

    open func removeItems(_ ids: Set<UUID>) {
        items.removeAll { ids.contains($0.id) }
    }

    open func moveItem(from sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex != destinationIndex,
              items.indices.contains(sourceIndex)
        else { return }
        let item = items.remove(at: sourceIndex)
        let dest = min(destinationIndex, items.count)
        items.insert(item, at: dest)
    }

    open func reorderItems(by orderedIDs: [UUID]) {
        let orderedItems = orderedIDs.compactMap(item(for:))
        guard !orderedItems.isEmpty else { return }

        let orderedSet = Set(orderedIDs)
        let remainingItems = items.filter { !orderedSet.contains($0.id) }
        items = orderedItems + remainingItems
    }

    // MARK: - Form Presentation

    private func presentForm(
        for item: Item,
        isNew: Bool,
        from viewController: CKViewController
    ) async -> Item? {
        await withUnsafeContinuation { (continuation: UnsafeContinuation<Item?, Never>) in
            let sessionID = "ObjectListForm.\(UUID().uuidString)"
            let tempStorage = InMemoryStorage()
            let fields = Item.formFields

            // Track whether the form was committed; if VC is popped without it, resume with nil
            let commitState = CommitState()

            // Build ConfigurableObjects from field descriptors
            var objects: [ConfigurableObject] = []
            for field in fields {
                if let editable = field.createEditableObject(keyPrefix: sessionID, item: item, storage: tempStorage) {
                    objects.append(editable)
                } else {
                    // Read-only field — show as a static label
                    objects.append(ConfigurableObject {
                        let view = ConfigurableView()
                        view.configure(icon: .image(optionalName: field.icon))
                        view.configure(title: field.title)
                        view.configure(description: String.LocalizationValue(
                            stringLiteral: field.displayValue(from: item)
                        ))
                        #if canImport(UIKit)
                            view.isUserInteractionEnabled = false
                            view.alpha = 0.6
                        #elseif canImport(AppKit)
                            view.alphaValue = 0.6
                        #endif
                        return view
                    })
                }
            }

            objects.append(
                ConfigurableObject(
                    icon: "checkmark.circle.fill",
                    title: isNew ? String.LocalizationValue("Create") : String.LocalizationValue("Save"),
                    ephemeralAnnotation: .action(handler: { [weak self] formViewController in
                        guard let self else { return }
                        guard !commitState.didCommit else { return }

                        commitState.didCommit = true
                        var result = item
                        for field in fields where field.isEditable {
                            field.applyValue(from: tempStorage, keyPrefix: sessionID, to: &result)
                        }

                        if isNew {
                            items.append(result)
                        } else if let idx = items.firstIndex(where: { $0.id == result.id }) {
                            items[idx] = result
                        }

                        continuation.resume(returning: result)
                        formViewController.ckClose(animated: true)
                    })
                )
            )

            let manifest = ConfigurableManifest(
                title: isNew
                    ? String.LocalizationValue("New Item")
                    : String.LocalizationValue("Edit"),
                list: objects
            )

            let editVC = ConfigurableViewController(manifest: manifest)
            editVC.title = isNew ? String(localized: "New Item") : String(localized: "Edit")

            // Resume with nil when the VC disappears without committing (back button)
            editVC.onDeinit = {
                if !commitState.didCommit {
                    continuation.resume(returning: nil)
                }
            }

            viewController.ckPush(editVC, animated: true)
        }
    }
}

// MARK: - Commit State

private final class CommitState: @unchecked Sendable {
    var didCommit = false
}

// MARK: - In-Memory Storage

/// Ephemeral key-value storage for form editing sessions.
private final class InMemoryStorage: KeyValueStorage {
    private var store: [String: Data] = [:]

    nonisolated(unsafe) static let valueUpdatePublisher = PassthroughSubject<(String, Data?), Never>()
    private let instancePublisher = PassthroughSubject<(String, Data?), Never>()

    var valueUpdatePublisher: PassthroughSubject<(String, Data?), Never> {
        instancePublisher
    }

    func value(forKey key: String) -> Data? {
        store[key]
    }

    func setValue(_ value: Data?, forKey key: String) {
        store[key] = value
        instancePublisher.send((key, value))
    }
}
