//
//  ViewController.swift
//  Notes
//
//  Created by Suyog Ghinmine on 09/10/19.
//  Copyright © 2019 Suyog Ghinmine. All rights reserved.
//

//Frameworks:
import UIKit
import CoreData

class ViewController: UIViewController {
    
    //The array that contains all the notes:
    var notesArray : [NotesDataClass] = []
    
    //The outlet for the table:
    @IBOutlet weak var notesTable: UITableView!
    @IBOutlet weak var addButton: UIButton!
    
    @IBAction func addNewNote(_ sender: Any) {
        let sbObj = UIStoryboard(name: "Main", bundle: nil)
             let vcObj = sbObj.instantiateViewController(identifier: "NewNoteScreenSB")
             navigationController?.pushViewController(vcObj, animated: true)
         
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Register the nib for the table:
        notesTable.register(UINib(nibName: "NotesCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        //The title of nav bar:
        self.navigationItem.title = "Notes"
        
        //Floating circular button to add new note:
        addButton.layer.cornerRadius = addButton.frame.width/2
        addButton.backgroundColor = UIColor.systemBlue
        self.view.bringSubviewToFront(addButton)
}
    
    override func viewDidAppear(_ animated: Bool) {
        
        //Remove all items in array:
        notesArray.removeAll()
        
        //Call the function that reads notes from db:
        readNotesFromDataBase()
        
    }
    
    //The function that reads the notes from db and appends them to the array:
    func readNotesFromDataBase(){
        
        //The app delegate and managed object context:
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObjectContext = appdelegate.persistentContainer.viewContext
        
        //The query for fetching items in "Note" entity:
        let fetchquery = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        
        do
        {
            //All the objects that match specified query:
            let result = try managedObjectContext.fetch(fetchquery)
            //Iterate over the objects:
            for i in 0..<result.count
            {
                //Object of note from db:
                let note = result[i] as! Note
                
                //The attributes of the entity from the db:
                let titleOfTheNote = note.noteTitle!
                let textOfTheNote = note.noteText!
                let timeStampOfTheNote = note.noteTimeStamp!
                let idOfTheNote = note.noteId!
                
                //Define an object of NotesDataClass with obtained attributes:
                let thisNote = NotesDataClass(idOfTheNote : idOfTheNote,titleOfTheNote: titleOfTheNote, textOfTheNote: textOfTheNote, timeStampOfTheNote: timeStampOfTheNote)
                
                //Append this note to the array:
                notesArray.append(thisNote)
            }
            //Asynchronously sort the notes in the array by date and reload the table:
            DispatchQueue.main.async {
                self.notesArray = self.notesArray.sorted(by: {$1.noteTimeStamp<$0.noteTimeStamp})
                self.notesTable.reloadData()
            }
        }
        
            //In case of errors:
        catch
        {
            print("Failed to display data")
        }
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
}

extension ViewController : UITableViewDelegate, UITableViewDataSource{
    
    //No of rows in the table:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notesArray.count
    }
    
    //The properties for each cell:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NotesCell
       
        //Text in each label of the cell:
        if notesArray[indexPath.row].noteTitle == ""{
            cell.noteTitle.text = notesArray[indexPath.row].noteText
        }else{
        cell.noteTitle.text = notesArray[indexPath.row].noteTitle
        }
        cell.noteText.text = notesArray[indexPath.row].noteText
        cell.dateLabel.text = displayDateInMyFormat(theDate: notesArray[indexPath.row].noteTimeStamp)
  
        //Dynamic height for the cells:
        tableView.estimatedRowHeight = 400
        tableView.rowHeight = UITableView.automaticDimension
        
        return cell
    }
    
    //On selecting a row:
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //The note on that row:
        let thisNote = notesArray[indexPath.row]
        
        //Navigate to details page with the details of this note:
        let sbObj = UIStoryboard(name: "Main", bundle: nil)
        let vcObj = sbObj.instantiateViewController(identifier: "NotesDetailsScreenSB") as! NotesDetailsScreen
        vcObj.noteToBeEdited = thisNote
        navigationController?.pushViewController(vcObj, animated: true)
    }
    
    //Swipe actions at the rows:
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //Swipe action to delete:
        let swipeToDelete = UIContextualAction(style: .destructive, title: "Delete", handler: {(contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
            
            //Alert controller to delete
            let alertController = UIAlertController(title: "Delete?", message: "This note will be deleted", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let deleteAction = UIAlertAction(title: "Confirm", style: .destructive, handler: {(action) in
               
                print(self.notesArray[indexPath.row].noteId)
                self.delete(noteID: self.notesArray[indexPath.row].noteId)
                self.notesArray.remove(at: indexPath.row)
                tableView.reloadData()
            })
            alertController.addAction(deleteAction)
            
            self.present(alertController,animated: true,completion: nil)
        })
        
        let swipeToShare = UIContextualAction(style: .normal, title: "Share", handler: {(contextAction:UIContextualAction, sourceView : UIView, completionHandler : (Bool) -> Void) in
            
            let noteAsString = self.displayDateInMyFormat(theDate: self.notesArray[indexPath.row].noteTimeStamp) + "\n" + self.notesArray[indexPath.row].noteTitle + "\n" + self.notesArray[indexPath.row].noteText
            
            let fileURL = self.saveNoteAsText(theNote: noteAsString)
            
            let objectsToShare = [fileURL]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
            self.present(activityVC, animated: true, completion: nil)
            
            print(noteAsString)
        })
        
        return UISwipeActionsConfiguration(actions: [swipeToDelete, swipeToShare])
    }
    
    func saveNoteAsText(theNote:String) -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        let filename = paths[0].appendingPathComponent("Note.txt")

        do {
            try theNote.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
            print("Success")
        } catch {
            print("Failed to save")
        }
        return filename
    }
    
    func delete(noteID : UUID){
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObjectContext = appdelegate.persistentContainer.viewContext
        
        let fetchquery = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        
        fetchquery.predicate = NSPredicate(format: "noteId=%@", "\(noteID)")

        do
        {
            let result = try managedObjectContext.fetch(fetchquery)
            print(result.count)
            for i in 0..<result.count
            {
                let obj = result[i] as! NSManagedObject
                managedObjectContext.delete(obj)
            }
            try managedObjectContext.save()
        }
        catch
        {
            
            let alertController = UIAlertController(title: "Oops!", message: "Your note could not be deleted. This should not have happened. Please try again.", preferredStyle: .actionSheet)
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
    }
}

