import UIKit
class AsyncImageLoader: NSObject {
  func downloadAndCacheImage(url:String, onSuccess:@escaping (_ image:UIImage?, _ url: String) -> Void, onFailure:@escaping (_ error:Error?) -> Void) -> Void {
    let finalUrl = URL(string: url )
    if let image = AsyncImageLoaderManager.sharedInstance.getImage(forUrl: url){
      onSuccess(image, url)
    }else{
      URLSession.shared.dataTask(with: finalUrl!, completionHandler: { (data, response, error) in
        if error != nil {
          print(error!)
          onFailure(error)
        }else{
          if let imageData = data,
             let image = UIImage(data: imageData){
            AsyncImageLoaderManager.sharedInstance.setImage(image: image, forKey: url)
            onSuccess(image, url)
          }else{
            onFailure(NSError(domain: StringConstants.kEmptyString, code: 100, userInfo: ["reason":"Unable to download image"]))
          }
        }
      }).resume()
    }
  }
  func cancelTask() {
    URLSession.shared.invalidateAndCancel()
  }
}
