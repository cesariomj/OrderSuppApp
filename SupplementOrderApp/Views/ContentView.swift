import SwiftUI
import CoreData
import SwiftSoup

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CartItem.supplement?.name, ascending: true)],
        predicate: NSPredicate(format: "order == nil"),
        animation: .default)
    private var cart: FetchedResults<CartItem>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Order.dateOrdered, ascending: false)],
        animation: .default)
    private var orders: FetchedResults<Order>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Supplement.name, ascending: true)],
        animation: .default)
    private var supplements: FetchedResults<Supplement>

    @State private var selectedTab = "Home" // Track the selected menu item

    var body: some View {
        ZStack {
            // Background
            VStack(spacing: 0) {
                Color.blue.opacity(0.1) // Solid light blue for the top inch
                    .frame(height: 100) // Roughly an inch, adjust if needed
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.white]), startPoint: .top, endPoint: .bottom)
            }
            .ignoresSafeArea()

            // Content based on selected tab
            VStack {
                // Custom Oval Menu at the Top
                HStack(spacing: 20) {
                    Text("Home")
                        .font(.system(size: 34)) // Doubled from ~17 to 34
                        .padding(8)
                        .background(selectedTab == "Home" ? Color.white : Color.clear)
                        .cornerRadius(8)
                        .onTapGesture { selectedTab = "Home" }
                    Text("Edit")
                        .font(.system(size: 34))
                        .padding(8)
                        .background(selectedTab == "Edit" ? Color.white : Color.clear)
                        .cornerRadius(8)
                        .onTapGesture { selectedTab = "Edit" }
                    Text("Cart")
                        .font(.system(size: 34))
                        .padding(8)
                        .background(selectedTab == "Cart" ? Color.white : Color.clear)
                        .cornerRadius(8)
                        .onTapGesture { selectedTab = "Cart" }
                    Text("Order List")
                        .font(.system(size: 34))
                        .padding(8)
                        .background(selectedTab == "Order List" ? Color.white : Color.clear)
                        .cornerRadius(8)
                        .onTapGesture { selectedTab = "Order List" }
                }
                .padding()
                .background(Color.blue.opacity(0.1)) // Matches the top background
                .clipShape(Capsule()) // Oval shape
                .padding(.horizontal)

                // Content Area
                switch selectedTab {
                case "Home":
                    HomeView()
                case "Edit":
                    EditSupplementsView()
                case "Cart":
                    CartView(
                        saveCart: saveCart,
                        addToOrderList: addToOrderList,
                        showCart: .constant(true),
                        supplementIcon: supplementIcon
                    )
                case "Order List":
                    OrderListView(
                        saveOrderList: saveCart,
                        showOrderList: .constant(true),
                        supplementIcon: supplementIcon
                    )
                default:
                    HomeView() // Fallback
                }
            }
        }
        .accentColor(.blue)
        .onAppear(perform: loadInitialData)
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
        do {
            try viewContext.save()
        } catch {
            print("Failed to save cart: \(error)")
        }
    }
    
    private func addToOrderList(_ items: [CartItem]) {
        let newOrder = Order(context: viewContext)
        newOrder.id = UUID()
        newOrder.dateOrdered = Date()
        newOrder.items = NSSet(array: items)
        items.forEach { $0.order = newOrder }
        saveCart()
    }
    
    private func loadInitialData() {
        if supplements.isEmpty {
            let initialSupplements: [(String, Double, String, Int32, String, [(String, String, String, Double?)])] = [
                ("Protein Powder", 29.99, "1 scoop daily", 30, "Powder", [
                    ("Amazon", "https://www.amazon.com/Optimum-Nutrition-Standard-Protein-Chocolate/dp/B000QSNYGI", "https://www.amazon.com/Optimum-Nutrition-Standard-Protein-Chocolate/dp/B000QSNYGI#customerReviews", 29.99),
                    ("Walmart", "https://www.walmart.com/ip/17476803", "https://www.walmart.com/reviews/product/17476803", 80.0)
                ]),
                ("Vitamin D", 9.99, "1 capsule daily", 100, "Capsule", [
                    ("Amazon", "https://www.amazon.com/Vitamin-D3-5000-IU/dp/B00JGCBGQA", "https://example.com/vitamind-amazon-info", 9.99),
                    ("Walmart", "https://www.walmart.com/ip/10448595", "https://example.com/vitamind-walmart-info", nil)
                ]),
                ("Omega-3 Fish Oil", 14.99, "2 capsules daily", 60, "Capsule", [
                    ("Amazon", "https://www.amazon.com/Nature-Made-Fish-Oil-1000/dp/B004U3Y8NI", "https://example.com/omega3-amazon-info", 29.99),
                    ("Walmart", "https://www.walmart.com/ip/10448596", "https://example.com/omega3-walmart-info", nil)
                ]),
                ("Multivitamin", 12.50, "1 tablet daily", 90, "Tablet", [
                    ("Amazon", "https://www.amazon.com/Centrum-Multivitamin-Adults-Tablets/dp/B09KLYG8NH", "https://example.com/multi-amazon-info", 12.50),
                    ("Walmart", "https://www.walmart.com/ip/11029191", "https://example.com/multi-walmart-info", nil)
                ])
            ]
            
            for (name, price, dosage, quantity, type, stores) in initialSupplements {
                let supplement = Supplement(context: viewContext)
                supplement.id = UUID()
                supplement.name = name
                supplement.price = price
                supplement.dosage = dosage
                supplement.quantity = quantity
                supplement.type = type
                
                for (storeName, storeURL, infoURL, storePrice) in stores {
                    let storeInfo = StoreInfo(context: viewContext)
                    storeInfo.id = UUID()
                    storeInfo.name = storeName
                    storeInfo.storeURL = storeURL
                    storeInfo.infoURL = infoURL
                    storeInfo.price = storePrice ?? 0.0
                    storeInfo.supplement = supplement
                }
            }
            try? viewContext.save()
        }
    }
}

struct HomeView: View {
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.white]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack {
                Image(systemName: "pills.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 400) // Doubled from 200 to 400
                    .foregroundColor(.blue)
                    .shadow(radius: 5)
                Text("Supplement Order")
                    .font(.system(size: 68, weight: .bold)) // Doubled from ~34 to 68
                    .foregroundColor(.blue)
                    .padding(.top, 20)
                Text("Manage your supplements with ease!")
                    .font(.system(size: 30)) // Doubled from ~15 to 30
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
