//
//  ViewController.swift
//  LayoutBattle
//
//  Created by Pavel Sharanda on 25.02.17.
//  Copyright © 2017 psharanda. All rights reserved.
//

import UIKit
import EasyPeasy


class AutoLayoutViewController: UIViewController {
    
    fileprivate lazy var tableView = UITableView(frame: CGRect(), style: .plain)
    
    let models = TweetModel.stubData()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        title = "Autolayout"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
        view.addSubview(tableView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        
    }
}

extension AutoLayoutViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellId = "CellId"
        
        let model = models[indexPath.row]
        let cell = (tableView.dequeueReusableCell(withIdentifier: cellId) as? ALTweetCell) ?? ALTweetCell(style: .default, reuseIdentifier: cellId)
        cell.configureWithModel(model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

class ALTweetCell: UITableViewCell {
    
    fileprivate lazy var userInfoLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        return label
    }()
    
    fileprivate lazy var displayableDateLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        return label
    }()
    
    fileprivate lazy var thumbnailImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect.zero)
        imageView.backgroundColor = UIColor.lightGray
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 6.0
        return imageView
    }()
    
    fileprivate lazy var tweetLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 100), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .vertical)
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
        layout()
    }
    
    // MARK: Public methods
    
    func configureWithModel(_ tweetModel: TweetModel) {
        thumbnailImageView.image = tweetModel.thumbnail
        
        userInfoLabel.attributedText = tweetModel.attributedName
        displayableDateLabel.attributedText = tweetModel.attributedDate
        tweetLabel.attributedText = tweetModel.attributedTweet
    }
    
    // MARK: Private methods
    
    fileprivate func setup() {
        backgroundColor = UIColor.white
        
        addSubview(thumbnailImageView)
        addSubview(displayableDateLabel)
        addSubview(userInfoLabel)
        addSubview(tweetLabel)
    }
    
}

/**
 Autolayout constraints
 */
extension ALTweetCell {
    
    fileprivate func layout() {
        // Thumbnail imageview
        thumbnailImageView.easy.layout([
            Size(52),
            Top(12),
            Left(12)
        ])
        
        // Displayable date label
        displayableDateLabel.easy.layout([
            Width(<=40),
            Top().to(thumbnailImageView, .top),
            Right(12)
        ])
        
        // UserInfo label
        userInfoLabel.easy.layout([
            Height(20),
            Top().to(thumbnailImageView, .top),
            Left(10).to(thumbnailImageView),
            Right(10).to(displayableDateLabel)
        ])
        
        // Tweet label
        tweetLabel.easy.layout([
            Height(>=20),
            Top(0).to(userInfoLabel),
            Bottom(12),
            Left().to(userInfoLabel, .left),
            Right(12)
        ])
    }
    
}
