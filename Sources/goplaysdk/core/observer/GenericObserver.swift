import Combine
import Foundation

// Conforming to Sendable if needed (for concurrency)
@MainActor
@objc public class GenericObserver: NSObject {
    // Dictionary to track subscriptions
    private var cancellables: [AnyHashable: AnyCancellable] = [:]
    private let lock = NSLock()
//    let loginResultPublisher = PassthroughSubject<LoginResultObjC, Never>()

    // Singleton instance
    @objc public static let shared = GenericObserver()

    // Private initializer to enforce Singleton usage
    private override init() {}

    // Function to observe changes to the entire data of a GoPlayViewModel
    public func observe<T>(
        viewModel: GoPlayViewModel<T>,
        onChange: @escaping (T) async -> Void
    ) {

        let cancellable = viewModel.$data
            //            .sink(receiveValue: onChange)
//            .receive(on: RunLoop.main)
            .sink { value in
                // Since it's async, call it with await inside a Task
                Task {
                    await onChange(value)
                }
            }

    }

    public func observeProperty<T, U>(
        viewModel: GoPlayViewModel<T>,
        keyPath: KeyPath<T, U>,
        onChange: @escaping (U) -> Void
    ) {
        let cancellable = viewModel.$data
            .map { $0[keyPath: keyPath] }
            .sink(receiveValue: onChange)

        let id = ObjectIdentifier(viewModel)
        cancellables[id] = cancellable

    }
    /*
     must manual-canceled subscription when not use
     Swift usage only: generic observer (cannot be @objc)
     */
    public func observePublisher<T>(
        publisher: AnyPublisher<T, Never>,
        id: AnyHashable,
        onChange: @escaping (T) -> Void
    ) {

        let cancellable =
            publisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: onChange)
        lock.lock()
        cancellables[ObjectIdentifierWrapper(id)] = cancellable
        lock.unlock()
    }
    /* Auto-canceled subscription  after get data 1st time*/
    public func observePublisherOnce<T>(
        publisher: AnyPublisher<T, Never>,
        id: AnyHashable,
        onChange: @escaping (T) -> Void
    ) {
        var cancellable: AnyCancellable? = nil

        cancellable = publisher.receive(on: RunLoop.main).sink { [weak self] value in
            onChange(value)

            // Cancel and remove after first event
            if let self = self, let cancellable = cancellable {
                self.cancellables[id]?.cancel()
                self.cancellables.removeValue(forKey: id)
                //print("Auto-canceled subscription for \(id)")
            }
        }

        if let cancellable = cancellable {
            lock.lock()
            cancellables[id] = cancellable
            lock.unlock()
        }
    }

    // ObjC-compatible method: observe LoginResult
    @objc public func startObservingLoginResultForTarget(
        goPlayAction: NSString,
        target: NSObject,
        selector: Selector
    ) {
        guard let publisher = resolvePublisher(for: goPlayAction as String)
        else {
            print("⚠️ Không tìm thấy publisher cho action: \(goPlayAction)")
            return
        }
        let cancellable =
            publisher
            .receive(on: RunLoop.main)
            .sink { [weak target] result in
//                print("✅ ==== Đã nhận được login result: \(result)")

                guard let target = target else { return }

                if target.responds(to: selector) {
                    _ = target.perform(selector, with: result)
//                    print("✅ phản hồi selector: \(selector)")
                } else {
//                    print("❌ Không phản hồi selector: \(selector)")
                }
            }

        lock.lock()
        cancellables[goPlayAction] = cancellable
        lock.unlock()
    }

    // Optional: cancel observer by id
    @objc public func cancelObserver(goPlayAction: NSString) {
        lock.lock()
        cancellables[goPlayAction]?.cancel()
        cancellables.removeValue(forKey: goPlayAction)
        lock.unlock()
    }

    // Function to cancel subscription for a specific ViewModel
    public func cancelSubscription<T>(for viewModel: GoPlayViewModel<T>?) {
        guard let viewModel else { return }
        let id = ObjectIdentifier(viewModel)
        cancellables[id]?.cancel()  // Cancel the subscription for the specific ViewModel
        cancellables.removeValue(forKey: id)  // Remove the cancellable from the dictionary
        print("Subscription canceled for \(viewModel)")

    }

    @objc public func cancelSubscriptionByID(for id: AnyHashable) {
        cancellables[id]?.cancel()
        cancellables.removeValue(forKey: id)
        print("Subscription canceled for \(id)")
    }

    // Function to cancel all subscriptions
    @objc public func cancelAll() {
        cancellables.forEach { $0.value.cancel() }  // Cancel all subscriptions
        cancellables.removeAll()  // Remove all entries from the dictionary
        print("All subscriptions canceled.")

    }

    // Helper to make AnyHashable act like ObjectIdentifier
    private struct ObjectIdentifierWrapper: Hashable {
        let id: AnyHashable

        init(_ id: AnyHashable) {
            self.id = id
        }
    }

    private func resolvePublisher(for action: String) -> AnyPublisher<
        AnyObject, Never
    >? {
        switch action {
        case GoPlayEvent.loginResult:
            return AuthService.shared.loginResultPublisher
                .map { $0 as AnyObject }
                .eraseToAnyPublisher()
        case GoPlayEvent.logoutResult:
            return AuthService.shared.logoutResultPublisher
                .map { $0 as AnyObject }
                .eraseToAnyPublisher()
        case GoPlayEvent.linkingAccount:
            return AuthService.shared.accountLinkingPublisher
                .map { $0 as AnyObject }
                .eraseToAnyPublisher()
        case GoPlayEvent.tokenExpire:
            return AuthService.shared.resResultPublisher
                .map { $0 as AnyObject }
                .eraseToAnyPublisher()

        default:
            print("GoPlaySDK::GenericObserver.resolvePublisher:: must return != nil if want event get fire!!!")
            return nil
        }
    }
}

/*
 Usage1:
 GenericObserver.shared.observePublisher(
     publisher: AuthManager.shared.loginResultPublisher.eraseToAnyPublisher(),
     id: "loginResult"
 ) { result in
     switch result {
     case .success(let user):
         print("Login succeeded for user: \(user.userName ?? "")")
         // Handle successful login
     case .failure(let error):
         print("Login failed with error: \(error)")
         // Handle login error
     }
 }
 */

/* USAGE: example
 struct Person {
     var name: String
     var age: Int
 }
 let person = Person(name: "John", age: 30)
 let viewModel = GoPlayViewModel(data: person)
 // Access the singleton GenericObserver
 GenericObserver.shared.observe(viewModel: viewModel) { updatedPerson in
     print("Person object updated: \(updatedPerson)")
 }

 // Observe a specific property (name) of the Person object
 GenericObserver.shared.observeProperty(viewModel: viewModel, keyPath: \Person.name) { newName in
     print("Person's name changed to: \(newName)")
 }

 // Update the entire object and individual property
 viewModel.data = Person(name: "Jane", age: 25)  // Triggers both observers
 viewModel.data.name = "Alice"  // Triggers only the property observer

 // Output:
 // Person object updated: Person(name: "Jane", age: 25)
 // Person's name changed to: Alice

 */
