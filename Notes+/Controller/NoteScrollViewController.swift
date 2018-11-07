//
//  NoteScrollViewController.swift
//  Notes+
//
//  Created by Hector Mendoza on 9/6/18.
//  Copyright © 2018 Hector Mendoza. All rights reserved.
//

import UIKit
import CoreData

class NoteScrollViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var scrollTextView: UITextView!
    @IBOutlet weak var noteNavigationBar: UINavigationItem!
    
    var notesArray = [Notes]()
    var arrayIndex: Int? {
        didSet {
            loadNotes()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var keyboardHeight: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(NoteScrollViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NoteScrollViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        noteNavigationBar.title = notesArray[arrayIndex!].noteTitle
        
        scrollTextView.delegate = self
        scrollTextView.text = notesArray[arrayIndex!].noteText
    }
    
    
    //MARK: - Text Did Change + Done Button
    func textViewDidChange(_ textView: UITextView) {
        saveNotes()
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        scrollTextView.endEditing(true)
        saveNotes()
    }
    
    
    //MARK: - Data Manipulation Methods
    func saveNotes() {
        notesArray[arrayIndex!].noteText = scrollTextView.text
        
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    func loadNotes(with request: NSFetchRequest<Notes> = Notes.fetchRequest()) {
        do {
            notesArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context: \(error)")
        }
        
        view.reloadInputViews()
    }
    
    //MARK: - Keyboard Control Methods
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}

        guard let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue else {return}
        
        let keyboardFrame = keyboardSize.cgRectValue
        keyboardHeight = keyboardFrame.height
        
        view.frame.size.height -= keyboardHeight
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        view.frame.size.height += keyboardHeight
    }
}
