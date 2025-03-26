import SwiftUI
import CoreData

struct SupplementStoreView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var supplement: Supplement
    
    @State private var newStoreName = ""
    @State private var newStoreURL = ""
    @State private var newInfoURL = ""
    @State private var newStorePrice = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Current Stores")) {
                    if let stores = supplement.storeInfos?.allObjects as? [StoreInfo], !stores.isEmpty {
                        ForEach(stores) { store in
                            VStack(alignment: .leading) {
                                Text(store.name ?? "Unnamed Store")
                                Text("Price: \(store.price, specifier: "%.2f")")
                                Link(store.storeURL ?? "", destination: URL(string: store.storeURL ?? "")!)
                                    .font(.caption)
                            }
                        }
                        .onDelete(perform: deleteStore)
                    } else {
                        Text("No stores added yet.")
                            .foregroundColor(.gray)
                    }
                }
                
                Section(header: Text("Add New Store")) {
                    TextField("Store Name", text: $newStoreName)
                    TextField("Store URL", text: $newStoreURL)
                    TextField("Info URL", text: $newInfoURL)
                    TextField("Price", text: $newStorePrice)
                        .keyboardType(.decimalPad)
                    Button("Add Store") {
                        addStore()
                    }
                    .disabled(newStoreName.isEmpty || newStoreURL.isEmpty || newStorePrice.isEmpty)
                }
            }
            .navigationTitle("Stores for \(supplement.name ?? "Supplement")")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addStore() {
        let storeInfo = StoreInfo(context: viewContext)
        storeInfo.id = UUID()
        storeInfo.name = newStoreName
        storeInfo.storeURL = newStoreURL
        storeInfo.infoURL = newInfoURL
        storeInfo.price = Double(newStorePrice) ?? 0.0
        storeInfo.supplement = supplement
        
        newStoreName = ""
        newStoreURL = ""
        newInfoURL = ""
        newStorePrice = ""
        
        try? viewContext.save()
    }
    
    private func deleteStore(at offsets: IndexSet) {
        if let stores = supplement.storeInfos?.allObjects as? [StoreInfo] {
            offsets.forEach { index in
                viewContext.delete(stores[index])
            }
            try? viewContext.save()
        }
    }
}

struct SupplementStoreView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let supplement = Supplement(context: context)
        supplement.name = "Test Supplement"
        return SupplementStoreView(supplement: supplement)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
