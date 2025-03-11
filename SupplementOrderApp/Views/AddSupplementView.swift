import SwiftUI

struct AddSupplementView: View {
    @Binding var supplements: [Supplement]
    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""
    @State private var price: Double = 0.0
    @State private var dosage: String = ""
    @State private var quantity: Int = 0
    @State private var type: String = "Capsule"
    @State private var storeInfos: [StoreInfo] = []
    @State private var newStoreName: String = ""
    @State private var newStoreURL: String = ""
    @State private var newInfoURL: String = ""
    let types = ["Capsule", "Tablet", "Powder", "Liquid"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Supplement Details")) {
                    TextField("Name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Price", value: $price, format: .number)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Dosage", text: $dosage)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Quantity", value: $quantity, format: .number)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Picker("Type", selection: $type) {
                        ForEach(types, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                }
                Section(header: Text("Store Options")) {
                    ForEach(storeInfos) { storeInfo in
                        Text("\(storeInfo.name): \(storeInfo.storeURL)")
                    }
                    TextField("Store Name", text: $newStoreName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Store URL", text: $newStoreURL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Info URL", text: $newInfoURL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Add Store") {
                        let newStore = StoreInfo(name: newStoreName, storeURL: newStoreURL, infoURL: newInfoURL)
                        storeInfos.append(newStore)
                        print("Added store: \(newStore.name)")
                        newStoreName = ""
                        newStoreURL = ""
                        newInfoURL = ""
                    }
                    .disabled(newStoreName.isEmpty || newStoreURL.isEmpty || newInfoURL.isEmpty)
                }
            }
            .navigationTitle("Add Supplement")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        let newSupplement = Supplement(
                            name: name,
                            price: price,
                            dosage: dosage,
                            quantity: quantity,
                            type: type,
                            storeInfos: storeInfos
                        )
                        supplements.append(newSupplement)
                        print("Saved new supplement: \(newSupplement.name) with \(newSupplement.storeInfos.count) stores")
                        dismiss()
                    }
                    .disabled(name.isEmpty || dosage.isEmpty || quantity <= 0)
                }
            }
        }
    }
}
