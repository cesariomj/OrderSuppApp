import SwiftUI
import CoreData

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @FetchRequest(entity: DosageUnit.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \DosageUnit.name, ascending: true)])
    private var dosageUnits: FetchedResults<DosageUnit>
    
    @FetchRequest(entity: DosageFrequency.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \DosageFrequency.name, ascending: true)])
    private var dosageFrequencies: FetchedResults<DosageFrequency>
    
    @FetchRequest(entity: SupplementType.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \SupplementType.name, ascending: true)])
    private var supplementTypes: FetchedResults<SupplementType>
    
    @FetchRequest(entity: Category.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)])
    private var categories: FetchedResults<Category>
    
    @State private var newDosageUnit: String = ""
    @State private var newDosageFrequency: String = ""
    @State private var newSupplementType: String = ""
    @State private var newCategory: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Dosage Units")) {
                    ForEach(dosageUnits) { unit in
                        Text(unit.name ?? "Unknown")
                    }
                    .onDelete(perform: deleteDosageUnits)
                    TextField("New Dosage Unit", text: $newDosageUnit)
                    Button("Add Dosage Unit") {
                        addDosageUnit()
                    }
                    .disabled(newDosageUnit.isEmpty)
                }
                
                Section(header: Text("Dosage Frequencies")) {
                    ForEach(dosageFrequencies) { freq in
                        Text(freq.name ?? "Unknown")
                    }
                    .onDelete(perform: deleteDosageFrequencies)
                    TextField("New Frequency", text: $newDosageFrequency)
                    Button("Add Frequency") {
                        addDosageFrequency()
                    }
                    .disabled(newDosageFrequency.isEmpty)
                }
                
                Section(header: Text("Supplement Types")) {
                    ForEach(supplementTypes) { type in
                        Text(type.name ?? "Unknown")
                    }
                    .onDelete(perform: deleteSupplementTypes)
                    TextField("New Type", text: $newSupplementType)
                    Button("Add Type") {
                        addSupplementType()
                    }
                    .disabled(newSupplementType.isEmpty)
                }
                
                Section(header: Text("Categories")) {
                    ForEach(categories) { cat in
                        Text(cat.name ?? "Unknown")
                    }
                    .onDelete(perform: deleteCategories)
                    TextField("New Category", text: $newCategory)
                    Button("Add Category") {
                        addCategory()
                    }
                    .disabled(newCategory.isEmpty)
                }
            }
            .navigationTitle("Manage Options")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addDosageUnit() {
        let newUnit = DosageUnit(context: viewContext)
        newUnit.name = newDosageUnit
        newDosageUnit = ""
        try? viewContext.save()
    }
    
    private func addDosageFrequency() {
        let newFreq = DosageFrequency(context: viewContext)
        newFreq.name = newDosageFrequency
        newDosageFrequency = ""
        try? viewContext.save()
    }
    
    private func addSupplementType() {
        let newType = SupplementType(context: viewContext)
        newType.name = newSupplementType
        newSupplementType = ""
        try? viewContext.save()
    }
    
    private func addCategory() {
        let newCat = Category(context: viewContext)
        newCat.name = newCategory
        newCategory = ""
        try? viewContext.save()
    }
    
    private func deleteDosageUnits(at offsets: IndexSet) {
        offsets.map { dosageUnits[$0] }.forEach(viewContext.delete)
        try? viewContext.save()
    }
    
    private func deleteDosageFrequencies(at offsets: IndexSet) {
        offsets.map { dosageFrequencies[$0] }.forEach(viewContext.delete)
        try? viewContext.save()
    }
    
    private func deleteSupplementTypes(at offsets: IndexSet) {
        offsets.map { supplementTypes[$0] }.forEach(viewContext.delete)
        try? viewContext.save()
    }
    
    private func deleteCategories(at offsets: IndexSet) {
        offsets.map { categories[$0] }.forEach(viewContext.delete)
        try? viewContext.save()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
