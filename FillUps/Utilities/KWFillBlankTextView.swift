//
//  KWFillBlankTextView.swift
//  KWFillBlankTextView
//
//  Created by 一折 on 16/7/30.
//  Copyright © 2016年 yizhe. All rights reserved.
//


import UIKit

public protocol KWFillBlankDelegate {
    func fillBlankView(fillBlankView:UIView, didSelectedBlankRange range:NSRange)->Void
}

class KWFillBlankTextView: UITextView {
    /**
     The blank character in the text, the default value is "_".
     
     It's no use to change this property after the initialize.
     */
    @IBInspectable var blankTag:String = "_"
    /**
     The text to display on the view.
     */
    private var contentText:NSMutableAttributedString!
    
    private var originFontSize:CGFloat = 22.0
    
    private var blankDic = NSMutableDictionary()
    private var blankArr = NSMutableArray()
    var selectedBlank:Int = 0
    
    /**
     Creates a KWFillBlankTextView with the specified blank tag and content string.
     
     An initialized KWFillBlankTextView.
     
     - parameter frame: The frame rectangle of the KWFillBlankTextView.
     - parameter contentText: The text to display on the view, the defualt value is "".
     - parameter blankTag: The blank character in the text, the defualt value is '_'.

     - returns: An initialized text view.
     */
    init(contentText:String,frame:CGRect,blankTag:String="_"){
        super.init(frame:frame,textContainer:nil)
        self.text = contentText
        self.blankTag = blankTag
        self.contentText = NSMutableAttributedString(string: self.text)
        setDefaultProperty()
        setBlank()
    }
    
    convenience init(contentText:String,frame:CGRect){
        self.init(contentText:contentText,frame:frame,blankTag: "_")
    }
    
    override func awakeFromNib() {
        self.contentText = NSMutableAttributedString(string: self.text)
        setDefaultProperty()
        setBlank()
        if !self.text.isEmpty {
            self.originFontSize = self.font!.pointSize
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func setDefaultProperty(){
        self.isEditable = false
        self.isSelectable = true
    }
    
    private func setBlank() {
        let textRange = NSMakeRange(0, self.contentText.length)
        let pattern = "\(blankTag)+"
        let expression = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options())
        let arr = expression.matches(in: self.text, options: .reportProgress, range: textRange)
        for res in arr {
            let range = res.range
            self.blankArr.add(range)
            self.blankDic["\(range.location)"] = self.blankArr.count-1
            contentText.addAttribute(NSAttributedString.Key.link, value: "blank", range: range)
            contentText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.blue, range: range)
        }
        contentText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: self.originFontSize), range: textRange)
        self.attributedText = contentText
    }
    
    func updateRange(range:NSRange){
        self.selectedBlank = self.blankDic["\(range.location)"] as! Int
    }
    
    func changeText(text: String, inRange range: NSRange) {
        updateRange(range: range)
        self.contentText.replaceCharacters(in: range, with: text)
        let newRange = NSMakeRange(range.location, text.count)
        self.contentText.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: newRange)
        self.attributedText = self.contentText
        updateBlanks()
    }
    
    func setText(_ text: String, blankTag: String = "_") {
        self.text = text
        self.blankTag = blankTag
        self.contentText = NSMutableAttributedString(string: self.text)
        self.setDefaultProperty()
        self.setBlank()
    }
    
    func updateBlanks() {
        self.blankDic.removeAllObjects()
        self.blankArr.removeAllObjects()
        self.contentText.enumerateAttribute(NSAttributedString.Key.link, in: NSMakeRange(0, self.contentText.length), options: .longestEffectiveRangeNotRequired, using: {
            value, range, stop in
            if value != nil && value as! String == "blank"{
                self.blankArr.add(range)
                self.blankDic["\(range.location)"] = self.blankArr.count-1
            }
        })
    }
    
    func highlightTextInRange(range:NSRange) {
        self.contentText.removeAttribute(NSAttributedString.Key.backgroundColor, range: NSMakeRange(0, self.contentText.length))
        self.contentText.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.groupTableViewBackground, range: range)
        self.attributedText = self.contentText
    }
    
    func contentTexts() -> [String]{
        var arr:[String] = []
        self.contentText.enumerateAttribute(NSAttributedString.Key.link, in: NSMakeRange(0, self.contentText.length), options: .longestEffectiveRangeNotRequired, using: {
            value, range, stop in
            if value != nil && value as! String == "blank"{
                var str = self.contentText.attributedSubstring(from: range).string
                if str.hasPrefix(self.blankTag){
                    str = ""
                }
                arr.append(str)
            }
        })
        return arr
    }
    
    func selectedBlankRange() -> NSRange {
        if self.blankArr.count > 0 {
            return self.blankArr[(selectedBlank+1)%self.blankArr.count] as! NSRange
        }
        return NSMakeRange(0, 0)
    }
    
    func selectedText() -> String{
        let range = self.blankArr[selectedBlank] as! NSRange
        var str = self.contentText.attributedSubstring(from: range).string
        if str.hasPrefix(self.blankTag) {
            str = ""
        }
        return str
    }
    
    func nextText() -> String{
        let range = self.blankArr[(selectedBlank+1)%self.blankArr.count] as! NSRange
        var str = self.contentText.attributedSubstring(from: range).string
        if str.hasPrefix(self.blankTag) {
            str = ""
        }
        return str
    }
    
}


