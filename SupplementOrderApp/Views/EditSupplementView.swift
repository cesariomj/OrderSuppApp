import SwiftUI
import CoreData

struct EditSupplementView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject private var supplement: Supplement
    @State private var isNewSupplement: Bool
    
    @State private var name: String
    @State private var dosageAmount: String
    @State private var dosageUnit: String
    @State private var dosageFrequency: String
    @State private var quantity: String
    @State private var selectedType: String
    @State private var selectedCategories: Set<String>
    
    @FetchRequest(entity: DosageUnit.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \DosageUnit.name, ascending: true)])
    private var dosageUnits: FetchedResults<DosageUnit>
    
    @FetchRequest(entity: DosageFrequency.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \DosageFrequency.name, ascending: true)])
    private var dosageFrequencies: FetchedResults<DosageFrequency>
    
    @FetchRequest(entity: SupplementType.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \SupplementType.name, ascending: true)])
    private var supplementTypes: FetchedResults<SupplementType>
    
    @FetchRequest(entity: Category.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)])
    private var categories: FetchedResults<Category>
    
    @State private var showingStoreSheet = false
    @State private var showingSettingsSheet = false
    @State private var pickerRefreshID = UUID()
    
    init(supplement: Supplement? = nil) {
        let context = PersistenceController.shared.container.viewContext
        if let supplement = supplement {
            self.supplement = supplement
            _isNewSupplement = State(initialValue: false)
            _name = State(initialValue: supplement.name ?? "")
            
            let dosageComponents = supplement.dosage?.split(separator: " ") ?? []
            _dosageAmount = State(initialValue: dosageComponents.first.map(String.init) ?? "")
            _dosageUnit = State(initialValue: dosageComponents.dropFirst().first.map(String.init) ?? "mg")
            _dosageFrequency = State(initialValue: dosageComponents.dropFirst(2).joined(separator: " ").isEmpty ? "daily" : dosageComponents.dropFirst(2).joined(separator: " "))
            
            _quantity = State(initialValue: String(supplement.quantity))
            _selectedType = State(initialValue: supplement.type ?? "Capsules")
            if let categories = supplement.categories as? Set<Category> {
                _selectedCategories = State(initialValue: Set(categories.map { $0.name ?? "" }))
            } else {
                _selectedCategories = State(initialValue: Set<String>())
            }
        } else {
            let newSupplement = Supplement(context: context)
            newSupplement.id = UUID()
            self.supplement = newSupplement
            _isNewSupplement = State(initialValue: true)
            _name = State(initialValue: "")
            _dosageAmount = State(initialValue: "")
            _dosageUnit = State(initialValue: "mg")
            _dosageFrequency = State(initialValue: "daily")
            _quantity = State(initialValue: "")
            _selectedType = State(initialValue: "Capsules")
            _selectedCategories = State(initialValue: Set<String>())
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Supplement Details")) {
                    TextField("Name", text: $name)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Dosage")
                            .font(.headline)
                        HStack(spacing: 25) {
                            TextField("Amount", text: $dosageAmount)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 45)
                            Picker("Unit", selection: $dosageUnit) {
                                ForEach(dosageUnits, id: \.self) { unit in
                                    Text(unit.name ?? "Unknown")
                                        .tag(unit.name ?? "Unknown")
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 140)
                            Picker("Frequency", selection: $dosageFrequency) {
                                ForEach(dosageFrequencies, id: \.self) { freq in
                                    Text(freq.name ?? "Unknown")
                                        .tag(freq.name ?? "Unknown")
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 180) // Increased width to fit "Frequency" and "weekly"
                            .fixedSize(horizontal: true, vertical: false)
                        }
                    }
                    
                    TextField("Quantity", text: $quantity)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Picker("Type", selection: $selectedType) {
                        ForEach(supplementTypes, id: \.self) { type in
                            Text(type.name ?? "Unknown")
                                .tag(type.name ?? "Unknown")
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    VStack(alignment: .leading) {
                        Text("Categories")
                            .font(.headline)
                        ScrollView {
                            ForEach(categories, id: \.self) { category in
                                HStack {
                                    Image(systemName: selectedCategories.contains(category.name ?? "") ? "checkmark.square" : "square")
                                        .foregroundColor(.blue)
                                    Text(category.name ?? "Unknown")
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if selectedCategories.contains(category.name ?? "") {
                                        selectedCategories.remove(category.name ?? "")
                                    } else {
                                        selectedCategories.insert(category.name ?? "")
                                    }
                                    pickerRefreshID = UUID()
                                }
                            }
                        }
                        .frame(maxHeight: 200)
                    }
                }
                
                Section {
                    Button("Edit Stores") {
                        showingStoreSheet = true
                    }
                    Button("Manage Options") {
                        showingSettingsSheet = true
                    }
                }
            }
            .navigationTitle(isNewSupplement ? "Add Supplement" : "Edit Supplement")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveSupplement()
                        dismiss()
                    }
                    .disabled(name.isEmpty || dosageAmount.isEmpty)
                }
            }
            .sheet(isPresented: $showingStoreSheet) {
                SupplementStoreView(supplement: supplement)
            }
            .sheet(isPresented: $showingSettingsSheet) {
                SettingsView()
            }
            .id(pickerRefreshID)
            .onAppear {
                print("Dosage Units available: \(dosageUnits.map { $0.name ?? "nil" })")
                print("Dosage Frequencies available: \(dosageFrequencies.map { $0.name ?? "nil" })")
                print("Supplement Types available: \(supplementTypes.map { $0.name ?? "nil" })")
            }
        }
    }
    
    private func saveSupplement() {
        supplement.name = name
        supplement.dosage = "\(dosageAmount) \(dosageUnit) \(dosageFrequency)".trimmingCharacters(in: .whitespaces)
        supplement.quantity = Int32(quantity) ?? 0 // Ensure quantity updates
        supplement.type = selectedType
        supplement.categories = NSSet(array: categories.filter { selectedCategories.contains($0.name ?? "") })
        
        do {
            try viewContext.save()
            print("Saved supplement with dosage: \(supplement.dosage ?? "N/A"), quantity: \(supplement.quantity)")
        } catch {
            print("Failed to save supplement: \(error)")
        }
    }
}

struct EditSupplementView_Previews: PreviewProvider {
    static var previews: some View {
        EditSupplementView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
