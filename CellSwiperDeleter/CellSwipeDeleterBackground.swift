//
//  CellSwipeDeleterBackground.swift
//  Purchase App
//
//  Created by Mudith Chathuranga on 7/3/18.
//  Copyright © 2018 Chathuranga. All rights reserved.
//

import UIKit

public class CellSwipeDeleterBackground: UIView {
    
    @IBOutlet weak var deleteImage: UIImageView!
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        let podBundle = Bundle(for: CellSwipeDeleterBackground.self)
        self.deleteImage.image = UIImage(named: "cellSwiperDelete", in: podBundle, compatibleWith: nil)
    }
    
    public class func getBackgroundEditView() -> CellSwipeDeleterBackground {
        let cellNib = UINib(nibName: "CellSwipeDeleterBackground", bundle: Bundle(for: CellSwipeDeleterBackground.self))
        return cellNib.instantiate(withOwner: nil, options: nil)[0] as! CellSwipeDeleterBackground
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
