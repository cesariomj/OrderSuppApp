// Add this new view inside ContentView.swift, below the imports and structs
import SwiftUI

struct SupplementEditView: View {
    @Binding var supplement: Supplement
    @Environment(\.dismiss) var dismiss
    
    let types = ["Capsule", "Tablet", "Powder", "Liquid"] // Options for type picker
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $supplement.name)
                TextField("Price", value: $supplement.price, format: .number)
                    .keyboardType(.decimalPad)
                TextField("Dosage", text: $supplement.dosage)
                TextField("Quantity", value: $supplement.quantity, format: .number)
                    .keyboardType(.numberPad)
                Picker("Type", selection: $supplement.type) {
                    ForEach(types, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
                TextField("Store URL", text: $supplement.storeURL)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                TextField("Supplement URL", text: $supplement.supplementURL)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
            }
            .navigationTitle("Edit Supplement")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

