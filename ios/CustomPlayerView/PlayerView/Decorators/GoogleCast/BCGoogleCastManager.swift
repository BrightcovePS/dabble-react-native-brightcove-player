import Foundation
import GoogleCast
import BrightcovePlayerSDK
import BrightcoveGoogleCast
@objc public class BCGoogleCastManager: NSObject {
  static let shared = BCGoogleCastManager()
  var accountId = StringConstants.kEmptyString
  var policyKey = StringConstants.kEmptyString
  lazy var googleCastManager: BCOVGoogleCastManager = {
      let receiverAppConfig = BCOVReceiverAppConfig()
      receiverAppConfig.accountId = accountId
      receiverAppConfig.policyKey = policyKey
      receiverAppConfig.splashScreen = "https://solutions.brightcove.com/jblaker/cast-splash.jpg"
      return BCOVGoogleCastManager(forBrightcoveReceiverApp: receiverAppConfig)
  }()
  private override init() {}
}
