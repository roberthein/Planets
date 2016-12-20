//
//  HUD.swift
//  Planets!
//
//  Created by Robert-Hein Hooijmans on 20/12/16.
//  Copyright © 2016 Robert-Hein Hooijmans. All rights reserved.
//

import Foundation
import UIKit

class HUD: UIView {
    
    var loader: Loader!
    var title: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        loader = Loader()
        loader.translatesAutoresizingMaskIntoConstraints = false
        addSubview(loader)
        
        loader.top(to: self, offset: 5)
        loader.left(to: self, offset: 5)
        loader.right(to: self, offset: -5)
        loader.height(Loader.height)
        
        title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = UIFont.systemFont(ofSize: 40, weight: -0.5)
        title.textAlignment = .center
        title.numberOfLines = 0
        title.textColor = UIColor.white.withAlphaComponent(0.8)
        addSubview(title)
        
        title.top(to: self)
        title.left(to: self)
        title.right(to: self)
        title.height(200)
    }
}
