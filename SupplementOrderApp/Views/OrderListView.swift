import SwiftUI

struct OrderListView: View {
    @Binding var orderList: [CartItem]
    let saveOrderList: () -> Void
    @Binding var showOrderList: Bool
    let supplementIcon: (String) -> String // Add this to get the function from ContentView
    
    var body: some View {
        VStack {
            Text("Supplement Order List")
                .font(.title2.bold())
                .foregroundColor(.blue)
                .padding(.top)
            List {
                ForEach($orderList) { $item in
                    HStack {
                        Image(systemName: supplementIcon(item.supplement.name)) // Use the passed function
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
                }
                .onDelete(perform: { indexSet in
                    orderList.remove(atOffsets: indexSet)
                    saveOrderList()
                })
            }
            HStack(spacing: 15) {
                Button("Copy List") {
                    let listText = orderList.map { "\($0.supplement.name) x\($0.quantity)" }.joined(separator: ", ")
                    UIPasteboard.general.string = listText.isEmpty ? "Order list is empty" : listText
                }
                .font(.subheadline)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.purple.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(8)
                Button("Clear List") {
                    orderList.removeAll()
                    saveOrderList()
                }
                .font(.subheadline)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.red.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(8)
                Spacer()
                Button("Close") {
                    showOrderList = false
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
