//
//  StoreInfo+CoreDataProperties.swift
//  SupplementOrderApp
//
//  Created by M1Chip MacBook Pro on 3/12/25.
//
//

import Foundation
import CoreData


extension StoreInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoreInfo> {
        return NSFetchRequest<StoreInfo>(entityName: "StoreInfo")
    }

    @NSManaged public var name: String?
    @NSManaged public var storeURL: String?
    @NSManaged public var infoURL: String?
    @NSManaged public var price: Double
    @NSManaged public var supplement: Supplement?
    @NSManaged public var cardItems: NSSet?

}

// MARK: Generated accessors for cardItems
extension StoreInfo {

    @objc(addCardItemsObject:)
    @NSManaged public func addToCardItems(_ value: CartItem)

    @objc(removeCardItemsObject:)
    @NSManaged public func removeFromCardItems(_ value: CartItem)

    @objc(addCardItems:)
    @NSManaged public func addToCardItems(_ values: NSSet)

    @objc(removeCardItems:)
    @NSManaged public func removeFromCardItems(_ values: NSSet)

}

extension StoreInfo : Identifiable {

}
