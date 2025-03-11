import SwiftUI

struct OrderListView: View {
    @Binding var orderList: [CartItem]
    let saveOrderList: () -> Void
    @Binding var showOrderList: Bool
    let supplementIcon: (String) -> String
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach($orderList) { $item in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: supplementIcon(item.supplement.name))
                                    .foregroundColor(.purple)
                                    .frame(width: 30)
                                Text(item.supplement.name)
                                    .font(.headline)
                                Spacer()
                                Button(action: {
                                    if item.quantity > 1 {
                                        item.quantity -= 1
                                        saveOrderList()
                                    }
                                }) {
                                    Image(systemName: "minus.circle")
                                        .foregroundColor(.red)
                                }
                                Text("x\(item.quantity)")
                                    .foregroundColor(.gray)
                                Button(action: {
                                    item.quantity += 1
                                    saveOrderList()
                                }) {
                                    Image(systemName: "plus.circle")
                                        .foregroundColor(.green)
                                }
                            }
                            Text("Store: \(item.selectedStoreInfo.name)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            if let price = item.selectedStoreInfo.price {
                                Text("Price: $\(price, specifier: "%.2f")")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                            if let url = URL(string: item.selectedStoreInfo.storeURL) {
                                Text("Visit Store")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .onTapGesture {
                                        UIApplication.shared.open(url)
                                    }
                            }
                            if let url = URL(string: item.selectedStoreInfo.infoURL) {
                                Text("Visit Info")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .onTapGesture {
                                        UIApplication.shared.open(url)
                                    }
                            }
                        }
                        .padding(8)
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(color: .gray.opacity(0.2), radius: 2)
                    }
                    .onDelete(perform: { indexSet in
                        orderList.remove(atOffsets: indexSet)
                        saveOrderList()
                    })
                }
                HStack(spacing: 15) {
                    Button("Copy List") {
                        let listText = orderList.map { "\($0.supplement.name) (\($0.selectedStoreInfo.name)) x\($0.quantity)" }.joined(separator: ", ")
                        UIPasteboard.general.string = listText.isEmpty ? "Order list is empty" : listText
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.purple.opacity(0.9))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    Button("Clear List") {
                        orderList.removeAll()
                        saveOrderList()
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.red.opacity(0.9))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Order List")
        }
    }
}
