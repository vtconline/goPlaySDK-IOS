//
//  Untitled.swift
//  goplaysdk
//
//  Created by Ngô Đồng on 17/4/25.
//

import Combine

// Generic ViewModel with a @Published property
public class GoPlayViewModel<T>: ObservableObject {
    @Published var data: T

    init(data: T) {
        self.data = data
    }
    
    // Method required to conform to Hashable
//        func hash(into hasher: inout Hasher) {
//            hasher.combine(data) // Combine the data property into the hash function
//        }
//
//        // Required equality check method for Hashable
//        static func == (lhs: GoPlayViewModel<T>, rhs: GoPlayViewModel<T>) -> Bool {
//            return lhs.data == rhs.data // Compare the data property for equality
//        }
       
    
}


// Using the generic ViewModel with a String
//let stringViewModel = MyViewModel(data: "Hello, World!") data can be struct, class,...
//let stringObserver = GenericObserver(viewModel: stringViewModel)
//
//stringViewModel.data = "New String!" // This triggers the observer

/*example for view
 struct ContentView: View {
     @StateObject private var user = UserModel(name: "Hùng", age: 25)

     @State private var showEdit = false

     var body: some View {
         VStack {
             Text("Tên: \(user.name), Tuổi: \(user.age)")

             Button("Sửa thông tin") {
                 showEdit = true
             }
             .sheet(isPresented: $showEdit) {
                 EditUserView(user: user) // truyền object
             }
         }
         .padding()
     }
 }

 
 
 View con: dùng @ObservedObject
 swift
 Copy
 Edit
 struct EditUserView: View {
     @ObservedObject var user: UserModel

     var body: some View {
         VStack(spacing: 20) {
             TextField("Tên", text: $user.name)
                 .textFieldStyle(.roundedBorder)

             Stepper("Tuổi: \(user.age)", value: $user.age, in: 1...100)
         }
         .padding()
     }
 }
 
 */
