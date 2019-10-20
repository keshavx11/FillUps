//
//  Utilities.swift
//  FillUps
//
//  Created by Keshav Bansal on 20/10/19.
//  Copyright © 2019 kb. All rights reserved.
//

import Foundation
import UIKit

class Utilities {
    
    class func getHomeBarHeight() -> CGFloat {
        if #available(iOS 11.0, *) {
            if let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom {
                return bottomPadding
            }
        }
        return 0.0
    }
}
