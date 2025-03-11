import SwiftUI
import SwiftSoup

struct EditSupplementsView: View {
    @Binding var supplements: [Supplement]
    @Binding var cart: [CartItem]
    @State private var editingSupplementIndex: Int?
    @State private var addingSupplement = false
    @State private var selectedStores: [UUID: UUID] = [:]
    @State private var isRefreshingPrices = false
    @State private var refreshError: String?
    
    var body: some View {
        NavigationStack {
            List($supplements) { $supplement in
                SupplementRow(
                    supplement: $supplement,
                    selectedStoreId: $selectedStores[supplement.id],
                    cart: cart,
                    addToCart: {
                        if let selectedStoreId = selectedStores[supplement.id],
                           let storeInfo = supplement.storeInfos.first(where: { $0.id == selectedStoreId }) {
                            print("Adding \(supplement.name) from \(storeInfo.name) to cart")
                            if let index = cart.firstIndex(where: { $0.supplement.id == supplement.id && $0.selectedStoreInfo.id == storeInfo.id }) {
                                cart[index].quantity += 1
                            } else {
                                cart.append(CartItem(supplement: supplement, selectedStoreInfo: storeInfo, quantity: 1))
                            }
                            saveCart()
                        } else {
                            print("No store selected for \(supplement.name)")
                        }
                    },
                    editAction: {
                        if let index = supplements.firstIndex(where: { $0.id == supplement.id }) {
                            print("Setting editingSupplementIndex to: \(index) for \(supplement.name)")
                            editingSupplementIndex = index
                        }
                    }
                )
            }
            .navigationTitle("Edit Supplements")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        Task {
                            isRefreshingPrices = true
                            refreshError = nil
                            do {
                                try await refreshPrices()
                            } catch {
                                refreshError = "Failed to refresh prices: \(error.localizedDescription)"
                            }
                            isRefreshingPrices = false
                        }
                    }) {
                        if isRefreshingPrices {
                            ProgressView()
                        } else {
                            Text("Refresh Prices")
                        }
                    }
                    .foregroundColor(.blue)
                    .disabled(isRefreshingPrices)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        addingSupplement = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.blue)
                    }
                }
            }
            .overlay {
                if let error = refreshError {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                        .shadow(radius: 4)
                        .onTapGesture {
                            refreshError = nil
                        }
                }
            }
            .sheet(isPresented: Binding(
                get: { editingSupplementIndex != nil },
                set: { if !$0 { editingSupplementIndex = nil } }
            )) {
                if let index = editingSupplementIndex {
                    SupplementEditView(
                        supplement: supplements[index],
                        onSave: { updatedSupplement in
                            supplements[index] = updatedSupplement
                            saveSupplements()
                            editingSupplementIndex = nil
                        }
                    )
                }
            }
            .sheet(isPresented: $addingSupplement) {
                AddSupplementView(supplements: $supplements)
            }
            .onAppear {
                for supplement in supplements {
                    if selectedStores[supplement.id] == nil, let firstStoreId = supplement.storeInfos.first?.id {
                        selectedStores[supplement.id] = firstStoreId
                    }
                }
            }
            .onChange(of: supplements) {
                saveSupplements()
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
    
    @MainActor
    private func refreshPrices() async throws {
        for index in supplements.indices {
            for storeIndex in supplements[index].storeInfos.indices {
                if let url = URL(string: supplements[index].storeInfos[storeIndex].storeURL) {
                    do {
                        let price = try await scrapePrice(from: url)
                        supplements[index].storeInfos[storeIndex].price = price
                    } catch {
                        print("Failed to scrape \(url): \(error)")
                        supplements[index].storeInfos[storeIndex].price = nil
                        throw error
                    }
                }
            }
        }
        saveSupplements()
    }
    
    private func scrapePrice(from url: URL) async throws -> Double {
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36", forHTTPHeaderField: "User-Agent")
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        guard let html = String(data: data, encoding: .utf8) else {
            throw URLError(.cannotDecodeContentData)
        }
        
        let doc = try SwiftSoup.parse(html)
        let host = url.host ?? ""
        
        switch host {
        case "www.amazon.com":
            let selectors = [
                ".a-price .a-offscreen",
                "#priceblock_ourprice",
                ".priceToPay .a-offscreen",
                "[data-a-size='xl'] .a-offscreen"
            ]
            for selector in selectors {
                if let priceText = try doc.select(selector).first()?.text(),
                   let price = Double(priceText.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)) {
                    return price
                }
            }
        case "www.walmart.com":
            let selectors = [
                ".price--dollars",
                "[itemprop='price']",
                ".price-display",
                ".price-group"
            ]
            for selector in selectors {
                if let priceText = try doc.select(selector).first()?.text(),
                   let price = Double(priceText.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)) {
                    return price
                }
            }
        default:
            let genericSelectors = [
                "span.price", "div.price", ".price", "[itemprop='price']", ".a-price", ".price--dollars"
            ]
            for selector in genericSelectors {
                if let priceText = try doc.select(selector).first()?.text(),
                   let price = Double(priceText.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)) {
                    return price
                }
            }
        }
        throw URLError(.resourceUnavailable)
    }
    
    func saveCart() {
        if let encoded = try? JSONEncoder().encode(cart) {
            UserDefaults.standard.set(encoded, forKey: "cart")
        }
    }
    
    func saveSupplements() {
        if let encoded = try? JSONEncoder().encode(supplements) {
            UserDefaults.standard.set(encoded, forKey: "supplements")
        }
    }
}

