import SwiftUI
import CoreData

struct CartView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CartItem.supplement?.name, ascending: true)],
        predicate: NSPredicate(format: "order == nil"),
        animation: .default)
    private var cart: FetchedResults<CartItem>
    
    let saveCart: () -> Void
    let addToOrderList: ([CartItem]) -> Void
    @Binding var showCart: Bool
    let supplementIcon: (String) -> String
    
    private var totalPrice: Double {
        cart.reduce(0) { $0 + (Double($1.quantity) * ($1.selectedStoreInfo?.price ?? 0)) }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(cart) { item in
                        HStack {
                            Image(systemName: supplementIcon(item.supplement?.name ?? ""))
                                .foregroundColor(.green)
                                .frame(width: 30)
                            VStack(alignment: .leading) {
                                Text(item.supplement?.name ?? "Unknown")
                                    .font(.headline)
                                Text(item.selectedStoreInfo?.name ?? "Unknown")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Text("x\(item.quantity)")
                                .foregroundColor(.gray)
                            Text("$\(item.selectedStoreInfo?.price ?? 0 * Double(item.quantity), specifier: "%.2f")")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(8)
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(color: .gray.opacity(0.2), radius: 2)
                    }
                    .onDelete(perform: deleteItems)
                }
                Text("Total: $\(totalPrice, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding(.top)
                HStack(spacing: 15) {
                    Button("Clear Cart") {
                        cart.forEach { viewContext.delete($0) }
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
                        addToOrderList(Array(cart))
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
    
    private func deleteItems(at offsets: IndexSet) {
        offsets.map { cart[$0] }.forEach(viewContext.delete)
        saveCart()
    }
}

#Preview {
    CartView(
        saveCart: {},
        addToOrderList: { _ in },
        showCart: .constant(true),
        supplementIcon: { _ in "pill.fill" }
    ).environment(\.managedObjectContext, PersistenceController.shared.container.viewContext) // Fixed reference
}
