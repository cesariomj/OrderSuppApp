import SwiftUI

struct CartView: View {
    @Binding var cart: [CartItem]
    let saveCart: () -> Void
    let addToOrderList: ([CartItem]) -> Void
    @Binding var showCart: Bool
    let supplementIcon: (String) -> String // Add this to get the function from ContentView
    
    private var totalPrice: Double {
        cart.reduce(0) { $0 + ($1.supplement.price * Double($1.quantity)) }
    }
    
    var body: some View {
        VStack {
            Text("Your Cart")
                .font(.title2.bold())
                .foregroundColor(.blue)
                .padding(.top)
            List {
                ForEach(cart) { item in
                    HStack {
                        Image(systemName: supplementIcon(item.supplement.name)) // Use the passed function
                            .foregroundColor(.green)
                            .frame(width: 30)
                        Text(item.supplement.name)
                            .font(.headline)
                        Spacer()
                        Text("x\(item.quantity)")
                            .foregroundColor(.gray)
                        Text("$\(item.supplement.price * Double(item.quantity), specifier: "%.2f")")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .onDelete(perform: { indexSet in
                    cart.remove(atOffsets: indexSet)
                    saveCart()
                })
            }
            Text("Total: $\(totalPrice, specifier: "%.2f")")
                .font(.subheadline.bold())
                .foregroundColor(.blue)
                .padding(.top)
            HStack(spacing: 15) {
                Button("Clear Cart") {
                    cart.removeAll()
                    saveCart()
                }
                .font(.subheadline)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.red.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(8)
                Button("Add to Order List") {
                    addToOrderList(cart)
                    cart.removeAll()
                    saveCart()
                    showCart = false
                }
                .font(.subheadline)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(LinearGradient(gradient: Gradient(colors: [.green, .mint]), startPoint: .leading, endPoint: .trailing))
                .foregroundColor(.white)
                .cornerRadius(8)
                Spacer()
                Button("Close") {
                    showCart = false
                }
                .font(.subheadline)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.blue.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color(uiColor: UIColor.systemGray6), .white]), startPoint: .top, endPoint: .bottom))
    }
}
