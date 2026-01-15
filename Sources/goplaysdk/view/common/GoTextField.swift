import Combine
import SwiftUI

struct GoTextField<Validator: TextFieldValidator>: View {
    @Binding var text: String

    @ObservedObject var validator: Validator  // 👈 Use validator binding
    @State private var isPasswordVisible = false
    @Binding var keyBoardFocused: Bool
    var placeholder: String = ""
    var leftIconName: String? = nil
    var isSystemIcon: Bool = true
    var isPwd: Bool = false
    var widthBtn: CGFloat = 300
    private var paddingHorizontal: CGFloat = 16
    private var scaleFactor: CGFloat {
        return 1
        //        return UIScreen.main.scale
    }
    var keyboardType: UIKeyboardType = .default

    public init(
        text: Binding<String>,
        placeholder: String = "user name",
        isPwd: Bool = false,
        validator: Validator,
        widthBtn: CGFloat = 300,
        leftIconName: String? = nil,
        isSystemIcon: Bool = true,
        keyBoardFocused: Binding<Bool> = .constant(false),
        keyboardType: UIKeyboardType = .default
    ) {
        self._text = text  // ✅ Bindings use underscore!
        self.placeholder = placeholder
        self.leftIconName = leftIconName
        self.isSystemIcon = isSystemIcon
        self.validator = validator
        self.isPwd = isPwd
        self.widthBtn = widthBtn
        self._keyBoardFocused = keyBoardFocused  // 🟢 Bind the passed in `keyBoardFocused` state
        self.keyboardType = keyboardType
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                // Optional Left Icon (from assets in the main bundle)
                if isSystemIcon {
                    if let icon = leftIconName {
                        Image(systemName: icon).resizable()
                            .scaledToFit()
                            .frame(
                                width: 48 * scaleFactor,
                                height: 48 * scaleFactor
                            )
                            .clipped()
                    }
                } else {
                    if let icon = leftIconName,
                        let image = UIImage(
                            named: icon,
                            in: Bundle.goplaysdk,
                            compatibleWith: nil
                        )
                    {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: 48 * scaleFactor,
                                height: 48 * scaleFactor
                            )
                            .clipped()  // Trims any overflowing content
                    }
                }

                if isPwd && !isPasswordVisible {
                    //                    SecureField(placeholder, text: $text)
                    //                    .foregroundColor(Color.black)
                    ZStack(alignment: .leading) {
                        if text.isEmpty {
                            Text(placeholder)
                                .foregroundColor(Color.gray.opacity(0.5))
                        }

                        SecureField("", text: $text)
                            .foregroundColor(Color.black)
                    }
                    .font(.system(size: 16))
                    .padding(.vertical, 12)
                    .padding(.trailing, 12)
                    .autocorrectionDisabled(true)
                    .autocapitalization(.none)
                    .keyboardType(keyboardType)
                    //                        .focused($isFocused)
                } else {
                    //                    TextField(placeholder, text: $text)
                    //                    .foregroundColor(Color.black)
                    ZStack(alignment: .leading) {
                        if text.isEmpty {
                            Text(placeholder)
                                .foregroundColor(Color.gray.opacity(0.5))
                        }

                        TextField("", text: $text)
                            .foregroundColor(Color.black)
                    }
                    .font(.system(size: 16))
                    .foregroundColor(Color.black)
                    .padding(.vertical, 12)
                    .padding(.trailing, 12)
                    .autocorrectionDisabled(true)
                    .autocapitalization(.none)
                    .keyboardType(keyboardType)
                    //                        .focused($isFocused)
                }

                // Right Eye Icon
                if isPwd {
                    Button(action: {
                        isPasswordVisible.toggle()
                    }) {
                        Image(
                            systemName: isPasswordVisible
                                ? "eye.slash.fill" : "eye.fill"
                        )
                        .foregroundColor(.gray)
                    }
                    .padding(.trailing, 12)
                }

            }
            //            .frame(width: min(UIScreen.main.bounds.width - 2*paddingHorizontal, widthBtn))
            .frame(maxWidth: widthBtn == nil ? .infinity : widthBtn)
            //            .background(
            //                RoundedRectangle(cornerRadius: 12)
            //                    .stroke(Color.gray.opacity(0.1), lineWidth: 2))
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(  // Add border matching the clip shape
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        validator.isValid ? Color.gray.opacity(0.1) : Color.red,
                        lineWidth: 2
                    )
            )
            // Optional: Show validation error
            if !validator.isValid {
                Text(validator.errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        // Validate text input on change
        .onChangeCompat(of: text) { _ in
            if !validator.isValid {
                validator.validate(text: text)
            }
        }

    }

}
