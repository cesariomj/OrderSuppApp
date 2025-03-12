//
//  CartItem+CoreDataProperties.swift
//  SupplementOrderApp
//
//  Created by M1Chip MacBook Pro on 3/12/25.
//
//

import Foundation
import CoreData


extension CartItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CartItem> {
        return NSFetchRequest<CartItem>(entityName: "CartItem")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var quantity: Int32
    @NSManaged public var supplement: Supplement?
    @NSManaged public var selectedStoreInfo: StoreInfo?
    @NSManaged public var order: Order?

}

extension CartItem : Identifiable {

}
