import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
                
        let supplements: [(String, Double, String, Int32, String, [String], [(String, String, String, Double)])] = [
            ("Protein Powder", 29.99, "1 scoop daily", 30, "Powder", ["General", "Muscle"], [
                ("Amazon", "https://www.amazon.com/protein", "https://www.amazon.com/protein-reviews", 29.99),
                ("Walmart", "https://www.walmart.com/protein", "https://www.walmart.com/protein-reviews", 28.50)
            ]),
            ("Vitamin D", 9.99, "1 capsule daily", 100, "Capsule", ["General", "Bones"], [
                ("Amazon", "https://www.amazon.com/vitamind", "https://www.amazon.com/vitamind-reviews", 9.99)
            ])
        ]
        
        for (name, price, dosage, quantity, type, categories, stores) in supplements {
            let supplement = Supplement(context: viewContext)
            supplement.id = UUID()
            supplement.name = name
            supplement.price = price
            supplement.dosage = dosage
            supplement.quantity = quantity
            supplement.type = type
            supplement.categories = NSSet(set: Set(categories))
            
            for (storeName, storeURL, infoURL, storePrice) in stores {
                let storeInfo = StoreInfo(context: viewContext)
                storeInfo.id = UUID()
                storeInfo.name = storeName
                storeInfo.storeURL = storeURL
                storeInfo.infoURL = infoURL
                storeInfo.price = storePrice
                storeInfo.supplement = supplement
            }
        }
        
        do {
            try viewContext.save()
        } catch {
            fatalError("Failed to save preview data: \(error)")
        }
        
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "SupplementOrderApp")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        // Register the transformer and log it
        StringSetTransformer.register()
        print("Registered StringSetTransformer: \(ValueTransformer(forName: StringSetTransformer.name) != nil)")

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
