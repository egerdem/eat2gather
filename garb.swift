//checkpoint
//import SwiftUI
//import Combine
//
//struct Person: Identifiable {
//    var id = UUID()
//    var name: String
//    var isSelected: Bool = false
//}
//
//struct FoodItem: Identifiable {
//    var id = UUID()
//    var type: String = ""
//    var quantity: Double = 0
//    var unitPrice: Double = 0
//    var totalPrice: Double {
//        return quantity * unitPrice
//    }
//    var selectedPersons: [Person] = []
//}
//
//struct ContentView: View {
//    @State private var people: [Person] = [
//        Person(name: "EE"),
//        Person(name: "MF"),
//        Person(name: "Ö"),
//        Person(name: "i")
//    ]
//    @State private var foodItems: [FoodItem] = []
//    @State private var newFoodType = ""
//    @State private var newQuantity: Double = 0
//    @State private var newUnitPrice: Double = 0
//    @State private var newPersonName = ""
//    @State private var isAddingPerson = false
//    @FocusState private var isInputActive: Bool
//    @State private var newSelectedPersons: [Person] = []
//
//    let numberFormatter: NumberFormatter = {
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .decimal
//        return formatter
//    }()
//    
//    let totalWidth = UIScreen.main.bounds.width - 160
//    let columnWidthRatios: [CGFloat] = [0.2, 0.15, 0.15, 0.2, 0.3]
//
//    var body: some View {
//        VStack {
//            Text("Eat #1 - \(Date(), formatter: dateFormatter)")
//                .padding(10)
//            Text("Select Eaters")
//                .foregroundColor(.gray)
//                .font(.footnote)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.bottom, -8)
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack(spacing: 10) {
//                    ForEach($people) { $person in
//                        Circle()
//                            .fill(person.isSelected ? Color.yellow : Color.gray.opacity(0.1))
//                            .frame(width: 40, height: 40)
//                            .overlay(
//                                Circle()
//                                    .stroke(Color.black, lineWidth: 1)
//                            )
//                            .overlay(Text(person.name))
//                            .onTapGesture {
//                                person.isSelected.toggle()
//                                
//                            }
//                    }
//                    addPersonButton
//                }
//                .padding(.vertical, 10)
//            }
//
//            foodItemsSection
//
//            totalCostView
//        }
//        .padding()
//    }
//
//    var addPersonButton: some View {
//        Group {
//            if isAddingPerson {
//                TextField("Name", text: $newPersonName)
//                    .font(.system(size: 12))
//                    .focused($isInputActive)
//                    .textFieldStyle(PlainTextFieldStyle())
//                    .frame(width: 40, height: 40)
//                    .background(Circle().fill(Color.gray.opacity(0.2)))
//                    .foregroundColor(.white)
//                    .multilineTextAlignment(.center)
//                    .autocapitalization(.words)
//                    .textContentType(.name)
//                    .onChange(of: isInputActive) { isActive in
//                        if !isActive && !newPersonName.isEmpty {
//                            addNewPerson()
//                        }
//                    }
//            } else {
//                Circle()
//                    .stroke(style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round, dash: [6]))
//                    .frame(width: 40, height: 40)
//                    .overlay(
//                        Text("+")
//                            .font(.title)
//                            .foregroundColor(.yellow)
//                    )
//                    .onTapGesture {
//                        isAddingPerson = true
//                        isInputActive = true
//                    }
//            }
//        }
//    }
//
//    var selectedPeople: [Person] {
//        return people.filter { $0.isSelected }
//    }
//
//    var foodItemsSection: some View {
//        VStack {
//            List {
//                Section(header: HStack(spacing: 10) {
//                    Text("food")
//                        .font(.system(size: 12))
//                        .frame(width: totalWidth * columnWidthRatios[0], alignment: .leading)
//                    Text("qty")
//                        .font(.system(size: 12))
//                        .frame(width: totalWidth * columnWidthRatios[1], alignment: .leading)
//                    Text("price")
//                        .font(.system(size: 12))
//                        .frame(width: totalWidth * columnWidthRatios[2], alignment: .leading)
//                    Text("total")
//                        .font(.system(size: 12))
//                        .frame(width: totalWidth * columnWidthRatios[3], alignment: .leading)
//                    Divider() // Divider added here
//                        .frame(height: 20) // Adjust height to match the row height
//                    Text("people")
//                        .font(.system(size: 12))
//                        .frame(alignment: .trailing)
//                }
//                .padding(.leading, -10)
//                .textCase(nil)) {
//                    HStack(spacing: 10) {
//                        TextField("type", text: $newFoodType)
//                            .frame(width: totalWidth * columnWidthRatios[0], alignment: .leading)
//                        TextField("qty", value: $newQuantity, formatter: numberFormatter)
//                            .frame(width: totalWidth * columnWidthRatios[1], alignment: .leading)
//                            .onChange(of: newQuantity) { _ in
//                                updateNewTotal()
//                            }
//                        TextField("price", value: $newUnitPrice, formatter: numberFormatter)
//                            .frame(width: totalWidth * columnWidthRatios[2], alignment: .leading)
//                            .onChange(of: newUnitPrice) { _ in
//                                updateNewTotal()
//                            }
//                        Text("\(newQuantity * newUnitPrice, specifier: "%.2f")")
//                            .frame(width: totalWidth * columnWidthRatios[3], alignment: .leading)
//                        Divider()
//                            .frame(height: 20)
//                            .background(Color.black)
//                        ScrollView(.horizontal, showsIndicators: false) {
//                            HStack(spacing: 5) {
//                                ForEach(selectedPeople) { person in
//                                    Circle()
//                                        .fill(newSelectedPersons.contains { $0.id == person.id } ? Color.green : Color.gray.opacity(0.2))
//                                        .overlay(Text(person.name))
//                                        .onTapGesture {
//                                            if let index = newSelectedPersons.firstIndex(where: { $0.id == person.id }) {
//                                                newSelectedPersons.remove(at: index)
//                                            } else {
//                                                newSelectedPersons.append(person)
//                                            }
//                                        }
//                                }
//                            }
//                        }
//                        .frame( alignment: .leading)
//                    }
//                    .padding(.leading, -10)
//                    .padding(.vertical, 5)
//                    
//                    ForEach($foodItems) { $item in
//                        HStack(spacing: 10) {
//                            TextField("type", text: $item.type)
//                                .frame(width: totalWidth * columnWidthRatios[0], alignment: .leading)
//                            TextField("qty", value: $item.quantity, formatter: numberFormatter)
//                                .frame(width: totalWidth * columnWidthRatios[1], alignment: .leading)
//                            TextField("price", value: $item.unitPrice, formatter: numberFormatter)
//                                .frame(width: totalWidth * columnWidthRatios[2], alignment: .leading)
//                            Text("\(item.totalPrice, specifier: "%.2f")")
//                                .frame(width: totalWidth * columnWidthRatios[3], alignment: .leading)
//                            Divider()
//                                .frame(height: 20)
//                                .background(Color.black)
//                            ScrollView(.horizontal, showsIndicators: false) {
//                                HStack(spacing: 5) {
//                                    ForEach(selectedPeople) { person in
//                                        Circle()
//                                            .fill(item.selectedPersons.contains { $0.id == person.id } ? Color.green : Color.gray.opacity(0.2))
//                                            .overlay(Text(person.name))
//                                            .onTapGesture {
//                                                if let index = item.selectedPersons.firstIndex(where: { $0.id == person.id }) {
//                                                    item.selectedPersons.remove(at: index)
//                                                } else {
//                                                    item.selectedPersons.append(person)
//                                                }
//                                            }
//                                    }
//                                }
//                            }
//                            .frame(alignment: .leading)
//                        }
//                        .padding(.leading, -10)
//                        .padding(.vertical, 5)
//                    }
//                    .onDelete(perform: deleteFoodItem)
//                    
//                    HStack {
//                        Spacer()
//                        Circle()
//                            .fill(Color.blue.opacity(0.2))
//                            .frame(width: 30, height: 30)
//                            .overlay(Text("+").foregroundColor(.white))
//                            .onTapGesture {
//                                addFoodItem()
//                            }
//                        Spacer()
//                    }
//                }
//            }
//        }
//    }
//
//    var totalCostView: some View {
//        VStack {
//            ForEach(people.filter { $0.isSelected }) { person in
//                Text("\(person.name): \(String(format: "%.2f", calculateBill(for: person)))")
//            
//            }
//        }
//    }
//
//    func addNewPerson() {
//        let newPerson = Person(name: newPersonName, isSelected: false)
//        people.append(newPerson)
//        newPersonName = ""
//        isAddingPerson = false
//        isInputActive = false
//    }
//
//    func addFoodItem() {
//        let newItem = FoodItem(type: newFoodType, quantity: newQuantity, unitPrice: newUnitPrice, selectedPersons: newSelectedPersons)
//        foodItems.append(newItem)
//        newFoodType = ""
//        newQuantity = 1
//        newUnitPrice = 0
//        newSelectedPersons = []
//    }
//
//    func deleteFoodItem(at offsets: IndexSet) {
//        foodItems.remove(atOffsets: offsets)
//    }
//
//    func calculateBill(for person: Person) -> Double {
//        var totalBill = 0.0
//        for item in foodItems {
//            if item.selectedPersons.contains(where: { $0.id == person.id }) {
//                let numberOfEaters = item.selectedPersons.count
//                if numberOfEaters > 0 {
//                    totalBill += item.totalPrice / Double(numberOfEaters)
//                }
//            }
//        }
//        return totalBill
//    }
//
//    func updateNewTotal() {
//        newQuantity = newQuantity
//        newUnitPrice = newUnitPrice
//    }
//}
//
//let dateFormatter: DateFormatter = {
//    let formatter = DateFormatter()
//    formatter.dateStyle = .short
//    return formatter
//}()

//func updateSelectedPersons(person: Person) {
//    if person.isSelected {
//        newSelectedPersons.append(person)
//    } else {
//        if let index = newSelectedPersons.firstIndex(where: { $0.id == person.id }) {
//            newSelectedPersons.remove(at: index)
//        }
//    }
//}
//

//import SwiftUI
//import Combine
//
//struct Person: Identifiable {
//    var id = UUID()
//    var name: String
//    var isSelected: Bool = false
//}
//
//struct FoodItem: Identifiable {
//    var id = UUID()
//    var type: String = ""
//    var quantity: Double = 0
//    var unitPrice: Double = 0
//    var totalPrice: Double {
//        return quantity * unitPrice
//    }
//    var selectedPersons: [Person] = []
//}
//
//struct ContentView: View {
//    @State private var people: [Person] = [
//        Person(name: "EE"),
//        Person(name: "MF"),
//        Person(name: "Ö"),
//        Person(name: "i")
//    ]
//    @State private var foodItems: [FoodItem] = []
//    @State private var newFoodType = ""
//    @State private var newQuantity: Double = 0
//    @State private var newUnitPrice: Double = 0
//    @State private var newPersonName = ""
//    @State private var isAddingPerson = false
//    @FocusState private var isInputActive: Bool
//    @State private var newSelectedPersons: [Person] = []
//
//    let numberFormatter: NumberFormatter = {
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .decimal
//        return formatter
//    }()
//
//    var body: some View {
//        VStack {
//            Text("Eat #1 - \(Date(), formatter: dateFormatter)")
//                .padding(10)
//            Text("Select Eaters")
//                .foregroundColor(.gray)
//                .font(.footnote)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.bottom, -8)
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack(spacing: 10) {
//                    ForEach($people) { $person in
//                        Circle()
//                            .fill(person.isSelected ? Color.yellow : Color.gray.opacity(0.1))
//                            .frame(width: 40, height: 40)
//                            .overlay(
//                                Circle()
//                                    .stroke(Color.black, lineWidth: 1)
//                            )
//                            .overlay(Text(person.name))
//                            .onTapGesture {
//                                    person.isSelected.toggle()
//                                    updateSelectedPersons(person: person)
//                            }
//                    }
//                    addPersonButton
//                }
//                .padding(.vertical, 10)
//            }
//
//            foodItemsSection
//
//            totalCostView
//        }
//        .padding()
//    }
//
//    var addPersonButton: some View {
//        Group {
//            if isAddingPerson {
//                TextField("Name", text: $newPersonName)
//                    .font(.system(size: 12))
//                    .focused($isInputActive)
//                    .textFieldStyle(PlainTextFieldStyle())
//                    .frame(width: 40, height: 40)
//                    .background(Circle().fill(Color.gray.opacity(0.2)))
//                    .foregroundColor(.white)
//                    .multilineTextAlignment(.center)
//                    .autocapitalization(.words)
//                    .textContentType(.name)
//                    .onChange(of: isInputActive) { isActive in
//                        if !isActive && !newPersonName.isEmpty {
//                            addNewPerson()
//                        }
//                    }
//            } else {
//                Circle()
//                    .stroke(style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round, dash: [6]))
//                    .frame(width: 40, height: 40)
//                    .overlay(
//                        Text("+")
//                            .font(.title)
//                            .foregroundColor(.yellow)
//                    )
//                    .onTapGesture {
//                        isAddingPerson = true
//                        isInputActive = true
//                    }
//            }
//        }
//    }
//
//    var selectedPeople: [Person] {
//        return people.filter { $0.isSelected }
//    }
//
//    var foodItemsSection: some View {
//        let totalWidth = UIScreen.main.bounds.width - 160
//        let columnWidths: [CGFloat] = [0.2, 0.15, 0.15, 0.2, 0.3]
//        
//        return VStack {
//            List {
//                Section(header: HStack(spacing: 10) {
//                    Text("food")
//                        .font(.system(size: 12))
//                        .frame(width: totalWidth * columnWidths[0], alignment: .leading)
//                    Text("qty")
//                        .font(.system(size: 12))
//                        .frame(width: totalWidth * columnWidths[1], alignment: .leading)
//                    Text("price")
//                        .font(.system(size: 12))
//                        .frame(width: totalWidth * columnWidths[2], alignment: .leading)
//                    Text("total")
//                        .font(.system(size: 12))
//                        .frame(width: totalWidth * columnWidths[3], alignment: .leading)
//                    Divider() // Divider added here
//                        .frame(height: 20) // Adjust height to match the row height
//                    Text("people")
//                        .font(.system(size: 12))
//                        .frame(alignment: .trailing)
//                }
//                .padding(.leading, -10)
//                .textCase(nil)) {
//                    HStack(spacing: 10) {
//                        TextField("type", text: $newFoodType)
//                            .frame(width: totalWidth * columnWidths[0], alignment: .leading)
//                        TextField("quantity", value: $newQuantity, formatter: numberFormatter)
//                            .frame(width: totalWidth * columnWidths[1], alignment: .leading)
//                            .onChange(of: newQuantity) { _ in
//                                updateNewTotal()
//                            }
//                        TextField("price", value: $newUnitPrice, formatter: numberFormatter)
//                            .frame(width: totalWidth * columnWidths[2], alignment: .leading)
//                            .onChange(of: newUnitPrice) { _ in
//                                updateNewTotal()
//                            }
//                        Text("\(newQuantity * newUnitPrice, specifier: "%.2f")")
//                            .frame(width: totalWidth * columnWidths[3], alignment: .leading)
//                        Divider()
//                            .frame(height: 20)
//                            .background(Color.black)
//                        ScrollView(.horizontal, showsIndicators: false) {
//                            HStack(spacing: 5) {
//                                ForEach(newSelectedPersons) { person in
//                                    Circle()
//                                        .fill(newSelectedPersons.contains { $0.id == person.id } ? Color.green : Color.gray.opacity(0.2))
//                                        .frame(width: 30, height: 30)
//                                        .overlay(Text(person.name))
//                                        .onTapGesture {
//                                            if let index = newSelectedPersons.firstIndex(where: { $0.id == person.id }) {
//                                                newSelectedPersons.remove(at: index)
//                                            } else {
//                                                newSelectedPersons.append(person)
//                                            }
//                                        }
//                                }
//                            }
//                        }
//                        .frame(alignment: .leading)
//                    }
//                    .padding(.leading, -10)
//                    .padding(.vertical, 5)
//                    
//                    ForEach($foodItems) { $item in
//                        HStack(spacing: 10) {
//                            TextField("type", text: $item.type)
//                                .frame(width: totalWidth * columnWidths[0], alignment: .leading)
//                            TextField("quantity", value: $item.quantity, formatter: numberFormatter)
//                                .frame(width: totalWidth * columnWidths[1], alignment: .leading)
//                            TextField("price", value: $item.unitPrice, formatter: numberFormatter)
//                                .frame(width: totalWidth * columnWidths[2], alignment: .leading)
//                            Text("\(item.totalPrice, specifier: "%.2f")")
//                                .frame(width: totalWidth * columnWidths[3], alignment: .leading)
//                            Divider()
//                                .frame(height: 20)
//                                .background(Color.black)
//                            ScrollView(.horizontal, showsIndicators: false) {
//                                HStack(spacing: 5) {
//                                    ForEach(item.selectedPersons) { person in
//                                        Circle()
//                                            .fill(item.selectedPersons.contains { $0.id == person.id } ? Color.green : Color.gray.opacity(0.2))
//                                            .overlay(Text(person.name))
//                                            .onTapGesture {
//                                                if let index = item.selectedPersons.firstIndex(where: { $0.id == person.id }) {
//                                                    item.selectedPersons.remove(at: index)
//                                                } else {
//                                                    item.selectedPersons.append(person)
//                                                }
//                                            }
//                                    }
//                                }
//                            }
//                            .frame(width: columnWidths[4], alignment: .leading)
//                        }
//                        .padding(.leading, -10)
//                        .padding(.vertical, 5)
//                    }
//                    .onDelete(perform: deleteFoodItem)
//                    
//                    HStack {
//                        Spacer()
//                        Circle()
//                            .fill(Color.blue.opacity(0.2))
//                            .frame(width: 30, height: 30)
//                            .overlay(Text("+").foregroundColor(.white))
//                            .onTapGesture {
//                                addFoodItem()
//                            }
//                        Spacer()
//                    }
//                }
//            }
//        }
//    }
//
//    var totalCostView: some View {
//        VStack {
//            ForEach(people.filter { $0.isSelected }) { person in
//                Text("\(person.name): \(String(format: "%.2f", calculateBill(for: person)))")
//            }
//        }
//    }
//
//    func addNewPerson() {
//        let newPerson = Person(name: newPersonName, isSelected: false)
//        people.append(newPerson)
//        newPersonName = ""
//        isAddingPerson = false
//        isInputActive = false
//    }
//
//    func addFoodItem() {
//        let newItem = FoodItem(type: newFoodType, quantity: newQuantity, unitPrice: newUnitPrice, selectedPersons: newSelectedPersons)
//        foodItems.append(newItem)
//        newFoodType = ""
//        newQuantity = 1
//        newUnitPrice = 0
//        newSelectedPersons = []
//    }
//
//    func deleteFoodItem(at offsets: IndexSet) {
//        foodItems.remove(atOffsets: offsets)
//    }
//
//    func calculateBill(for person: Person) -> Double {
//        var totalBill = 0.0
//        for item in foodItems {
//            if item.selectedPersons.contains(where: { $0.id == person.id }) {
//                let numberOfEaters = item.selectedPersons.count
//                if numberOfEaters > 0 {
//                    totalBill += item.totalPrice / Double(numberOfEaters)
//                }
//            }
//        }
//        return totalBill
//    }
//
//    func updateNewTotal() {
//        newQuantity = newQuantity
//        newUnitPrice = newUnitPrice
//    }
//
//    func updateSelectedPersons(person: Person) {
//        if person.isSelected {
//            newSelectedPersons.append(person)
//        } else {
//            if let index = newSelectedPersons.firstIndex(where: { $0.id == person.id }) {
//                newSelectedPersons.remove(at: index)
//            }
//        }
//    }
//}
//
//let dateFormatter: DateFormatter = {
//    let formatter = DateFormatter()
//    formatter.dateStyle = .short
//    return formatter
//}()