struct SupplementRow: View {
    @Binding var supplement: Supplement
    @Binding var selectedStoreId: UUID?
    let cart: [CartItem]
    let addToCart: () -> Void
    let editAction: () -> Void
    
    private var cartQuantity: Int {
        if let selectedStoreId = selectedStoreId,
           let cartItem = cart.first(where: { $0.supplement.id == supplement.id && $0.selectedStoreInfo.id == selectedStoreId }) {
            return cartItem.quantity
        }
        return 0
    }
    
    private var cheapestStoreId: UUID? {
        let validStores = supplement.storeInfos.filter { $0.price != nil }
        guard let cheapest = validStores.min(by: { $0.price! < $1.price! }) else { return nil }
        return cheapest.id
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: supplementIcon(for: supplement.name))
                    .foregroundColor(.blue)
                    .frame(width: 30)
                Text(supplement.name)
                    .font(.headline)
                    .contentShape(Rectangle())
                    .onTapGesture(perform: editAction)
                Spacer()
                HStack(spacing: 4) {
                    Button(action: addToCart) {
                        Text("Add")
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(LinearGradient(gradient: Gradient(colors: [.green, .teal]), startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 2)
                    }
                    .disabled(selectedStoreId == nil)
                    .buttonStyle(PlainButtonStyle())
                    if cartQuantity > 0 {
                        Text("x\(cartQuantity)")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.leading, 2)
                    }
                }
            }
            Text("Dosage: \(supplement.dosage)")
                .font(.caption)
            Text("Quantity: \(supplement.quantity) \(supplement.type.lowercased())s")
                .font(.caption)
            Section(header: Text("Store Options").font(.caption.bold())) {
                ForEach(supplement.storeInfos) { storeInfo in
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Image(systemName: selectedStoreId == storeInfo.id ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(.blue)
                            Text("\(storeInfo.name):")
                                .font(.caption)
                            Text(storeInfo.price != nil ? "$\(storeInfo.price!, specifier: "%.2f")" : "N/A")
                                .font(.caption)
                                .foregroundColor(storeInfo.id == cheapestStoreId ? .green : (storeInfo.price != nil ? .blue : .gray))
                            Spacer()
                            if let url = URL(string: storeInfo.storeURL) {
                                Text("Visit Store")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .onTapGesture {
                                        UIApplication.shared.open(url)
                                    }
                            }
                        }
                        if let url = URL(string: storeInfo.infoURL) {
                            HStack {
                                Text("Info")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .onTapGesture {
                                        UIApplication.shared.open(url)
                                    }
                                Spacer()
                            }
                            .padding(.leading, 20)
                        }
                    }
                    .padding(4)
                    .background(selectedStoreId == storeInfo.id ? Color.blue.opacity(0.1) : Color.clear)
                    .cornerRadius(6)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedStoreId = storeInfo.id
                    }
                }
            }
        }
        .padding(10)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
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
