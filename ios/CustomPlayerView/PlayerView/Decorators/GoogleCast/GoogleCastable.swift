import Foundation
typealias GoogleCastDecoratorType = PlayerDecoratorProtocol & GoogleCastable
/*LSP - Abstract interface shared by decorator and Playerview (core object)*/
protocol GoogleCastable {
  var accountId: String? { get set }
  var policyKey: String? { get set }
  func configureCastDecorator()
}
