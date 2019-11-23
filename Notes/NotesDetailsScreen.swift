//
//  NotesDetailsScreen.swift
//  Notes
//
//  Created by Suyog Ghinmine on 09/10/19.
//  Copyright © 2019 Suyog Ghinmine. All rights reserved.
//

import UIKit
import CoreData

class NotesDetailsScreen: UIViewController, UITextFieldDelegate {
    
    //Variables and constant:
    var noteToBeEdited : NotesDataClass?

    //Outlets:
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var noteTitleTextField: UITextField!
    
    @IBOutlet weak var noteTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        Tap gesture to dismiss keyboard when clicked elsewhere:
        let tapToDismissKeyboard = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        self.view.addGestureRecognizer(tapToDismissKeyboard)
        
        dateLabel.text = displayDateInMyFormat(theDate:(noteToBeEdited?.noteTimeStamp)!)
        noteTitleTextField.text = noteToBeEdited?.noteTitle
        noteTextView.text = noteToBeEdited?.noteText
        
        self.view.backgroundColor = UIColor(red: 240/255, green: 241/255, blue: 241/255, alpha: 1)
        
        noteTextView.layer.borderWidth = 0.5
        noteTextView.layer.borderColor = UIColor.lightGray.cgColor
        noteTextView.layer.cornerRadius = 8
        
        let leftBarButtonForCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelNote))
        self.navigationItem.leftBarButtonItem = leftBarButtonForCancel
        
        let rightBarButtonForSave = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveNote))
        
        self.navigationItem.rightBarButtonItem = rightBarButtonForSave
        
    }
    
    @objc func saveNote(){
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObjectContext = appdelegate.persistentContainer.viewContext
        
        guard let titleOfTheNote = noteTitleTextField.text else{
            return
        }
        guard let textOfTheNote = noteTextView.text else{
            return
        }
        let timeStampOfTheNote = Date()
        
        let fetchquery = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        
        let noteID = noteToBeEdited!.noteId
        
        fetchquery.predicate = NSPredicate(format: "noteId=%@", noteID as CVarArg)

            do
            {
            let result = try managedObjectContext.fetch(fetchquery)
            print(result.count)
            for i in 0 ..< result.count
            {
                let obj = result[i] as! NSManagedObject
                obj.setValue(titleOfTheNote, forKey: "noteTitle")
                obj.setValue(textOfTheNote, forKey: "noteText")
                obj.setValue(timeStampOfTheNote, forKey: "noteTimeStamp")
                obj.setValue(noteID, forKey: "noteId")
            }
                try managedObjectContext.save()
            }
        catch
        {
            print("Couldn't update")
        }
            navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func cancelNote(){
        let alertController = UIAlertController(title: "Changes will be discarded", message: nil, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .destructive, handler: {(action:UIAlertAction) in
            self.navigationController?.popToRootViewController(animated: true)
        })
        alertController.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController,animated: true,completion: nil)
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
