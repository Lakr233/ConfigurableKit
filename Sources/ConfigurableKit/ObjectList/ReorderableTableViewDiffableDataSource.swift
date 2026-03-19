//
//  ReorderableTableViewDiffableDataSource.swift
//  ConfigurableKit
//

import UIKit

final class ReorderableTableViewDiffableDataSource<SectionIdentifierType: Hashable & Sendable, ItemIdentifierType: Hashable & Sendable>:
    UITableViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>
{
    var canReorderItem: ((ItemIdentifierType) -> Bool)?
    var onReorderedItems: (([ItemIdentifierType]) -> Void)?

    override func tableView(_: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        guard let item = itemIdentifier(for: indexPath) else { return false }
        return canReorderItem?(item) ?? true
    }

    override func tableView(
        _: UITableView,
        moveRowAt sourceIndexPath: IndexPath,
        to destinationIndexPath: IndexPath
    ) {
        guard let fromItem = itemIdentifier(for: sourceIndexPath),
              sourceIndexPath != destinationIndexPath
        else { return }

        var currentSnapshot = snapshot()
        currentSnapshot.deleteItems([fromItem])

        if let toItem = itemIdentifier(for: destinationIndexPath) {
            if destinationIndexPath.row > sourceIndexPath.row {
                currentSnapshot.insertItems([fromItem], afterItem: toItem)
            } else {
                currentSnapshot.insertItems([fromItem], beforeItem: toItem)
            }
        } else if currentSnapshot.sectionIdentifiers.indices.contains(sourceIndexPath.section) {
            let section = currentSnapshot.sectionIdentifiers[sourceIndexPath.section]
            currentSnapshot.appendItems([fromItem], toSection: section)
        }

        onReorderedItems?(currentSnapshot.itemIdentifiers)
        apply(currentSnapshot, animatingDifferences: false)
    }
}
