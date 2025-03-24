import SwiftUI
import SwiftSoup
import CoreData

struct EditSupplementsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Supplement.name, ascending: true)],
        animation: .default)
    private var supplements: FetchedResults<Supplement>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CartItem.supplement?.name, ascending: true)],
        predicate: NSPredicate(format: "order == nil"),
        animation: .default)
    private var cart: FetchedResults<CartItem>
    
    @State private var editingSupplementIndex: Int?
    @State private var addingSupplement = false
    @State private var editingStoresForSupplement: Supplement? // Track which supplement’s stores to edit
    @State private var selectedStores: [UUID: UUID] = [:]
    @State private var isRefreshingPrices = false
    @State private var refreshError: String?
    
    var body: some View {
        NavigationStack {
            List(supplements.indices, id: \.self) { index in
                SupplementRowView(
                    supplement: supplements[index],
                    selectedStoreId: $selectedStores[supplements[index].id ?? UUID()],
                    cart: Array(cart),
                    addToCart: addToCart(index: index),
                    editAction: {
                        editingSupplementIndex = index
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
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Menu {
                        Button("Edit Stores") {
                            if !supplements.isEmpty {
                                editingStoresForSupplement = supplements.first
                            }
                        }
                        Button("Edit Supplement") {
                            if !supplements.isEmpty {
                                editingSupplementIndex = 0 // Edit the first supplement as a default
                            }
                        }
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundColor(.blue)
                    }
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
                            supplements[index].name = updatedSupplement.name
                            supplements[index].price = updatedSupplement.price
                            supplements[index].dosage = updatedSupplement.dosage
                            supplements[index].quantity = updatedSupplement.quantity
                            supplements[index].type = updatedSupplement.type
                            saveSupplements()
                            editingSupplementIndex = nil
                        }
                    )
                }
            }
            .sheet(isPresented: $addingSupplement) {
                AddSupplementView(supplements: .constant([])) // Placeholder until actual code is shared
            }
            .sheet(isPresented: Binding(
                get: { editingStoresForSupplement != nil },
                set: { if !$0 { editingStoresForSupplement = nil } }
            )) {
                if let supplement = editingStoresForSupplement {
                    StoreEditView(supplement: supplement)
                }
            }
            .onAppear {
                for supplement in supplements {
                    if selectedStores[supplement.id ?? UUID()] == nil,
                       let firstStore = supplement.storeInfos?.anyObject() as? StoreInfo {
                        selectedStores[supplement.id ?? UUID()] = firstStore.id
                    }
                }
            }
        }
    }
    
    private func addToCart(index: Int) -> () -> Void {
        return {
            let supplement = supplements[index]
            if let selectedStoreId = selectedStores[supplement.id ?? UUID()],
               let storeInfos = supplement.storeInfos as? Set<StoreInfo>,
               let storeInfo = storeInfos.first(where: { $0.id == selectedStoreId }) {
                if let existingItem = cart.first(where: { $0.supplement?.id == supplement.id && $0.selectedStoreInfo?.id == storeInfo.id }) {
                    existingItem.quantity += 1
                } else {
                    let newItem = CartItem(context: viewContext)
                    newItem.id = UUID()
                    newItem.supplement = supplement
                    newItem.selectedStoreInfo = storeInfo
                    newItem.quantity = 1
                }
                saveCart()
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
        for supplement in supplements {
            if let storeInfos = supplement.storeInfos as? Set<StoreInfo> {
                for storeInfo in storeInfos {
                    if let url = URL(string: storeInfo.storeURL ?? "") {
                        do {
                            let price = try await scrapePrice(from: url)
                            storeInfo.price = price
                        } catch {
                            print("Failed to scrape \(url): \(error)")
                            storeInfo.price = 0.0
                            throw error
                        }
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
    
    private func saveCart() {
        do {
            try viewContext.save()
        } catch {
            print("Failed to save cart: \(error)")
        }
    }
    
    private func saveSupplements() {
        do {
            try viewContext.save()
        } catch {
            print("Failed to save supplements: \(error)")
        }
    }
}

struct SupplementRowView: View {
    @ObservedObject var supplement: Supplement
    @Binding var selectedStoreId: UUID?
    let cart: [CartItem]
    let addToCart: () -> Void
    let editAction: () -> Void
    
    private var cartQuantity: Int {
        if let selectedStoreId = selectedStoreId,
           let cartItem = cart.first(where: { $0.supplement?.id == supplement.id && $0.selectedStoreInfo?.id == selectedStoreId }) {
            return Int(cartItem.quantity)
        }
        return 0
    }
    
    private var cheapestStoreId: UUID? {
        guard let storeInfos = supplement.storeInfos as? Set<StoreInfo>,
              !storeInfos.isEmpty else { return nil }
        let validStores = storeInfos.filter { $0.price != 0.0 }
        return validStores.min(by: { $0.price < $1.price })?.id
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: supplementIcon(for: supplement.name ?? ""))
                    .foregroundColor(.blue)
                    .frame(width: 30)
                Text(supplement.name ?? "Unknown")
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
            Text("Dosage: \(supplement.dosage ?? "N/A")")
                .font(.caption)
            Text("Quantity: \(supplement.quantity) \(supplement.type?.lowercased() ?? "")s")
                .font(.caption)
            Section {
                if let storeInfos = supplement.storeInfos as? Set<StoreInfo> {
                    let sortedStores = storeInfos.sorted { $0.name ?? "" < $1.name ?? "" }
                    ForEach(sortedStores, id: \.id) { storeInfo in
                        storeOptionRow(storeInfo: storeInfo)
                    }
                }
            } header: {
                Text("Store Options").font(.caption.bold())
            }
        }
        .padding(10)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
    }
    
    private func storeOptionRow(storeInfo: StoreInfo) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Image(systemName: selectedStoreId == storeInfo.id ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(.blue)
                Text("\(storeInfo.name ?? "Unknown"):")
                    .font(.caption)
                Text(storeInfo.price != 0.0 ? "$\(storeInfo.price, specifier: "%.2f")" : "N/A")
                    .font(.caption)
                    .foregroundColor(storeInfo.id == cheapestStoreId ? .green : (storeInfo.price != 0.0 ? .blue : .gray))
                Spacer()
                if let url = URL(string: storeInfo.storeURL ?? "") {
                    Text("Visit Store")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .onTapGesture {
                            UIApplication.shared.open(url)
                        }
                }
            }
            if let url = URL(string: storeInfo.infoURL ?? "") {
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
