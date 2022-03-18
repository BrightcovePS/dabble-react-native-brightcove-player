import UIKit
import BrightcovePlayerSDK
protocol PlayerDecoratorProtocol {
  /*Every conforming object needs to have an instance of RBPlayerView*/
  var playerView: PlayerView? { get set }
  /* PlayerView init */
  init(_ playerView: PlayerView)
}
/* Interface segregation principle - We dont want currentSession to mix up with  ClosedCaptionable conforming classes and hence segreagating them */
protocol SessionReferenceable: AnyObject {
  var session: BCOVPlaybackSession? { get set }
}
