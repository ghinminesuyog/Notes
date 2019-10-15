//
//  Notes.swift
//  Notes
//
//  Created by Suyog Ghinmine on 09/10/19.
//  Copyright © 2019 Suyog Ghinmine. All rights reserved.
//

import Foundation

class NotesDataClass {
    private(set) var noteTitle : String
    private(set) var noteText : String
    private(set) var noteTimeStamp : Date
    private(set) var noteId : UUID

    init(titleOfTheNote:String, textOfTheNote:String, timeStampOfTheNote: Date) {
        noteId = UUID()
        noteTitle = titleOfTheNote
        noteText = textOfTheNote
        noteTimeStamp = timeStampOfTheNote
    }
    init(idOfTheNote: UUID, titleOfTheNote:String, textOfTheNote:String, timeStampOfTheNote: Date) {
        noteId = idOfTheNote
        noteTitle = titleOfTheNote
        noteText = textOfTheNote
        noteTimeStamp = timeStampOfTheNote
    }
}
