import Foundation

struct Supplement: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var price: Double // Ensure not NaN
    var dosage: String
    var quantity: Int
    var type: String
    var storeInfos: [StoreInfo]
    
    init(id: UUID = UUID(), name: String, price: Double, dosage: String, quantity: Int, type: String, storeInfos: [StoreInfo]) {
        self.id = id
        self.name = name
        self.price = price.isNaN ? 0.0 : price // Safeguard
        self.dosage = dosage
        self.quantity = quantity
        self.type = type
        self.storeInfos = storeInfos
    }
    
    static func == (lhs: Supplement, rhs: Supplement) -> Bool {
        return lhs.id == rhs.id
    }
}

struct StoreInfo: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var storeURL: String
    var infoURL: String
    var price: Double?
    
    init(id: UUID = UUID(), name: String, storeURL: String, infoURL: String, price: Double? = nil) {
        self.id = id
        self.name = name
        self.storeURL = storeURL
        self.infoURL = infoURL
        self.price = price
    }
    
    // Equatable conformance
    static func == (lhs: StoreInfo, rhs: StoreInfo) -> Bool {
        return lhs.id == rhs.id
    }
}

struct CartItem: Codable, Identifiable, Equatable {
    let id: UUID
    let supplement: Supplement
    var selectedStoreInfo: StoreInfo
    var quantity: Int
    
    init(id: UUID = UUID(), supplement: Supplement, selectedStoreInfo: StoreInfo, quantity: Int) {
        self.id = id
        self.supplement = supplement
        self.selectedStoreInfo = selectedStoreInfo
        self.quantity = quantity
    }
    
    // Equatable conformance
    static func == (lhs: CartItem, rhs: CartItem) -> Bool {
        return lhs.id == rhs.id
    }
}
