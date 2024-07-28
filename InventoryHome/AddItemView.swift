//
//  AddItemView.swift
//  InventoryHome
//
//  Created by Ehtisham Khalid on 28.07.2024.
//

import SwiftUI
import CoreData

struct AddItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @State private var name: String = ""
    @State private var category: String = ""
    @State private var expiryDate: Date = Date()
    @State private var quantity: String = ""
    @State private var image: UIImage?
    @State private var showingImagePicker = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Name", text: $name)
                    TextField("Category", text: $category)
                    DatePicker("Expiry Date", selection: $expiryDate, displayedComponents: .date)
                    TextField("Quantity", text: $quantity)
                        .keyboardType(.numberPad)
                }

                Section {
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        } else {
                            Text("Select Image")
                        }
                    }
                }

                Section {
                    Button("Save") {
                        addItem()
                    }
                }
            }
            .navigationBarTitle("Add Item")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .sheet(isPresented: $showingImagePicker, content: {
                ImagePicker(image: $image)
            })
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.name = name
            newItem.category = category
            newItem.expiryDate = expiryDate
            newItem.quantity = Int64(quantity) ?? 0
            newItem.image = image?.jpegData(compressionQuality: 1.0)
            do {
                try viewContext.save()
                scheduleNotification(for: newItem)
                presentationMode.wrappedValue.dismiss()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func scheduleNotification(for item: Item) {
        let content = UNMutableNotificationContent()
        content.title = "Item Expiry Alert"
        content.body = "\(item.name ?? "An item") is expiring soon!"
        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: item.expiryDate ?? Date())
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
