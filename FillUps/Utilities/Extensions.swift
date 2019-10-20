//
//  Extensions.swift
//  FillUps
//
//  Created by Keshav Bansal on 20/10/19.
//  Copyright © 2019 kb. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    func getSentences() -> [String] {
        let sentences = self.components(separatedBy: ". ")
        return sentences
    }
    
    func getRandomWord(excludingWords excludeWords: [String]) -> String? {
        let words = Set(self.components(separatedBy: " "))
        let newWords = words.subtracting(Set(excludeWords))
        let random = newWords.randomElement()
        return random
    }
    
    func replacingFirstOccurrence(of target: String, withString replaceString: String) -> String {
        if let range = self.range(of: target) {
            return self.replacingCharacters(in: range, with: replaceString)
        }
        return self
    }
}

extension Notification {
    
    var keyboardHeightDelta: CGFloat {
        if let userInfo = self.userInfo {
            if let beginFrame = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect,
                let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                let homeBarHeight = Utilities.getHomeBarHeight()
                let delta: CGFloat = endFrame.origin.y - beginFrame.origin.y
                if delta > 0 {
                    return delta - homeBarHeight
                } else if delta < 0 {
                    return delta + homeBarHeight
                }
            }
        }
        return 0.0
    }
    
    var keyboardHeightInSafeArea: CGFloat {
        if let userInfo = self.userInfo {
            if let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                let height = UIScreen.main.bounds.height - endFrame.origin.y
                if height > 0 {
                    return height - Utilities.getHomeBarHeight()
                } else {
                    return 0
                }
            }
        }
        return 0.0
    }
    
    var keyboardAnimationDuration: TimeInterval {
        if let duration = self.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {
            return duration
        }
        return 0
    }
    
    var keyboardAnimationOptions: UIView.AnimationOptions {
        if let curveInfo = self.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int {
            if let curve = UIView.AnimationCurve(rawValue: curveInfo) {
                let options = UIView.AnimationOptions(rawValue: UInt(curve.rawValue << 16))
                return options
            }
        }
        return []
    }
    
}
