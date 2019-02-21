//
//  Created by Pavel Sharanda on 19.10.16.
//  Copyright © 2016 Pavel Sharanda. All rights reserved.
//

// Sample was borrowed from EasyPeasy https://github.com/nakiostudio/EasyPeasy/blob/master/Example/EasyPeasy/TweetView.swift


import UIKit
import LayoutOps

class LayoutOpsViewController: UIViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
        title = "LayoutOps"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(), style: .grouped)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        return tableView
    }()
    
    fileprivate var tweets: [TweetModel] = TweetModel.stubData()
    fileprivate var presentationCache: [(TweetModel, RootNode)]?
    
    private var referenceWidth: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
    }
    
    private var cancelCaching: (()->Void)?
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let width = view.frame.width
        
        if width != referenceWidth {
            
            cancelCaching?()
            
            presentationCache = nil
            referenceWidth = width
            
            let dateStart = Date()
            let models = tweets
            
            var cancelled = false
            
            cancelCaching = {
                cancelled = true
            }
            
            DispatchQueue.global(qos: .background).async {
                let cachedModels: [(TweetModel, RootNode)] = models.concurrentMap  {
                    let node = LOTweetCell.buildRootNode($0, estimated: false)
                    _ = node.calculate(for: CGSize(width: width, height: 0))
                    return ($0, node)
                }
                
                DispatchQueue.main.async { [weak self] in
                    if !cancelled {
                        print("did cache in \(Date().timeIntervalSince(dateStart))s")
                        self?.presentationCache = cachedModels
                    }
                }
            }
        }
        
        tableView.lx.fill()
    }
    
    fileprivate lazy var adapter: TableViewPresentationAdapter = { [unowned self] in
        return TableViewPresentationAdapter(presentationItemForRow: { indexPath, estimated in
            if let node = self.presentationCache?[indexPath.row]  {
                return NodeTableRow(model: node.1)
            } else {
                return NodeTableRow(model: LOTweetCell.buildRootNode(self.tweets[indexPath.row], estimated: estimated))
            }
        })
    }()
}

extension LayoutOpsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //rows
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return adapter.tableView(tableView, cellForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return adapter.tableView(tableView, estimatedHeightForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return adapter.tableView(tableView, heightForRowAt: indexPath)
    }
    
    //footers
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return adapter.tableView(tableView, viewForFooterInSection: section)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return adapter.tableView(tableView, estimatedHeightForFooterInSection: section)
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return adapter.tableView(tableView, heightForFooterInSection: section)
    }
    
    //headers
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return adapter.tableView(tableView, viewForHeaderInSection: section)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return adapter.tableView(tableView, estimatedHeightForHeaderInSection: section)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return adapter.tableView(tableView, heightForHeaderInSection: section)
    }
}

class LOTweetCell: NodeTableViewCell {
    
    enum Tags: String, TagConvertible {
        case user
        case tweet
        case avatar
        case timestamp
    }
    
    static func buildRootNode(_ model: TweetModel, estimated: Bool) -> RootNode {
    
        if estimated {
            return RootNode(height: 50)
        }
        
        //setup hierarchy
        let avatarNode = ImageNode(tag: Tags.avatar, image: model.thumbnail) {
            let imageView = $0 ?? UIImageView()
            imageView.backgroundColor = UIColor.lightGray
            imageView.layer.masksToBounds = true
            imageView.layer.cornerRadius = 6.0
            return imageView
        }
        
        let userNode = LabelNode(tag: Tags.user, text: .attributed(model.attributedName)) {
            return $0 ?? UILabel()
        }
        
        let tweetNode = LabelNode(tag: Tags.tweet, text: .attributed(model.attributedTweet), numberOfLines: 0) {
            return $0 ?? UILabel()
        }
        
        let timeStampNode = LabelNode(tag: Tags.timestamp, text: .attributed(model.attributedDate)) {
            return $0 ?? UILabel()
        }
        
        let rootNode = RootNode(subnodes: [avatarNode, userNode, tweetNode, timeStampNode]) { rootNode in
            
            let pad: CGFloat = 12
            
            //layout
            avatarNode.lx.set(x: pad, y: pad, width: 52, height: 52)
            
            timeStampNode.lx.sizeToFitMax(widthConstraint: .max(40))
            
            rootNode.lx.inViewport(leftAnchor: avatarNode.lx.rightAnchor) {
                rootNode.lx.hput(
                    Fix(pad),
                    Flex(userNode),
                    Fix(pad),
                    Fix(timeStampNode),
                    Fix(pad)
                )
                
                rootNode.lx.hput(
                    Fix(pad),
                    Flex(tweetNode),
                    Fix(pad)
                )
            }
            
            userNode.lx.setHeightAsLineHeight()
            
            tweetNode.lx.sizeToFit(width: .keepCurrent, height: .max, heightConstraint: .min(20))
            
            rootNode.lx.vput(
                Fix(pad),
                Fix(userNode),
                Fix(tweetNode)
            )
            
            if rootNode.frame.size.height > 10 { // in editing mode...
                let newTweetHeight = (rootNode.frame.height - pad - tweetNode.frame.minY)
                tweetNode.lx.set(height: newTweetHeight)
            }
            
            timeStampNode.lx.firstBaselineAnchor.follow(userNode.lx.firstBaselineAnchor)
            
            //calculate final cell height
            rootNode.frame.size.height = max(tweetNode.frame.maxY + pad, avatarNode.frame.maxY + pad)
        }
        
        return rootNode
    }
}

extension RandomAccessCollection {
    func concurrentMap<T>(_ transform: (Iterator.Element)->T) -> [T] {
        let n = numericCast(self.count) as Int
        let p = UnsafeMutablePointer<T>.allocate(capacity: n)
        defer { p.deallocate() }
        
        DispatchQueue.concurrentPerform(iterations: n) {
            offset in
            (p + offset).initialize(to: transform(self[index(startIndex, offsetBy: numericCast(offset))]))
        }
        
        return Array(UnsafeMutableBufferPointer(start: p, count: n))
    }
}
