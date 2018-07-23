//
//  PlutoconCell.swift
//  PlutoconSDK
//
//  Created by 김동혁 on 2018. 7. 20..
//  Copyright © 2018년 KongTech. All rights reserved.
//

import UIKit

class PlutoconCell: UITableViewCell {
    public static let CellId = "PlutoconCell"
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelMac: UILabel!
    @IBOutlet weak var viewIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
