import SwiftUI

// Define Supplement struct
struct Supplement: Identifiable, Codable {
    var id: UUID
    let name: String
    let price: Double
    
    init(name: String, price: Double) {
        self.id = UUID()
        self.name = name
        self.price = price
    }
}

// Define CartItem struct
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
    @State private var showCart = false
    @State private var orderList: [CartItem] = {
        if let data = UserDefaults.standard.data(forKey: "orderList"),
           let savedOrderList = try? JSONDecoder().decode([CartItem].self, from: data) {
            return savedOrderList
        }
        return []
    }()
    @State private var showOrderList = false
    
    // Define supplements array
    let supplements = [
        Supplement(name: "Protein Powder", price: 29.99),
        Supplement(name: "Vitamin D", price: 9.99),
        Supplement(name: "Omega-3 Fish Oil", price: 14.99),
        Supplement(name: "Multivitamin", price: 12.50)
    ]
    
    var body: some View {
        NavigationStack {
            List(supplements) { supplement in
                HStack {
                    Image(systemName: supplementIcon(for: supplement.name))
                        .foregroundColor(.blue)
                        .frame(width: 30)
                    Text(supplement.name)
                        .font(.headline)
                        .foregroundColor(.primary)
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
                        saveCart()
                    }) {
                        Text("Add")
                            .font(.subheadline)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(LinearGradient(gradient: Gradient(colors: [.green, .mint]), startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .padding(.horizontal, 5)
            }
            .navigationTitle("Supplements")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Order List: \(orderList.count)") {
                        showOrderList = true
                    }
                    .foregroundColor(.purple)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cart: \(cart.count)") {
                        showCart = true
                    }
                    .foregroundColor(.blue)
                }
            }
            .sheet(isPresented: $showCart) {
                CartView(
                    cart: $cart,
                    saveCart: saveCart,
                    addToOrderList: { items in orderList.append(contentsOf: items); saveOrderList() },
                    showCart: $showCart,
                    supplementIcon: supplementIcon // Pass the function
                )
            }
            .sheet(isPresented: $showOrderList) {
                OrderListView(
                    orderList: $orderList,
                    saveOrderList: saveOrderList,
                    showOrderList: $showOrderList,
                    supplementIcon: supplementIcon // Pass the function
                )
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

#Preview {
    ContentView()
}
