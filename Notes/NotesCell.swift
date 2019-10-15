//
//  NotesCell.swift
//  Notes
//
//  Created by Suyog Ghinmine on 09/10/19.
//  Copyright © 2019 Suyog Ghinmine. All rights reserved.
//

import UIKit

class NotesCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var noteTitle: UILabel!
    
    @IBOutlet weak var noteText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
