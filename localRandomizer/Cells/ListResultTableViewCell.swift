//
//  ListResultTableViewCell.swift
//  localRandomizer
//
//  Created by Roman Trekhlebov on 14/09/2019.
//  Copyright © 2019 Roman Trekhlebov. All rights reserved.
//

import UIKit

class ListResultTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var resultLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func initCell(_ viewModel: ListResultViewModel) {
        dateLabel?.text = viewModel.returnDateString()
        resultLabel?.text = viewModel.resultString
    }
}
