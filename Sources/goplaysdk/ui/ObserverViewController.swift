//
//  GoPlayUIViewController.swift
//  goplaysdk
//
//  Created by Ngô Đồng on 17/4/25.
//
import UIKit
import Combine
class ObserverViewController<T>: UIViewController {
    var viewModel: GoPlayViewModel<T>?

    /// Optional override — if nil is returned, no subscription is made
    func provideInitialData() -> T? {
        return nil  // Default: no data
    }

    override func viewDidLoad(){
        super.viewDidLoad()
    
    }
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        initObserver()
    }
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        guard let viewModel = self.viewModel else { return }

        GenericObserver.shared.cancelSubscription(for: viewModel)
    }
    
    func initObserver() {
        // Try to create the viewModel
        if let initialData = provideInitialData() {
            // Assign initial data to viewModel
            viewModel = GoPlayViewModel(data: initialData)

            // Safely unwrap the viewModel
            guard let vm = self.viewModel else {
                print("⚠️ ViewModel is nil. Observer will not be attached.")
                return
            }
            // Start observing the ViewModel asynchronously using Task
            Task {
                 GenericObserver.shared.observe(viewModel: vm) { [weak self] data in
                    // Ensure that any UI updates (MainActor actions) are done on the main thread
                    await MainActor.run {
                        self?.onDataChanged(data)
                    }
                }
            }
        } else {
            print("⚠️ No data provided. Observer will not be attached.")
        }
    }



    
    func onDataChanged(_ data: T) {
        print("🔁 GoPlayViewController:Data updated: \(data)")
    }
}

//example
//struct User {
//    var name: String
//    var age: Int
//}
//
//class UserViewController: ObserverViewController<User> {
//    override func provideInitialData() -> User {
//        return User(name: "Alice", age: 25)
//    }
//
//    override func onDataChanged(_ data: User) {
//        print("👤 User changed: \(data.name), \(data.age)")
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//        // Simulate a data change
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            self.viewModel.data = User(name: "Bob", age: 30)
//        }
//    }
//}

