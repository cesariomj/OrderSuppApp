import Foundation

@objc(StringSetTransformer)
final class StringSetTransformer: NSSecureUnarchiveFromDataTransformer {
    static let name = NSValueTransformerName(rawValue: "StringSetTransformer")
    
    override static var allowedTopLevelClasses: [AnyClass] {
        return [NSSet.self, NSString.self]
    }
    
    public static func register() {
        ValueTransformer.setValueTransformer(StringSetTransformer(), forName: name)
    }
}
