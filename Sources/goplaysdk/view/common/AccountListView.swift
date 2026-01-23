//
//  AccountListView.swift
//  goplaysdk
//
//  Created by pate
//

import SwiftUI

struct AccountListView: View {
    @StateObjectCompat private var vm = AccountListViewModel()
    @State private var showAlert = false
    @State private var selectedAccount: Account?


    
    private let onUserSelect: ((_ user: Account) -> Void)?

    public init(
        onUserSelect: ((_ user: Account) -> Void)? = nil
    ) {
        
        self.onUserSelect = onUserSelect
    }

    var body: some View {
        Group {
            if vm.accounts.count > 0 {
                Text("Các tài khoản đã lưu").frame(
                    maxWidth: min(
                        UIScreen.main.bounds.width - 2
                            * AppTheme.Paddings.horizontal,
                        AppTheme.Buttons.defaultWidth
                    ),
                    alignment: .leading
                )
            }
            listNormal
        }

    }

    @ViewBuilder
    private var listNormal: some View {
        List {
            ForEach(vm.accounts, id: \.userId) { account in
                HStack {
                    
                    if let image = UIImage(
                            named: "avatar-login",
                            in: Bundle.goplaysdk,
                            compatibleWith: nil
                        )
                    {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: 24,
                                height: 24
                            )
                            .clipped()  // Trims any overflowing content
                    }
                    
                    Text(account.username)
                    Spacer()

                    Button {
//                        vm.deleteAccount(account)
                        showAlert = true
                        selectedAccount = account
                    } label: {
                        Image(systemName: "trash")
                    }
                    
                    .buttonStyle(BorderlessButtonStyle())  // ⭐
                }
                .contentShape(Rectangle())
                .listRowInsets(EdgeInsets())
                .onTapGesture {
                    
                    onUserSelect?(account)
                }
            }
        }
        .frame(
            maxWidth: min(
                UIScreen.main.bounds.width - 2 * AppTheme.Paddings.horizontal,
                AppTheme.Buttons.defaultWidth
            ),
            alignment: .leading
        )
        .listStyle(PlainListStyle())
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Xác nhận"),
                message: Text("Bạn có chắc muốn bỏ lưu tài khoản \(selectedAccount?.username ?? "")  không?"),
                
                primaryButton: .destructive(Text("OK")) {
                    if let acc = selectedAccount {
                        vm.deleteAccount(acc)
                    }
                    selectedAccount = nil
                },
                secondaryButton: .cancel(Text("Huỷ")) {
                    selectedAccount = nil
                }
            )
        }

    }



    private var listWithSwipeDelete: some View {
        List {
            ForEach(vm.accounts, id: \.userId) { account in
                Text(account.username)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        print("Click:", account.username)

                    }
            }
            .onDelete { indexSet in
                indexSet.forEach {
                    vm.deleteAccount(vm.accounts[$0])
                }
            }
        }
    }

}

final class AccountListViewModel: ObservableObject {
    @Published var accounts: [Account] = []

    init() {
        load()
    }

    func load() {
        accounts = AccountManager.allAccounts()
    }

    func deleteAccount(_ account: Account) {
        let result = AccountManager.removeAccount(userId: account.userId)
        switch result {
        case .success:
            print("❌ Delete account done:")
            load()
        case .failure(let error):
            print("❌ Delete account failed:", error)
        }
    }
}
