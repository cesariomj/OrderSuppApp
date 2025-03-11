import SwiftUI

struct CartView: View {
    @Binding var cart: [CartItem]
    let saveCart: () -> Void
    let addToOrderList: ([CartItem]) -> Void
    @Binding var showCart: Bool
    let supplementIcon: (String) -> String
    
    private var totalPrice: Double {
        cart.reduce(0) { $0 + ($1.selectedStoreInfo.price ?? 0 * Double($1.quantity)) }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(cart) { item in
                        HStack {
                            Image(systemName: supplementIcon(item.supplement.name))
                                .foregroundColor(.green)
                                .frame(width: 30)
                            VStack(alignment: .leading) {
                                Text(item.supplement.name)
                                    .font(.headline)
                                Text(item.selectedStoreInfo.name)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Text("x\(item.quantity)")
                                .foregroundColor(.gray)
                            Text("$\(item.selectedStoreInfo.price ?? 0 * Double(item.quantity), specifier: "%.2f")")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(8)
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(color: .gray.opacity(0.2), radius: 2)
                    }
                    .onDelete(perform: { indexSet in
                        cart.remove(atOffsets: indexSet)
                        saveCart()
                    })
                }
                Text("Total: $\(totalPrice, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding(.top)
                HStack(spacing: 15) {
                    Button("Clear Cart") {
                        cart.removeAll()
                        saveCart()
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.red.opacity(0.9))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    Button("Add to Order List") {
                        addToOrderList(cart)
                        cart.removeAll()
                        saveCart()
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(LinearGradient(gradient: Gradient(colors: [.green, .teal]), startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Cart")
        }
    }
}
