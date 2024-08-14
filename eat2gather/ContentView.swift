//
//  ContentView.swift
//  eat2gather
//
//  Created by Ege Erdem on 13.08.2024.
//

import SwiftUI
import Combine
import Vision


struct Person: Identifiable {
    var id = UUID()
    var name: String
    var isActive: Bool = false
}

struct FoodItem: Identifiable {
    var id = UUID()
    var type: String = ""
    var quantity: Double = 1
    var unitPrice: Double = 0
    var totalPrice: Double {
        return quantity * unitPrice
    }
    var eatingPersons: [Person] = []
}

struct ContentView: View {
    @State private var people: [Person] = [
        Person(name: "EE"),
        Person(name: "MFS"),
        Person(name: "ÖFO"),
        Person(name: "iÇ")
    ]
    @State private var foodItems: [FoodItem] = []
    @State private var newFoodItem = FoodItem()
    @State private var newPersonName = ""
    @State private var isAddingPerson = false
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @FocusState private var isInputActive: Bool

    let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    let totalWidth = UIScreen.main.bounds.width - 160
    let columnWidthRatios: [CGFloat] = [0.25, 0.1, 0.15, 0.2, 0.3]
    let inputFontSize: CGFloat = 12 // Define the font size constant

    
    var body: some View {
        ZStack {
            VStack {
                Text("Eat #1 - \(Date(), formatter: dateFormatter)")
                    .padding(10)
                Text("Hayvanları Seç")
                    .foregroundColor(.gray)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, -8)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach($people) { $person in
                            Circle()
                                .fill(person.isActive ? Color.yellow : Color.gray.opacity(0.1))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .stroke(Color.black, lineWidth: 1)
                                )
                                .overlay(Text(person.name))
                                .onTapGesture {
                                    person.isActive.toggle()
                                }
                        }
                        addPersonButton
                    }
                    .padding(.vertical, 10)
                }

                foodItemsSection
                costPerPersonView

                if anyEatingPersons {
                    totalPaidView
                }
            }
            .padding()
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        if let image = UIImage(named: "beykoz") {
                                                processBillImage(image)}
                        
                        showImagePicker = false
                    }) {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: "camera.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 30))
                            )
                            .shadow(radius: 10)
                    }
                    .padding(.bottom, 30)
                    .padding(.trailing, UIScreen.main.bounds.width / 2 - 30)
                }
            }
        }
        .sheet(isPresented: $showImagePicker, onDismiss: {
            if let selectedImage = selectedImage {
                processBillImage(selectedImage)            }
        }) {
            ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
        }
    }

    // Check if there are any eating persons
    var anyEatingPersons: Bool {
        return !newFoodItem.eatingPersons.isEmpty || foodItems.contains { !$0.eatingPersons.isEmpty }
    }

    // Process the bill image
    func processBillImage(_ image: UIImage) {
        
        extractTextFromImage(image) { recognizedText in
            print("Recognized Text: \(String(describing: recognizedText))")
            guard let lines = recognizedText else {
                print("No text recognized")
                
                return
                
            }
            
            // Print all the extracted lines
                    print("Extracted Lines:")
            for line in lines {
                print(line)
            }
            
            print("lines! \(lines)")
            
            // Now, parse the extracted lines
            let parsedData = parseExtractedText(lines)
            
            // Output the parsed data
            for item in parsedData {
                let newItem = FoodItem(type: item.foodName, quantity: item.quantity, unitPrice: item.price, eatingPersons: [])
                
                // Print the parsed data
                print("Parsed Item - Food Name: \(item.foodName), Quantity: \(item.quantity), Price: \(item.price)")
                print("FoodItem created: \(newItem)")
                
                // Add the parsed data to the food items
                foodItems.append(newItem)
            }
        }
    }


    func extractTextFromImage(_ image: UIImage, completion: @escaping ([String]?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { (request, error) in
            guard error == nil else {
                print("Error: \(error!.localizedDescription)")
                completion(nil)
                return
            }

            let recognizedText = request.results?.compactMap { result in
                return (result as? VNRecognizedTextObservation)?.topCandidates(1).first?.string
            }

            completion(recognizedText)
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                print("Error: \(error.localizedDescription)")
                completion(nil)
            }
        }

    }

    func parseExtractedText(_ extractedLines: [String]) -> [(quantity: Double, foodName: String, price: Double)] {
        var parsedItems: [(quantity: Double, foodName: String, price: Double)] = []
        
        var quantity: Double?
        var foodName = ""
        var price: Double?

        for line in extractedLines {
            let components = line.split(separator: " ")
            
            // Check if the first component is a valid quantity
            if let firstComponent = components.first, let parsedQuantity = Double(firstComponent.replacingOccurrences(of: ",", with: ".")) {
                if let quantity = quantity, let price = price {
                    // Append the previous item if it's complete
                    parsedItems.append((quantity: quantity, foodName: foodName, price: price))
                }
                // Start a new item
                quantity = parsedQuantity
                foodName = components.dropFirst().dropLast().joined(separator: " ")
                if let lastComponent = components.last, let parsedPrice = Double(lastComponent.replacingOccurrences(of: ",", with: ".")) {
                    price = parsedPrice
                } else {
                    price = nil
                }
            } else if components.count > 1 {
                // If the first component is not a quantity, treat it as part of the food name or price
                if let lastComponent = components.last, let parsedPrice = Double(lastComponent.replacingOccurrences(of: ",", with: ".")) {
                    // If the last component can be parsed as a price, update the price
                    price = parsedPrice
                    foodName += " " + components.dropLast().joined(separator: " ")
                } else {
                    // Otherwise, add this line as part of the food name
                    foodName += " " + line
                }
            }
        }
        
        // Append the last item if it's complete
        if let quantity = quantity, let price = price {
            parsedItems.append((quantity: quantity, foodName: foodName, price: price))
        }

        return parsedItems
    }


    var addPersonButton: some View {
        Group {
            if isAddingPerson {
                TextField("Name", text: $newPersonName)
                    .font(.system(size: 17))
                    .focused($isInputActive)
                    .textFieldStyle(PlainTextFieldStyle())
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color.gray.opacity(0.2)))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .autocapitalization(.words)
                    .textContentType(.name)
                    .onChange(of: isInputActive) {
                        if !isInputActive && !newPersonName.isEmpty {
                            addNewPerson()
                        }
                    }
            } else {
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round, dash: [6]))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text("+")
                            .font(.title)
                            .foregroundColor(.yellow)
                    )
                    .onTapGesture {
                        isAddingPerson = true
                        isInputActive = true
                    }
            }
        }
    }

    var selectedPeople: [Person] {
        return people.filter { $0.isActive }
    }

    let g = Color.green
    let b = Color.blue
    
    var foodItemsSection: some View {
        VStack {
            List {
                Section(header: HStack(spacing: 10) {
                    Text("besin")
                        .font(.system(size: inputFontSize))
                        .frame(width: totalWidth * columnWidthRatios[0], alignment: .leading)
                    Text("qty")
                        .font(.system(size: inputFontSize))
                        .frame(width: totalWidth * columnWidthRatios[1], alignment: .leading)
                    Text("price")
                        .font(.system(size: inputFontSize))
                        .frame(width: totalWidth * columnWidthRatios[2], alignment: .leading)
                    Text("total")
                        .font(.system(size: inputFontSize))
                        .frame(width: totalWidth * columnWidthRatios[3], alignment: .leading)
                    Divider() // Divider added here
                        .frame(height: 20) // Adjust height to match the row height
                    Text("yiyen hayvanlar")
                        .font(.system(size: 12))
                        .frame(alignment: .trailing)
                }
                    .padding(.leading, -10)
                    .textCase(nil)) {
                        foodRow(item: $newFoodItem, isEditable: true, isNew: true, color: g)
                            .padding(.vertical, 5)
                        
                        ForEach($foodItems) { $item in
                            foodRow(item: $item, isEditable: true, isNew: false, color: g)
                                .padding(.vertical, 5)
                        }
                        .onDelete(perform: deleteFoodItem)
                        
                        HStack {
                            Spacer()
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 30, height: 30)
                                .overlay(Text("+").foregroundColor(.white))
                                .onTapGesture {
                                    addFoodItem()
                                }
                            Spacer()
                        }
                    }
                
                // Add the totalCostView as its own section within the list
                
                totalCostView.listRowBackground(Color.clear) // Removes the background of the entire row
                    .padding(.top, -10)
                
            }
        }}


    func foodRow(item: Binding<FoodItem>, isEditable: Bool, isNew: Bool, color: Color) -> some View {
        let totalWidth = UIScreen.main.bounds.width - 160
        
        return HStack(spacing: 10) {
            TextField("type", text: item.type)
                .font(.system(size: inputFontSize))
                .frame(width: totalWidth * columnWidthRatios[0], alignment: .leading)
            
            TextField("qty", value: item.quantity, formatter: numberFormatter)
                .font(.system(size: inputFontSize))
                .frame(width: totalWidth * columnWidthRatios[1], alignment: .leading)
                .onChange(of: item.quantity.wrappedValue) {
                    updateNewTotal()
                }
            
            TextField("price", value: item.unitPrice, formatter: numberFormatter)
                .font(.system(size: inputFontSize))
                .frame(width: totalWidth * columnWidthRatios[2], alignment: .leading)
                .onChange(of: item.unitPrice.wrappedValue) { 
                    updateNewTotal()
                }
            
            Text(formattedTotalPrice(for: item.quantity.wrappedValue, unitPrice: item.unitPrice.wrappedValue))
                .font(.system(size: inputFontSize))
                .frame(width: totalWidth * columnWidthRatios[3], alignment: .leading)
                .foregroundColor(.red)
                .fixedSize(horizontal: true, vertical: false)
            
            Divider()
                .frame(height: 20)
                .background(Color.black)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 5) {
                    ForEach(selectedPeople) { person in
                        Circle()
                            .fill((isNew && newFoodItem.eatingPersons.contains { $0.id == person.id }) || (!isNew && item.eatingPersons.wrappedValue.contains { $0.id == person.id }) ? color : Color.gray.opacity(0.2))
                            .overlay(Text(person.name).font(.system(size: inputFontSize)))
                            .frame(maxWidth: .infinity)
                            .onTapGesture {
                                if isNew {
                                    if let index = newFoodItem.eatingPersons.firstIndex(where: { $0.id == person.id }) {
                                        newFoodItem.eatingPersons.remove(at: index)
                                    } else {
                                        newFoodItem.eatingPersons.append(person)
                                    }
                                } else {
                                    if let index = item.eatingPersons.wrappedValue.firstIndex(where: { $0.id == person.id }) {
                                        item.eatingPersons.wrappedValue.remove(at: index)
                                    } else {
                                        item.eatingPersons.wrappedValue.append(person)
                                    }
                                }
                            }
                    }
                }
            }
            .frame(alignment: .leading)
        }
        .padding(.leading, -10)
    }

    var costPerPersonView: some View {
            ForEach(people.filter { $0.isActive }) { person in
                Text("\(person.name): \(String(format: "%.2f", calculateBill(for: person)))").frame(alignment: .leading)
        }
    }
    
    var totalCostView: some View {
        
        HStack {
            
            Text("Total Cost: \(foodItems.reduce(0) { $0 + $1.totalPrice }, specifier: "%.2f")")
                .font(.headline)
                .frame(width: totalWidth, alignment: .leading)
        }.padding(.leading, -10)
        
        .background(Color.clear) // Make sure the background is clear to avoid any unwanted background color

    }
    
    var totalPaidView: some View {
        VStack(alignment: .leading) {
            Divider()
                .padding(.vertical, 10)
            
            let totalPaid = people.filter { $0.isActive }.reduce(0) { $0 + calculateBill(for: $1) }
            
            Text("Total Paid: \(String(format: "%.2f", totalPaid))")
                .font(.headline)
                .foregroundColor(.blue)
        }
        .padding(.top, -5)
        .padding(.bottom, 5)
    }




    func addNewPerson() {
        let newPerson = Person(name: newPersonName, isActive: false)
        people.append(newPerson)
        newPersonName = ""
        isAddingPerson = false
        isInputActive = false
    }

    func addFoodItem() {
        let newItem = newFoodItem
        newFoodItem = FoodItem()  // Reset the newFoodItem to have empty selected persons
        foodItems.append(newItem)
        print("New Food Item Added: \(newItem)")
    }

    func deleteFoodItem(at offsets: IndexSet) {
        foodItems.remove(atOffsets: offsets)
    }

    func calculateBill(for person: Person) -> Double {
        var totalBill = 0.0
        
        // Include the newFoodItem if the person is in eatingPersons
        if newFoodItem.eatingPersons.contains(where: { $0.id == person.id }) {
            let numberOfEaters = newFoodItem.eatingPersons.count
            if numberOfEaters > 0 {
                totalBill += newFoodItem.totalPrice / Double(numberOfEaters)
            }
        }
        
        // Include all existing food items
        for item in foodItems {
            if item.eatingPersons.contains(where: { $0.id == person.id }) {
                let numberOfEaters = item.eatingPersons.count
                if numberOfEaters > 0 {
                    totalBill += item.totalPrice / Double(numberOfEaters)
                }
            }
        }
        
        return totalBill
    }


    func updateNewTotal() {
        newFoodItem.quantity = newFoodItem.quantity
        newFoodItem.unitPrice = newFoodItem.unitPrice
    }

    func updateeatingPersons() {
        newFoodItem.eatingPersons = selectedPeople
        for index in foodItems.indices {
            foodItems[index].eatingPersons = selectedPeople
        }
    }
}

func formattedTotalPrice(for quantity: Double, unitPrice: Double) -> String {
    let total = quantity * unitPrice

    // Create a number formatter
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = 2
    formatter.decimalSeparator = ","

    // Convert the total to a string using the formatter
    return formatter.string(from: NSNumber(value: total)) ?? "\(total)"
}

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()
