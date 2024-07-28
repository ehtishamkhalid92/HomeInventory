//
//  ContentView.swift
//  InventoryHome
//
//  Created by Ehtisham Khalid on 28.07.2024.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.expiryDate, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    @State private var selectedCategory: String = "All"
    @State private var showingAddItemView = false
    @State private var showingUpdateQuantityView = false
    @State private var itemToUpdate: Item?

    var categories: [String] {
        let allCategories = items.compactMap { $0.category }
        return ["All"] + Set(allCategories).sorted()
    }

    var filteredItems: [Item] {
        if selectedCategory == "All" {
            return Array(items)
        } else {
            return items.filter { $0.category == selectedCategory }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                Picker("Category", selection: $selectedCategory) {
                    ForEach(categories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                List {
                    ForEach(filteredItems) { item in
                        HStack {
                            if let imageData = item.image, let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "photo")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            }
                            VStack(alignment: .leading) {
                                Text(item.name ?? "Unknown")
                                    .font(.headline)
                                Text("Category: \(item.category ?? "Unknown")")
                                Text("Quantity: \(item.quantity)")
                                Text("Expires on: \(item.expiryDate ?? Date(), formatter: itemFormatter)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button(action: {
                                itemToUpdate = item
                                showingUpdateQuantityView.toggle()
                            }) {
                                Text("Update")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .navigationBarTitle("Home Inventory")
                .navigationBarItems(trailing: Button(action: {
                    showingAddItemView.toggle()
                }) {
                    Image(systemName: "plus")
                })
                .sheet(isPresented: $showingAddItemView) {
                    AddItemView().environment(\.managedObjectContext, viewContext)
                }
                .sheet(item: $itemToUpdate) { item in
                    UpdateQuantityView(item: item).environment(\.managedObjectContext, viewContext)
                }
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredItems[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
