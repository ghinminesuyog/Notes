//
//  NewNoteScreen.swift
//  Notes
//
//  Created by Suyog Ghinmine on 11/10/19.
//  Copyright © 2019 Suyog Ghinmine. All rights reserved.
//

import UIKit
import CoreData

class NewNoteScreen: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var textTextView: UITextView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Dismiss keyboard on touch elsewhere:
        let tapToDismissKeyboard = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tapToDismissKeyboard)
        

        dateLabel.text = displayDateInMyFormat(theDate: Date())
        textTextView.text = ""
        titleTextField.placeholder = "Enter title"

        self.view.backgroundColor = UIColor(red: 240/255, green: 241/255, blue: 241/255, alpha: 1)

        textTextView.layer.borderWidth = 0.5
        textTextView.layer.borderColor = UIColor.lightGray.cgColor
        textTextView.layer.cornerRadius = 8
        
        let rightBarButtonForSave = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(savebutton))
        self.navigationItem.rightBarButtonItem = rightBarButtonForSave
        
    }
    
    
    @objc func savebutton(){
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
            let managedObjectContext = appdelegate.persistentContainer.viewContext
            
            guard let titleOfTheNote = titleTextField.text else{
                return
            }
            guard let textOfTheNote = textTextView.text else{
                return
            }
            let timeStampOfTheNote = Date()
            
            
            //Save new note:

            let noteToBeCreated = NotesDataClass(titleOfTheNote: titleOfTheNote, textOfTheNote: textOfTheNote, timeStampOfTheNote: timeStampOfTheNote)
            
            let newNoteToBeCreated = NSEntityDescription.insertNewObject(forEntityName: "Note", into: managedObjectContext)
           
            newNoteToBeCreated.setValue(noteToBeCreated.noteTitle, forKey: "noteTitle")
            newNoteToBeCreated.setValue(noteToBeCreated.noteText, forKey: "noteText")
            newNoteToBeCreated.setValue(noteToBeCreated.noteTimeStamp, forKey: "noteTimeStamp")
            newNoteToBeCreated.setValue(noteToBeCreated.noteId, forKey: "noteId")
            
            do
            {
                try managedObjectContext.save()
            }
            catch
            {
                print("Failed to insert record")
        }
            
            //Save to db
            self.navigationController?.popToRootViewController(animated: true)
        
    }
    
    func displayDateInMyFormat(theDate:Date) -> String{
        //The formatter:
        let formatter = DateFormatter()
        //The date format required:
        formatter.dateFormat = "EEE, dd-MMM-yyyy hh:mm a"
        //The string from given date in above format:
        let dateString = formatter.string(from: theDate)
        //Return it:
        return(dateString)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
