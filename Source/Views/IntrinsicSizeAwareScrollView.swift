//
//  IntrinsicSizeAwareScrollView.swift
//  Matrioska
//
//  Created by Alex Manzella on 15/11/16.
//  Copyright © 2016 runtastic. All rights reserved.
//

import Foundation
import UIKit

/// A `UIScrollView` subclass that adapts its `intrinsicContentSize` to its `contentSize`
final class IntrinsicSizeAwareScrollView: UIScrollView {
    
    private let keyPath = #keyPath(UIScrollView.contentSize)
    private var kvoContext = UInt8()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addContentSizeObserver()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addContentSizeObserver()
    }
    
    deinit {
        removeObserver(self, forKeyPath: keyPath)
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        
        if &kvoContext == context,
            let new = change?[.newKey] as? NSValue,
            let old = change?[.oldKey] as? NSValue,
            new.cgSizeValue != old.cgSizeValue {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return contentSize
    }
    
    private func addContentSizeObserver() {
        addObserver(self, forKeyPath: keyPath, options: [.new, .old], context: &kvoContext)
    }
}
