import SwiftUI

struct SupplementEditView: View {
    @State private var supplement: Supplement // Local state, not binding
    let onSave: (Supplement) -> Void // Closure to save changes
    @Environment(\.dismiss) var dismiss
    let types = ["Capsule", "Tablet", "Powder", "Liquid"]
    @State private var newStoreName: String = ""
    @State private var newStoreURL: String = ""
    @State private var newInfoURL: String = ""
    
    init(supplement: Supplement, onSave: @escaping (Supplement) -> Void) {
        self._supplement = State(initialValue: supplement)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Supplement Details")) {
                    TextField("Name", text: $supplement.name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .submitLabel(.done)
                        .onChange(of: supplement.name) {
                            print("Name changed to: \(supplement.name)")
                        }
                    TextField("Price", value: $supplement.price, format: .number)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .submitLabel(.done)
                        .onChange(of: supplement.price) {
                            print("Price changed to: \(supplement.price)")
                        }
                    TextField("Dosage", text: $supplement.dosage)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .submitLabel(.done)
                        .onChange(of: supplement.dosage) {
                            print("Dosage changed to: \(supplement.dosage)")
                        }
                    TextField("Quantity", value: $supplement.quantity, format: .number)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .submitLabel(.done)
                        .onChange(of: supplement.quantity) {
                            print("Quantity changed to: \(supplement.quantity)")
                        }
                    Picker("Type", selection: $supplement.type) {
                        ForEach(types, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .onChange(of: supplement.type) {
                        print("Type changed to: \(supplement.type)")
                    }
                }
                Section(header: Text("Store Options")) {
                    ForEach($supplement.storeInfos) { $storeInfo in
                        VStack(alignment: .leading) {
                            TextField("Store Name", text: $storeInfo.name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .submitLabel(.done)
                            TextField("Store URL", text: $storeInfo.storeURL)
                                .keyboardType(.URL)
                                .autocapitalization(.none)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .submitLabel(.done)
                            TextField("Info URL", text: $storeInfo.infoURL)
                                .keyboardType(.URL)
                                .autocapitalization(.none)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .submitLabel(.done)
                        }
                    }
                    .onDelete { indices in
                        supplement.storeInfos.remove(atOffsets: indices)
                        print("Deleted store at indices: \(indices)")
                    }
                    VStack(alignment: .leading) {
                        TextField("New Store Name", text: $newStoreName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .submitLabel(.done)
                        TextField("New Store URL", text: $newStoreURL)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .submitLabel(.done)
                        TextField("New Info URL", text: $newInfoURL)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .submitLabel(.done)
                        Button("Add") {
                            let newStore = StoreInfo(name: newStoreName, storeURL: newStoreURL, infoURL: newInfoURL)
                            supplement.storeInfos.append(newStore)
                            print("Added store: \(newStore.name)")
                            newStoreName = ""
                            newStoreURL = ""
                            newInfoURL = ""
                        }
                        .disabled(newStoreName.isEmpty || newStoreURL.isEmpty || newInfoURL.isEmpty)
                    }
                }
            }
            .navigationTitle("Edit Supplement")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        print("Finished editing: \(supplement.name)")
                        onSave(supplement)
                        dismiss()
                    }
                }
            }
            .onAppear {
                print("Opened edit sheet for: \(supplement.name)")
            }
        }
    }
}
