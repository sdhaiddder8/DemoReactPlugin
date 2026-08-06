import UIKit
import EkeySDK

/// Swift-side bridge between the ObjC++ Turbo Module (EkeySdkModule.mm) and the vendored
/// EkeySDK.xcframework. Kept separate from the .mm file since EkeyLoginResult's
/// associated-value enum cases aren't representable in Objective-C directly — this converts
/// them to a plain NSDictionary the .mm file can hand straight to the JS promise resolver.
@objc(EkeySdkImpl)
public final class EkeySdkImpl: NSObject {
    @objc public static let shared = EkeySdkImpl()

    private override init() {}

    @objc public func initiateLogin(resolve: @escaping (NSDictionary) -> Void) {
        // Turbo Module methods run on RN's native-modules background queue by default, but
        // everything here (finding the presenting view controller, creating the WKWebView,
        // presenting UIKit) must happen on the main thread.
        DispatchQueue.main.async {
            guard let presenter = Self.topViewController() else {
                resolve(["status": "failed", "error": "noRootViewController"])
                return
            }

            Ekey.shared.initiateLogin(from: presenter) { result in
                switch result {
                case .completed(let redirectURL):
                    resolve(["status": "completed", "redirectUri": redirectURL.absoluteString])
                case .cancelled:
                    resolve(["status": "cancelled"])
                case .failed(let error):
                    resolve(["status": "failed", "error": String(describing: error)])
                }
            }
        }
    }

    private static func topViewController() -> UIViewController? {
        guard var top = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?.rootViewController
        else {
            return nil
        }
        while let presented = top.presentedViewController {
            top = presented
        }
        return top
    }
}
