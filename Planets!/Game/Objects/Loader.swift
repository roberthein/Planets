//
//  Loader.swift
//  Planets!
//
//  Created by Robert-Hein Hooijmans on 08/12/16.
//  Copyright © 2016 Robert-Hein Hooijmans. All rights reserved.
//

import Foundation
import UIKit

class Loader: UIView {
    
    var bar: UIView!
    var progress: TextureProgress!
    static let height: CGFloat = 4
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        bar = UIView()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.backgroundColor = .white
        bar.clipsToBounds = true
        bar.layer.cornerRadius = 3
        addSubview(bar)
        
        bar.top(to: self)
        bar.left(to: self)
        bar.width(0)
        bar.height(Loader.height)
        
        progress = { percentage in
            self.set(CGFloat(percentage), animated: true)
        }
    }
    
    private func set(_ percentage: CGFloat, animated: Bool) {
        bar.width(percentage * bounds.width)
        
        if animated {
            let options: UIViewAnimationOptions = [.curveEaseOut, .beginFromCurrentState, .allowUserInteraction]
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: options, animations: {
                self.layoutIfNeeded()
            }) { success in
                if percentage >= 1.0 {
                    self.set(0, animated: false)
                }
            }
        } else {
            layoutIfNeeded()
        }
    }
}
