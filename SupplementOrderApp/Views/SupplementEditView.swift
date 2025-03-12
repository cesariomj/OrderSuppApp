import SwiftUI
import CoreData

struct SupplementEditView: View {
    @ObservedObject var supplement: Supplement
    let onSave: (Supplement) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: Binding(
                    get: { supplement.name ?? "" },
                    set: { supplement.name = $0.isEmpty ? nil : $0 }
                ))
                TextField("Price", value: $supplement.price, format: .number)
                    .keyboardType(.decimalPad)
                TextField("Dosage", text: Binding(
                    get: { supplement.dosage ?? "" },
                    set: { supplement.dosage = $0.isEmpty ? nil : $0 }
                ))
                TextField("Quantity", value: $supplement.quantity, format: .number)
                    .keyboardType(.numberPad)
                TextField("Type", text: Binding(
                    get: { supplement.type ?? "" },
                    set: { supplement.type = $0.isEmpty ? nil : $0 }
                ))
            }
            .navigationTitle("Edit Supplement")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(supplement)
                        dismiss()
                    }
                }
            }
        }
    }
}
