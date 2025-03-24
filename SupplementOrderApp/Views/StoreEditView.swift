import SwiftUI
import CoreData

struct StoreEditView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var supplement: Supplement
    
    @State private var stores: [StoreInfo] = []
    @State private var addingStore = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(stores.indices, id: \.self) { index in
                    VStack(alignment: .leading) {
                        TextField("Store Name", text: Binding(
                            get: { stores[index].name ?? "" },
                            set: { stores[index].name = $0.isEmpty ? nil : $0 }
                        ))
                        TextField("Store URL", text: Binding(
                            get: { stores[index].storeURL ?? "" },
                            set: { stores[index].storeURL = $0.isEmpty ? nil : $0 }
                        ))
                        TextField("Info URL", text: Binding(
                            get: { stores[index].infoURL ?? "" },
                            set: { stores[index].infoURL = $0.isEmpty ? nil : $0 }
                        ))
                        TextField("Price", value: $stores[index].price, format: .number)
                            .keyboardType(.decimalPad)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: deleteStores)
            }
            .navigationTitle("Edit Stores for \(supplement.name ?? "Supplement")")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Add Store") {
                        addingStore = true
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveStores()
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $addingStore) {
                AddStoreView(stores: $stores)
            }
            .onAppear {
                if let storeInfos = supplement.storeInfos as? Set<StoreInfo> {
                    stores = storeInfos.sorted { $0.name ?? "" < $1.name ?? "" }
                }
            }
        }
    }
    
    private func deleteStores(at offsets: IndexSet) {
        offsets.forEach { index in
            viewContext.delete(stores[index])
            stores.remove(at: index)
        }
        saveStores()
    }
    
    private func saveStores() {
        supplement.storeInfos = NSSet(array: stores)
        do {
            try viewContext.save()
        } catch {
            print("Failed to save stores: \(error)")
        }
    }
}

struct AddStoreView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var stores: [StoreInfo]
    
    @State private var name = ""
    @State private var storeURL = ""
    @State private var infoURL = ""
    @State private var price: Double = 0.0
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Store Name", text: $name)
                TextField("Store URL", text: $storeURL)
                TextField("Info URL", text: $infoURL)
                TextField("Price", value: $price, format: .number)
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("Add Store")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { // Fixed typo: Removed 'Pharmacy'
                    Button("Save") {
                        let newStore = StoreInfo(context: stores.first?.managedObjectContext ?? NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType))
                        newStore.id = UUID()
                        newStore.name = name.isEmpty ? nil : name
                        newStore.storeURL = storeURL.isEmpty ? nil : storeURL
                        newStore.infoURL = infoURL.isEmpty ? nil : infoURL
                        newStore.price = price
                        stores.append(newStore)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    StoreEditView(supplement: {
        let context = PersistenceController.preview.container.viewContext
        let supplement = Supplement(context: context)
        supplement.name = "Test Supplement"
        return supplement
    }())
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
