import Foundation
import SwiftUICore
import CommonCrypto
import CryptoKit

public class Utils {
    @discardableResult
    static func startCountdown(
        totalSeconds: Int,
        onTick: @escaping (_ secondsLeft: Int) -> Void,
        onFinish: @escaping () -> Void
    ) -> Timer {
        var secondsLeft = totalSeconds

        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            secondsLeft -= 1
            onTick(secondsLeft)

            if secondsLeft <= 0 {
                timer.invalidate()
                onFinish()
            }
        }

        // Fire the first tick immediately (optional)
        onTick(secondsLeft)

        return timer
    }
    @MainActor static func getPartnerParams() -> [String: Any] {
        var params = [String: Any]()
        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        let majorVersion = osVersion.majorVersion
        let minorVersion = osVersion.minorVersion
        let patchVersion = osVersion.patchVersion
        params["osver"] = "iOS: \(majorVersion).\(minorVersion).\(patchVersion)"
        params["appver"] = ""
        params["dvId"] = GoPlayUUID.shared.userUUID
        params["os"] = "ios"
        params["ip"] = ""

        return params
    }
    static func md5(_ string: String) -> String {
        let digest = Insecure.MD5.hash(data: Data(string.utf8))
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
    static func generateHashMD5(input: String?) -> String? {
        guard let input = input else { return nil }

        let data = Data(input.utf8)
        var hash = Data(count: Int(CC_MD5_DIGEST_LENGTH))

        _ = hash.withUnsafeMutableBytes { hashBytes in
            data.withUnsafeBytes { messageBytes in
                CC_MD5(messageBytes.baseAddress, CC_LONG(data.count), hashBytes.baseAddress?.assumingMemoryBound(to: UInt8.self))
            }
        }

        let hexString = hash.map { String(format: "%02hhx", $0) }.joined()
        return hexString
    }
    
    static func removeSign(jwt: String?) -> String? {
        guard let jwt = jwt else { return nil }
        let parts = jwt.split(separator: ".")
        guard parts.count >= 2 else { return nil }
        return "\(parts[0]).\(parts[1])."
    }

    static func parseClaimsJwt(jwt: String) -> [String: Any]? {
        let parts = jwt.split(separator: ".")
        guard parts.count > 1 else { return nil }
        let payload = parts[1]
        
        // Decode Base64
        var payloadString = String(payload)
        let requiredLength = (4 * ((payloadString.count + 3) / 4))
        let paddingLength = requiredLength - payloadString.count
        if paddingLength > 0 {
            payloadString += String(repeating: "=", count: paddingLength)
        }
        
        guard let payloadData = Data(base64Encoded: payloadString, options: .ignoreUnknownCharacters) else {
            return nil
        }
        do {
            let json = try JSONSerialization.jsonObject(with: payloadData, options: [])
            return json as? [String: Any]
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
