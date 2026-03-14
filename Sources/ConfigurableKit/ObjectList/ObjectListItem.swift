//
//  ObjectListItem.swift
//  ConfigurableKit
//
//  Protocol for items manageable by ObjectListViewController.
//

import Foundation

public protocol ObjectListItem: Identifiable, Hashable where ID == UUID {
    func matches(query: String) -> Bool
}
