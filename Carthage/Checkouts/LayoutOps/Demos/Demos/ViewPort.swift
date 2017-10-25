//
//  Created by Pavel Sharanda on 19.10.16.
//  Copyright © 2016 Pavel Sharanda. All rights reserved.
//


import UIKit
import LayoutOps

class ViewPortDemo: UIView, DemoViewProtocol {
    
    let blueView = makeBlueView()
    let greenView = makeGreenView()
    let redView = makeRedView()
    let heartView = makeHeartView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(blueView)
        addSubview(greenView)
        addSubview(redView)
        addSubview(heartView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        blueView.lx.hfill(inset: 20)
        
        self.lx.vput(
            Fix(20),
            Fix(blueView, 20),
            Fix(20),
            Flex(greenView),
            Fix(20)
        )
        
        greenView.lx.alignLeft(20)
            .set(width: 20)
        
        self.lx.inViewport(topAnchor: blueView.lx.bottomAnchor.insettedBy(5), leftAnchor: greenView.lx.rightAnchor.insettedBy(5), bottomAnchor: self.lx.bottomAnchor.insettedBy(-5), rightAnchor: self.lx.rightAnchor.insettedBy(-5)) {
            redView.lx.fill()
            heartView.lx.bottomAnchor.follow(self.lx.bottomAnchor)
            heartView.lx.rightAnchor.follow(self.lx.rightAnchor)
        }
    }
    
    static let title = "Demo"
    static let comments = "Viewport can be defined using anchors of any childview, or nil anchor if using superview edges"
}
