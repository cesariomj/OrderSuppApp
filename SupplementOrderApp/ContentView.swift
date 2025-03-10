import SwiftUI

struct Supplement: Identifiable, Codable {
    var id: UUID
    var name: String
    var price: Double
    var dosage: String
    var quantity: Int
    var type: String
    var storeURL: String
    var supplementURL: String
    
    init(name: String, price: Double, dosage: String, quantity: Int, type: String, storeURL: String, supplementURL: String) {
        self.id = UUID()
        self.name = name
        self.price = price
        self.dosage = dosage
        self.quantity = quantity
        self.type = type
        self.storeURL = storeURL
        self.supplementURL = supplementURL
    }
}

struct CartItem: Identifiable, Codable {
    var id: UUID
    let supplement: Supplement
    var quantity: Int
    
    init(supplement: Supplement, quantity: Int) {
        self.id = UUID()
        self.supplement = supplement
        self.quantity = quantity
    }
}

struct ContentView: View {
    @State private var cart: [CartItem] = {
        if let data = UserDefaults.standard.data(forKey: "cart"),
           let savedCart = try? JSONDecoder().decode([CartItem].self, from: data) {
            return savedCart
        }
        return []
    }()
    @State private var orderList: [CartItem] = {
        if let data = UserDefaults.standard.data(forKey: "orderList"),
           let savedOrderList = try? JSONDecoder().decode([CartItem].self, from: data) {
            return savedOrderList
        }
        return []
    }()
    @State private var supplements = [
        Supplement(name: "Protein Powder", price: 29.99, dosage: "1 scoop daily", quantity: 30, type: "Powder", storeURL: "https://example.com/protein", supplementURL: "https://example.com/protein-info"),
        Supplement(name: "Vitamin D", price: 9.99, dosage: "1 capsule daily", quantity: 100, type: "Capsule", storeURL: "https://example.com/vitamind", supplementURL: "https://example.com/vitamind-info"),
        Supplement(name: "Omega-3 Fish Oil", price: 14.99, dosage: "2 capsules daily", quantity: 60, type: "Capsule", storeURL: "https://example.com/omega3", supplementURL: "https://example.com/omega3-info"),
        Supplement(name: "Multivitamin", price: 12.50, dosage: "1 tablet daily", quantity: 90, type: "Tablet", storeURL: "https://example.com/multi", supplementURL: "https://example.com/multi-info")
    ]
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            EditSupplementsView(supplements: $supplements, cart: $cart)
                .tabItem {
                    Label("Edit", systemImage: "pencil")
                }
            CartView(cart: $cart, saveCart: saveCart, addToOrderList: { items in orderList.append(contentsOf: items); saveOrderList() }, showCart: .constant(true), supplementIcon: supplementIcon)
                .tabItem {
                    Label("Cart", systemImage: "cart")
                }
            OrderListView(orderList: $orderList, saveOrderList: saveOrderList, showOrderList: .constant(true), supplementIcon: supplementIcon)
                .tabItem {
                    Label("Order List", systemImage: "list.bullet")
                }
        }
        .accentColor(.blue)
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.white]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }
    
    private func supplementIcon(for name: String) -> String {
        switch name {
        case "Protein Powder": return "drop.fill"
        case "Vitamin D": return "sun.max.fill"
        case "Omega-3 Fish Oil": return "fish.fill"
        case "Multivitamin": return "pills.fill"
        default: return "pill.fill"
        }
    }
    
    private func saveCart() {
        if let encoded = try? JSONEncoder().encode(cart) {
            UserDefaults.standard.set(encoded, forKey: "cart")
        }
    }
    
    private func saveOrderList() {
        if let encoded = try? JSONEncoder().encode(orderList) {
            UserDefaults.standard.set(encoded, forKey: "orderList")
        }
    }
}

struct HomeView: View {
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.white]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack {
                Image(systemName: "pills.fill") // Placeholder image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .foregroundColor(.blue)
                    .shadow(radius: 5)
                Text("Supplement Order")
                    .font(.largeTitle.bold())
                    .foregroundColor(.blue)
                    .padding(.top, 20)
                Text("Manage your supplements with ease!")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct EditSupplementsView: View {
    @Binding var supplements: [Supplement]
    @Binding var cart: [CartItem]
    @State private var editingSupplement: Supplement?
    @State private var addingSupplement = false
    
    var body: some View {
        NavigationStack {
            List($supplements) { $supplement in
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Image(systemName: supplementIcon(for: supplement.name))
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        Text(supplement.name)
                            .font(.headline)
                        Spacer()
                        Text("$\(supplement.price, specifier: "%.2f")")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Button(action: {
                            if let index = cart.firstIndex(where: { $0.supplement.id == supplement.id }) {
                                cart[index].quantity += 1
                            } else {
                                cart.append(CartItem(supplement: supplement, quantity: 1))
                            }
                        }) {
                            Text("Add")
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(LinearGradient(gradient: Gradient(colors: [.green, .teal]), startPoint: .leading, endPoint: .trailing))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(radius: 2)
                        }
                    }
                    Text("Dosage: \(supplement.dosage)")
                        .font(.caption)
                    Text("Quantity: \(supplement.quantity) \(supplement.type.lowercased())s")
                        .font(.caption)
                    HStack(spacing: 15) {
                        if let url = URL(string: supplement.storeURL) {
                            Text("Store")
                                .font(.caption)
                                .foregroundColor(.blue)
                                .onTapGesture {
                                    UIApplication.shared.open(url)
                                }
                        } else {
                            Text("Store (Invalid URL)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        if let url = URL(string: supplement.supplementURL) {
                            Text("Info")
                                .font(.caption)
                                .foregroundColor(.blue)
                                .onTapGesture {
                                    UIApplication.shared.open(url)
                                }
                        } else {
                            Text("Info (Invalid URL)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(10)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                .onTapGesture {
                    editingSupplement = supplement
                }
            }
            .navigationTitle("Edit Supplements")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        addingSupplement = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(item: $editingSupplement) { supplement in
                SupplementEditView(supplement: $supplements.first(where: { $0.id == supplement.id })!)
            }
            .sheet(isPresented: $addingSupplement) {
                AddSupplementView(supplements: $supplements)
            }
        }
    }
    
    private func supplementIcon(for name: String) -> String {
        switch name {
        case "Protein Powder": return "drop.fill"
        case "Vitamin D": return "sun.max.fill"
        case "Omega-3 Fish Oil": return "fish.fill"
        case "Multivitamin": return "pills.fill"
        default: return "pill.fill"
        }
    }
}

struct AddSupplementView: View {
    @Binding var supplements: [Supplement]
    @State private var newSupplement = Supplement(name: "", price: 0.0, dosage: "", quantity: 0, type: "Capsule", storeURL: "", supplementURL: "")
    let types = ["Capsule", "Tablet", "Powder", "Liquid"]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $newSupplement.name)
                TextField("Price", value: $newSupplement.price, format: .number)
                    .keyboardType(.decimalPad)
                TextField("Dosage", text: $newSupplement.dosage)
                TextField("Quantity", value: $newSupplement.quantity, format: .number)
                    .keyboardType(.numberPad)
                Picker("Type", selection: $newSupplement.type) {
                    ForEach(types, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
                TextField("Store URL", text: $newSupplement.storeURL)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                TextField("Supplement URL", text: $newSupplement.supplementURL)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
            }
            .navigationTitle("Add Supplement")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        supplements.append(newSupplement)
                        dismiss()
                    }
                    .disabled(newSupplement.name.isEmpty)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
