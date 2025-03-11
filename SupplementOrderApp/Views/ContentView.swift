import SwiftUI

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
        Supplement(
            name: "Protein Powder",
            price: 29.99,
            dosage: "1 scoop daily",
            quantity: 30,
            type: "Powder",
            storeInfos: [
                StoreInfo(name: "Amazon", storeURL: "https://www.amazon.com/Optimum-Nutrition-Standard-Protein-Chocolate/dp/B000QSNYGI", infoURL: "https://www.amazon.com/Optimum-Nutrition-Standard-Protein-Chocolate/dp/B000QSNYGI#customerReviews"),
                StoreInfo(name: "Walmart", storeURL: "https://www.walmart.com/ip/17476803", infoURL: "https://www.walmart.com/reviews/product/17476803", price: 80.0)
                ]
        ),
        Supplement(
            name: "Vitamin D",
            price: 9.99,
            dosage: "1 capsule daily",
            quantity: 100,
            type: "Capsule",
            storeInfos: [
                StoreInfo(name: "Amazon", storeURL: "https://www.amazon.com/Vitamin-D3-5000-IU/dp/B00JGCBGQA", infoURL: "https://example.com/vitamind-amazon-info"),
                StoreInfo(name: "Walmart", storeURL: "https://www.walmart.com/ip/10448595", infoURL: "https://example.com/vitamind-walmart-info")
            ]
        ),
        Supplement(
            name: "Omega-3 Fish Oil",
            price: 14.99,
            dosage: "2 capsules daily",
            quantity: 60,
            type: "Capsule",
            storeInfos: [
                StoreInfo(name: "Amazon", storeURL: "https://www.amazon.com/Nature-Made-Fish-Oil-1000/dp/B004U3Y8NI", infoURL: "https://example.com/omega3-amazon-info"),
                StoreInfo(name: "Walmart", storeURL: "https://www.walmart.com/ip/10448596", infoURL: "https://example.com/omega3-walmart-info")
            ]
        ),
        Supplement(
            name: "Multivitamin",
            price: 12.50,
            dosage: "1 tablet daily",
            quantity: 90,
            type: "Tablet",
            storeInfos: [
                StoreInfo(name: "Amazon", storeURL: "https://www.amazon.com/Centrum-Multivitamin-Adults-Tablets/dp/B09KLYG8NH", infoURL: "https://example.com/multi-amazon-info"),
                StoreInfo(name: "Walmart", storeURL: "https://www.walmart.com/ip/11029191", infoURL: "https://example.com/multi-walmart-info")
            ]
        )
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

// Keep HomeView, EditSupplementsView, AddSupplementView, etc. as separate structs below
struct HomeView: View {
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.white]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack {
                Image(systemName: "pills.fill")
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

#Preview {
    ContentView()
}
