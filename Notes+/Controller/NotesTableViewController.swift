//
//  NotesTableViewController.swift
//  Notes+
//
//  Created by Hector Mendoza on 9/4/18.
//  Copyright © 2018 Hector Mendoza. All rights reserved.
//

import UIKit
import CoreData

class NotesTableViewController: UITableViewController {
    var notesArray = [Notes]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        loadNotes()
        setupLongPressGesture()
        
        tableView.register(UINib(nibName: "NoteCell", bundle: nil), forCellReuseIdentifier: "customNoteCell")
        
        configureTableView()
    }
    

    // MARK: - TableView Data Source
    func configureTableView() {
        tableView.rowHeight = 190.0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notesArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customNoteCell", for: indexPath) as! CustomNoteCell
        
        let item = notesArray[indexPath.row]
        
        cell.titleLabel.text = item.noteTitle
        cell.descriptionLabel.text = item.noteDescription
        
        if item.noteImage != nil {
            cell.noteImage.image = UIImage(data: item.noteImage!)
        }
        
        return cell
    }
    
    
    //MARK: - TableView Delegate Method
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //deleteNotes(indexPath)
        performSegue(withIdentifier: "goToNoteScrollView", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! NoteScrollViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.arrayIndex = indexPath.row
        }
    }

    
    //MARK: - Add New Notes
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            } else {
                print("Camera not available")
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func addNoteAlert(_ imageData: Data) {
        var titleTextField = UITextField()
        var descriptionTextField = UITextField()
        
        let alert = UIAlertController(title: "Add New Note", message: "Please add a place and a description of your note", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            if titleTextField.text!.isEmpty || descriptionTextField.text!.isEmpty {
                //do nothing
            } else {
                let newNote = Notes(context: self.context)
                newNote.noteTitle = titleTextField.text!
                newNote.noteDescription = descriptionTextField.text!
                newNote.noteImage = imageData
        
                self.notesArray.append(newNote)
        
                self.saveNotes()
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Place"
            print("isEditing: \(alertTextField.isEditing)")
            titleTextField = alertTextField
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Description"
            descriptionTextField = alertTextField
        }
        
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Data Manipulation Methods
    func saveNotes() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadNotes(with request: NSFetchRequest<Notes> = Notes.fetchRequest()) {
        do {
            notesArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context: \(error)")
        }
        
        tableView.reloadData()
    }
    
    func updateNotes(indexPath: IndexPath) {
        var titleTextField = UITextField()
        var descriptionTextField = UITextField()
        
        let alert = UIAlertController(title: "Edit Note", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Edit", style: .default) { (action) in
            if titleTextField.text!.isEmpty || descriptionTextField.text!.isEmpty {
                //do nothing
            } else {
                self.notesArray[indexPath.row].noteTitle = titleTextField.text
                self.notesArray[indexPath.row].noteDescription = descriptionTextField.text
                
                self.saveNotes()
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Place"
            alertTextField.text = self.notesArray[indexPath.row].noteTitle
            titleTextField = alertTextField
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Description"
            alertTextField.text = self.notesArray[indexPath.row].noteDescription
            descriptionTextField = alertTextField
        }
        
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func deleteNotes(_ indexPath: IndexPath) {
        context.delete(notesArray[indexPath.row])
        notesArray.remove(at: indexPath.row)
        
        saveNotes()
    }
}




//MARK: - Long Press Methods
extension NotesTableViewController: UIGestureRecognizerDelegate {
    func setupLongPressGesture() {
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        longPressGesture.minimumPressDuration = 0.8 //second press
        longPressGesture.delegate = self
        self.tableView.addGestureRecognizer(longPressGesture)
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                updateNotes(indexPath: indexPath)
            }
        }
    }
}




//MARK: Image Picker Controller Delegate
extension NotesTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        let imageData = image.jpegData(compressionQuality: 0.05)
        
        picker.dismiss(animated: true, completion: nil)
        
        addNoteAlert(imageData!)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
