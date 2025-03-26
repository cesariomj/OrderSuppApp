import SwiftUI
import CoreData

struct EditSupplementView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject private var supplement: Supplement
    @State private var isNewSupplement: Bool
    
    @State private var name: String
    @State private var dosage: String
    @State private var quantity: String
    @State private var selectedType: String
    @State private var customType: String = ""
    @State private var showCustomTypeField: Bool = false
    @State private var selectedCategories: Set<String> = []
    @State private var customCategory: String = ""
    @State private var showCustomCategoryField: Bool = false
    
    private let typeOptions = ["Capsules", "Liquid", "Tincture", "Add Custom"]
    private let predefinedCategoryOptions = [
        "Digestion", "Rash", "General", "Kidney", "Liver", "Stones", "Thyroid",
        "Cramps", "Hair", "Memory", "Eyes", "Joints", "Detox", "Fungal/Yeast",
        "Parasite", "Gall Bladder"
    ]
    @State private var categoryOptions: [String]
    
    @State private var showingStoreSheet = false
    
    init(supplement: Supplement? = nil) {
        let context = PersistenceController.shared.container.viewContext
        if let supplement = supplement {
            self.supplement = supplement
            _isNewSupplement = State(initialValue: false)
            _name = State(initialValue: supplement.name ?? "")
            _dosage = State(initialValue: supplement.dosage ?? "")
            _quantity = State(initialValue: String(supplement.quantity))
            _selectedType = State(initialValue: supplement.type ?? "")
            if let categories = supplement.categories as? Set<String> {
                _selectedCategories = State(initialValue: categories)
            }
        } else {
            let newSupplement = Supplement(context: context)
            newSupplement.id = UUID()
            self.supplement = newSupplement
            _isNewSupplement = State(initialValue: true)
            _name = State(initialValue: "")
            _dosage = State(initialValue: "")
            _quantity = State(initialValue: "")
            _selectedType = State(initialValue: "Capsules")
            _selectedCategories = State(initialValue: Set<String>())
        }
        _categoryOptions = State(initialValue: predefinedCategoryOptions)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Supplement Details")) {
                    TextField("Name", text: $name)
                    TextField("Dosage", text: $dosage)
                    TextField("Quantity", text: $quantity)
                        .keyboardType(.numberPad)
                    
                    Picker("Type", selection: $selectedType) {
                        ForEach(typeOptions, id: \.self) { option in
                            Text(option)
                        }
                        if !customType.isEmpty && !typeOptions.contains(customType) {
                            Text(customType).tag(customType)
                        }
                    }
                    .onChange(of: selectedType) { oldValue, newValue in
                        showCustomTypeField = (newValue == "Add Custom")
                        if !showCustomTypeField && newValue != "Add Custom" {
                            customType = newValue
                        }
                    }
                    
                    if showCustomTypeField {
                        TextField("Custom Type", text: $customType)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .submitLabel(.done)
                            .onSubmit {
                                if !customType.isEmpty {
                                    selectedType = customType
                                    showCustomTypeField = false
                                }
                            }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Categories")
                            .font(.headline)
                        ScrollView {
                            ForEach(categoryOptions, id: \.self) { category in
                                HStack {
                                    Image(systemName: selectedCategories.contains(category) ? "checkmark.square" : "square")
                                        .foregroundColor(.blue)
                                    Text(category)
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if selectedCategories.contains(category) {
                                        selectedCategories.remove(category)
                                    } else {
                                        selectedCategories.insert(category)
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: 200)
                        
                        HStack {
                            Button(action: {
                                showCustomCategoryField.toggle()
                            }) {
                                Text(showCustomCategoryField ? "Cancel" : "Add Custom Category")
                            }
                            Spacer()
                        }
                        
                        if showCustomCategoryField {
                            TextField("Custom Category", text: $customCategory)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .submitLabel(.done)
                                .onSubmit {
                                    if !customCategory.isEmpty && !categoryOptions.contains(customCategory) {
                                        categoryOptions.append(customCategory)
                                        selectedCategories.insert(customCategory)
                                        customCategory = ""
                                        showCustomCategoryField = false
                                    }
                                }
                        }
                        
                        Text("Selected: \(selectedCategories.sorted().joined(separator: ", "))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Section {
                    Button("Edit Stores") {
                        showingStoreSheet = true
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
                    .disabled(name.isEmpty)
                }
            }
            .sheet(isPresented: $showingStoreSheet) {
                SupplementStoreView(supplement: supplement)
            }
            .onDisappear {
                if isNewSupplement && !viewContext.hasChanges {
                    viewContext.delete(supplement)
                }
            }
        }
    }
    
    private func saveSupplement() {
        supplement.name = name
        supplement.dosage = dosage
        supplement.quantity = Int32(quantity) ?? 0
        supplement.type = selectedType
        supplement.categories = NSSet(set: selectedCategories)
        
        try? viewContext.save()
    }
}

struct EditSupplementView_Previews: PreviewProvider {
    static var previews: some View {
        EditSupplementView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
