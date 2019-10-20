//
//  ViewController.swift
//  FillUps
//
//  Created by Keshav Bansal on 08/10/19.
//  Copyright © 2019 kb. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textView: KWFillBlankTextView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var replayButton: UIButton!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!

    var wordPicker: UIPickerView = UIPickerView()

    var dataGenerator = DataGenerator()
    
    // words picked by user on the basis of index of blanks
    var pickedWords = [Int: String]()
    var pickerItems = [String]()
    
    private var selectedRange: NSRange?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.getData()
        self.configurePicker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.adjustForKeyboard(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: NotificationCenter handlers
    @objc func adjustForKeyboard(notification: Notification) {
        self.bottomConstraint.constant = notification.keyboardHeightInSafeArea + 16
        UIView.animate(withDuration: notification.keyboardAnimationDuration, delay: 0, options: notification.keyboardAnimationOptions, animations: {() -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func configurePicker() {
        self.wordPicker = UIPickerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100))
        self.wordPicker.translatesAutoresizingMaskIntoConstraints = false
        self.wordPicker.delegate = self
        self.wordPicker.dataSource = self
        let toolBarframe = CGRect(x: 0, y: self.wordPicker.frame.origin.y - 24, width: self.view.frame.width, height: 100)
        let pickerToolBar = self.getToolbar(frame: toolBarframe)
        
        self.textView.inputView = self.wordPicker
        self.textView.inputAccessoryView = pickerToolBar
        
        self.wordPicker.reloadAllComponents()
    }
    
    func getToolbar(frame: CGRect) -> UIToolbar {
        let pickerToolBar = UIToolbar()
        pickerToolBar.frame = CGRect(x: 0, y: self.wordPicker.frame.origin.y - 24, width: self.view.frame.width, height: 100)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let setButton = UIBarButtonItem(title: "Select", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.setBlankValue))
        pickerToolBar.barStyle = UIBarStyle.default
        pickerToolBar.isTranslucent = true
        pickerToolBar.tintColor = UIColor.black
        pickerToolBar.sizeToFit()
        pickerToolBar.setItems([spaceButton, spaceButton, setButton], animated: true)
        pickerToolBar.isUserInteractionEnabled = true
        return pickerToolBar
    }
    
    func getData() {
        self.setLoading(true)
        self.dataGenerator.getRandomWikiText(completion: { (extract) in
            DispatchQueue.main.async {
                self.setLoading(false)
                self.textView.setText(extract, blankTag: "_______")
                self.pickerItems = self.dataGenerator.shuffledWords
                self.wordPicker.reloadAllComponents()
            }
        }) { (error) in
            
        }
    }
    
    @IBAction func replay() {
        self.pickedWords = [Int: String]()
        self.pickerItems = [String]()
        self.wordPicker.reloadAllComponents()
        self.getData()
    }
    
    @IBAction func hideKeyboard() {
        self.textView.resignFirstResponder()
    }
    
    @IBAction func submitPressed() {
        let score = self.dataGenerator.getFinalScore(forAnswers: self.pickedWords)
        let alertController = UIAlertController(title: "You got \(score)/10", message: "", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Got it!", style: .cancel) { _ in
        })
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func setBlankValue() {
        let row = self.wordPicker.selectedRow(inComponent: 0)
        if row < self.pickerItems.count, let range = self.selectedRange {
            let pickedWord = self.pickerItems[row]
            self.textView.changeText(text: pickedWord, inRange: range)
            self.pickedWords[self.textView.selectedBlank] = pickedWord
            self.hideKeyboard()
        }
    }

    func setLoading(_ loading: Bool) {
        self.loadingView.isHidden = !loading
        self.replayButton.isEnabled = !loading
    }
    
}

extension ViewController: UITextViewDelegate, UITextFieldDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if URL.absoluteString == "blank" {
            self.selectedRange = characterRange
            self.textView.becomeFirstResponder()
            self.textView.highlightTextInRange(range: characterRange)
            self.textView.updateRange(range: characterRange)
            return false
        }
        return true
    }
    
}

// MARK: UIPickerView Delegates
extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerItems.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row < self.pickerItems.count {
            return self.pickerItems[row]
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
}
