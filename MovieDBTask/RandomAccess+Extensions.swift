//
//  MovieDBAPI.swift
//  MovieDBTask
//
//  Created by Barath K on 13/05/22.
//

import Foundation
import UIKit

extension String: Identifiable {
    public var id: String {
        return self
    }
}

extension RandomAccessCollection where Self.Element: Identifiable {
    public func isLastItem<Item: Identifiable>(_ item: Item) -> Bool {
        guard !isEmpty else {
            return false
        }
        guard let itemIndex = lastIndex(where: { AnyHashable($0.id) == AnyHashable(item.id) }) else {
            return false
        }
        let distance = self.distance(from: itemIndex, to: endIndex)
        return distance == 1
    }

    public func indexItem<Item: Identifiable>(_ item: Item) -> Int {
        guard let itemIndex = lastIndex(where: { AnyHashable($0.id) == AnyHashable(item.id) }), let index = itemIndex as? Int, index >= 10 else {
            return -1
        }
        return Int(index / BussinessConstant.ItemCountPerPage) + 1
    }
}

struct BussinessConstant {
    static let ItemCountPerPage = 10
}
