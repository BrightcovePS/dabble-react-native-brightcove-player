import Foundation
typealias GoogleCastDecoratorType = PlayerDecoratorProtocol & GoogleCastable
/*LSP - Abstract interface shared by decorator and Playerview (core object)*/
protocol GoogleCastable {
  func configureCastDecorator()
}
