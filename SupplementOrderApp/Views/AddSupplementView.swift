import SwiftUI
import CoreData

struct AddSupplementView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var price = ""
    @State private var dosage = ""
    @State private var quantity = ""
    @State private var type = ""
    @Binding var supplements: [Supplement] // Placeholder for now

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Name", text: $name)
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
                    TextField("Dosage", text: $dosage)
                    TextField("Quantity", text: $quantity)
                        .keyboardType(.numberPad)
                    TextField("Type", text: $type)
                } header: {
                    Text("Supplement Details")
                }
            }
            .navigationTitle("Add Supplement")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let supplement = Supplement(context: viewContext)
                        supplement.id = UUID() // New id attribute
                        supplement.name = name
                        supplement.price = Double(price) ?? 0.0
                        supplement.dosage = dosage
                        supplement.quantity = Int32(quantity) ?? 0
                        supplement.type = type
                        try? viewContext.save()
                        dismiss()
                    }
                }
            }
        }
    }
}
