//
//  Created by Pavel Sharanda on 23.11.16.
//  Copyright © 2016 Pavel Sharanda. All rights reserved.
//

import Foundation
#if os(macOS)
    import Cocoa
#else
    import UIKit
#endif

public protocol TagConvertible {
    var tag: String {get}
}

extension TagConvertible where Self: RawRepresentable, Self.RawValue == String {
    public var tag: String {
        return rawValue
    }
}

extension String: TagConvertible {
    public var tag: String {
        return self
    }
}

public protocol NodeProtocol: SelfSizingLayoutable {
    var lx_parent: Layoutable? {get set}
    func install(in container: NodeContainer)
    func prepareForReuse(in container: NodeContainer)
}

public protocol NodeContainer: Layoutable {
    var lx_tag: String? {get set}
    func lx_add(child: NodeContainer)
    func lx_child(with tag: String) -> NodeContainer?
}

open class Node<T: NodeContainer>: NodeProtocol {
    
    //MARK: - confirm layoutable
    
    public var lx_frame: CGRect {
        get {
            return frame
        }
        set {
            frame = newValue
        }
    }
    
    public var lx_viewport: CGRect?
    
    public weak var lx_parent: Layoutable?
    
    //MARK: - in fact shorthands to be similar to UIView etc
    public var bounds: CGRect {
        return CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
    }
    
    public var frame = CGRect()
    
    
    open func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize()
    }
    
    //MARK: - state
    public var subnodes: [NodeProtocol]
    private let initializer: ((T?)->T)
    private let prepareForReuse: ((T)->Void)
    public let tag: TagConvertible
    
    public init(tag: TagConvertible, subnodes: [NodeProtocol] = [], prepareForReuse: @escaping ((T)->Void) = {_ in }, initializer: @escaping (T?)->T) {
        self.tag = tag
        self.initializer = initializer
        self.subnodes = subnodes
        self.prepareForReuse = prepareForReuse
        
        subnodes.forEach {
            $0.lx_parent = self
        }
    }
    
    public func install(in container: NodeContainer) {
        let viewWithTag = container.lx_child(with: tag.tag)
        
        let nodeView = initializer(viewWithTag.flatMap { $0 as? T } )
        nodeView.lx_tag = tag.tag
        
        if nodeView.lx_parent == nil {
            container.lx_add(child: nodeView)
        }
        nodeView.lx_frame = frame
        
        subnodes.forEach {
            $0.install(in: nodeView)
        }
    }
    
    public func prepareForReuse(in container: NodeContainer) {
        if let v = container.lx_child(with: tag.tag), let viewWithTag = v as? T  {
            prepareForReuse(viewWithTag)
            
            subnodes.forEach {
                $0.prepareForReuse(in: viewWithTag)
            }
        }
    }
}

extension Node: LayoutingCompatible { }

