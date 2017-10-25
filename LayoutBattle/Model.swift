//
//  Created by Pavel Sharanda on 28.02.17.
//  Copyright © 2017 psharanda. All rights reserved.
//

import UIKit
import Atributika

struct TweetModel {
    
    let name: String
    let username: String
    let displayableDate: String
    let tweet: String
    let thumbnail: UIImage?
    
    var attributedName = NSAttributedString()
    var attributedTweet = NSAttributedString()
    var attributedDate = NSAttributedString()
    
    init(name: String, username: String, displayableDate: String, tweet: String, thumbnail: UIImage?) {
        self.name = name
        self.username = username
        self.displayableDate = displayableDate
        self.tweet = tweet
        self.thumbnail = thumbnail
        
        attributedDate = _attributedDate
        attributedTweet = _attributedTweet
        attributedName = _attributedName
    }
    
    init() {
        self.name = ""
        self.username = ""
        self.displayableDate = ""
        self.tweet = ""
        self.thumbnail = nil
        
    }
}

extension TweetModel {
    
    static func stubData() -> [TweetModel] {
        
        let images = [#imageLiteral(resourceName: "thumb-felix"), #imageLiteral(resourceName: "thumb-eloy"), #imageLiteral(resourceName: "thumb-javi"), #imageLiteral(resourceName: "thumb-nacho")]
        
        let hashtags = Lorem.words(4).components(separatedBy: " ").map { (" #\($0)")}.joined()
        
        return (0..<500).map { idx in
            TweetModel(name: Lorem.name, username: Lorem.email, displayableDate: "30m", tweet: Lorem.sentences(3).appending(hashtags), thumbnail: images[idx%4])
            
        }
    }
    
}

/**
 NSAttributedString factory methods
 */
extension TweetModel {
    
    var _attributedName: NSAttributedString {
        let n = Style("n").font(.boldSystemFont(ofSize: 16)).foregroundColor(.black)
        let u = Style("u").font(.systemFont(ofSize: 14)).foregroundColor(TweetModel.darkGreyColor)
        return "<n>\(name)</n> <u>\(username)</u>".style(tags: n, u).attributedString
    }
    
    var _attributedTweet: NSAttributedString {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.2
        
        let s = Style.font(.systemFont(ofSize: 14)).foregroundColor(.black).paragraphStyle(paragraphStyle)
        let h = Style.foregroundColor(.blue)
        return tweet.styleAll(s).styleHashtags(h).attributedString
    }
    
    var _attributedDate: NSAttributedString {
        let s = Style.font(.systemFont(ofSize: 15)).foregroundColor(TweetModel.darkGreyColor)
        return displayableDate.styleAll(s).attributedString
    }
    
    static let darkGreyColor = UIColor(red: 140.0/255.0, green: 157.0/255.0, blue: 170.0/255.0, alpha: 1.0)
    static let lightBlueColor = UIColor(red: 33.0/255.0, green: 151.0/255.0, blue: 225.0/255.0, alpha: 1.0)    
}


extension Array {
    func parallelMap<R>(striding n: Int, filler: R, f: @escaping (Element) -> R, completion: @escaping ([R]) -> ()) {
        let N = self.count
        
        var finalResult = Array<R>(repeating: filler, count: N)
        
        finalResult.withUnsafeMutableBufferPointer { res in
            DispatchQueue.concurrentPerform(iterations: N/n) { k in
                for i in (k * n)..<((k + 1) * n) {
                    res[i] = f(self[i])
                }
            }
        }
        
        for i in (N - (N % n))..<N {
            finalResult[i] = f(self[i])
        }
        
        DispatchQueue.main.async {
            completion(finalResult)
        }
    }
}
