//
//  UpdateQuantityView.swift
//  InventoryHome
//
//  Created by Ehtisham Khalid on 28.07.2024.
//

import SwiftUI
import CoreData

struct UpdateQuantityView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var item: Item

    @State private var newQuantity: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Update Quantity")) {
                    TextField("New Quantity", text: $newQuantity)
                        .keyboardType(.numberPad)
                }
                Section {
                    Button("Save") {
                        updateQuantity()
                    }
                }
            }
            .navigationBarTitle("Update Quantity", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .onAppear {
            newQuantity = String(item.quantity)
        }
    }

    private func updateQuantity() {
        withAnimation {
            item.quantity = Int64(newQuantity) ?? item.quantity
            do {
                try viewContext.save()
                presentationMode.wrappedValue.dismiss()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

